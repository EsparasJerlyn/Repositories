/**
 * @description Class for Processing Engagement List Event Candidate
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 15, 2024         | DEPP-8484              | Created file                 |
 */
public with sharing class ELECandidateProcessor {          

    public List<ELECandidateProcessResult> process(Map<Id, Engagement_List_Event__c> eventCandidateMap, Engagement_List_Criteria__c criteria){
                  
        List<ELECandidateProcessResult> result = new List<ELECandidateProcessResult>();        
        EngagementListEventsDAO elEventsDAO = new EngagementListEventsDAO();
        
        Set<Id> programEnrollmentIds = new Set<Id>();
        Set<Id> completedCadenceIds = new Set<Id>();
        Set<Id> courseConnectionIds = new Set<Id>();
        Set<Id> courseConnectionAssessmentIds = new Set<Id>();
        Set<Id> programEnrollmentBreachIds = new Set<Id>();
        Set<Id> leaveOfAbsenceIds = new Set<Id>();

        String configId = criteria.Engagement_List_Configuration__r.Id;
        String configName = criteria.Engagement_List_Configuration__r.Name;
        Id criteriaId = criteria.Id;

        Map<EngagementListEventKey, ELEventCandidate> eventCandidateKeyMap = new Map<EngagementListEventKey, ELEventCandidate>();
        Set<Id> contactIds = eventCandidateMap.keySet();
        for(Id contactId : contactIds){
            for(Engagement_List_Event__c eventCandidate : eventCandidateMap.values()){
                programEnrollmentIds = setIds(eventCandidate.Program_Enrollment__c, programEnrollmentIds);
                completedCadenceIds = setIds(eventCandidate.Completed_Cadence__c, completedCadenceIds);
                courseConnectionIds = setIds(eventCandidate.Course_Connection__c, courseConnectionIds);
                courseConnectionAssessmentIds = setIds(eventCandidate.Course_Connection_Assessment__c, courseConnectionAssessmentIds);
                programEnrollmentBreachIds = setIds(eventCandidate.Program_Enrollment_Breach__c, programEnrollmentBreachIds);
                leaveOfAbsenceIds = setIds(eventCandidate.Leave_of_Absence__c, leaveOfAbsenceIds);
                EngagementListEventKey eventCandidateKey = generateKey(eventCandidate, contactId, criteriaId);
                eventCandidateKeyMap.put(eventCandidateKey, new ELEventCandidate(eventCandidate, contactId));
            }
        }

        Map<String, Set<Id>> relatedRecordIdMap = new Map<String, Set<Id>>{
            'engagementListCriteriaId' => new Set<Id>{criteriaId},
            'programEnrollmentIds' => programEnrollmentIds,
            'completedCadenceIds' => completedCadenceIds,
            'courseConnectionIds' => courseConnectionIds,
            'courseConnectionAssessmentIds' => courseConnectionAssessmentIds,
            'programEnrollmentBreachIds' => programEnrollmentBreachIds,
            'leaveOfAbsenceIds' => leaveOfAbsenceIds
        };

        System.debug('relatedRecordIdMap: ' + relatedRecordIdMap);
        Map<Id, Case> openCaseMap = new Map<Id, Case>();
        List<Case> openOutreachCases = CasesDAO.newInstance().getCasesByStatusAndRecordType(new Set<String>{CasesDAO.CASE_STATUS_OPEN}, CasesDAO.OUTREACH_RECTYPE_ID, AccessLevel.SYSTEM_MODE);
        for(Case caseRecord : openOutreachCases){
            openCaseMap.put(caseRecord.ContactId, caseRecord);
        }
        System.debug('openCaseMap: ' + openCaseMap);
        Map<Case, Engagement_List_Event__c> outreachCaseMap = new Map<Case, Engagement_List_Event__c>();
        List<Engagement_List_Event__c> newEvents = new List<Engagement_List_Event__c>();
        for(Engagement_List_Event__c existingEvent : elEventsDAO.getEngagementListEventsByRelatedRecordIds(relatedRecordIdMap, AccessLevel.SYSTEM_MODE)){
            EngagementListEventKey existingEventKey = generateKey(existingEvent, existingEvent.Case__r.ContactId, existingEvent.Engagement_List_Criteria__r.Id);
            for(EngagementListEventKey eventCandidateKey : eventCandidateKeyMap.KeySet()){
                if(!eventCandidateKey.isDuplicate(existingEventKey)){
                    System.debug('Key not existing: ');
                    Id eventCandidateContactId = eventCandidateKeyMap.get(eventCandidateKey).getContactId();
                    Engagement_List_Event__c event = eventCandidateKeyMap.get(eventCandidateKey).getEvent();
                    event.Engagement_List_Criteria__c = criteriaId;
                    if(openCaseMap.containsKey(eventCandidateContactId)){
                        System.debug('Creating Events only...');
                        event.Case__c = openCaseMap.get(eventCandidateContactId).Id;
                        newEvents.add(event);
                        result.add(new ELECandidateProcessResult(event, ELECandidateProcessResult.Outcome.EVENT_CREATED));
                    }else{
                        System.debug('Creating case...');
                        outreachCaseMap.put(createCase(new Engagement_List_Configuration__c(Id = configId, Name = configName)), event);
                    }
                    
                }else{
                    System.debug('Key IS existing: ');
                    result.add(new ELECandidateProcessResult(eventCandidateKeyMap.get(eventCandidateKey).getEvent(), ELECandidateProcessResult.Outcome.EVENT_NOT_CREATED));
                }
                eventCandidateKeyMap.remove(eventCandidateKey);
            }
            
        }

        List<Case> outReachCases = new List<Case>();
        outReachCases.addAll(outreachCaseMap.keySet());

        if(!outreachCaseMap.isEmpty()){
            CasesDAO.newInstance().insertRecords(outReachCases, false, AccessLevel.SYSTEM_MODE);   
        }

        for(Case caseRec : outReachCases){
            for(Engagement_List_Event__c event : outreachCaseMap.values()){
                event.Case__c = caseRec.Id;
                newEvents.add(event);
            }
        }
        if(!newEvents.isEmpty()){
            insert newEvents;
        }

        return result;
    }

    public Case createCase(Engagement_List_Configuration__c engagementListConfig){

        String groupName = 'Student Success - Student Retention';
        Id studentRetentionQueue = GroupsDAO.newInstance().getQueueByName(groupName);

        Case newCase = new Case(); 
        newCase.RecordTypeId = CasesDAO.OUTREACH_RECTYPE_ID;
        newCase.Case_Type__c = CasesDAO.CASE_TYPE_STUDENT_SUCCESS_RETENTION;
        newCase.Origin = CasesDAO.ORIGIN_ENGAGEMENT_LIST;
        newCase.Subject = engagementListConfig.Name;
        newCase.OwnerId = studentRetentionQueue;
        newCase.Description = CasesDAO.DESCRIPTION_ENGAGEMENT_LIST;
        newCase.Engagement_List_Configuration__c = engagementListConfig.Id;
        newCase.Status = CasesDAO.STATUS_CREATED;
        newCase.Priority = CasesDAO.PRIORITY_LOW;

        return newCase;
    }

    private Set<Id> setIds(Id recordId, Set<Id> idSet){
        if(recordId != null){
            idSet.add(recordId);
        }
        return idSet;
    }
    
    private EngagementListEventKey generateKey(Engagement_List_Event__c event, Id contactId, Id criteriaId){
        return new EngagementListEventKey(event, contactId, criteriaId);
    }

    public class ELEventCandidate {

        private Engagement_List_Event__c event;
        private Id contactId;

        public ELEventCandidate(Engagement_List_Event__c event, Id contactId){
            this.event = event;
            this.contactId = contactId;
        }

        public Engagement_List_Event__c getEvent() {
            return event;
        }
    
        public void setEvent(Engagement_List_Event__c event) {
            this.event = event;
        }
    
        public Id getContactId() {
            return contactId;
        }
    
        public void setContactId(Id contactId) {
            this.contactId = contactId;
        }
    }
}