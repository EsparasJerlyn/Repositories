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

    public List<ELECandidateProcessResult> process(Map<Id, List<Engagement_List_Event__c>> eventCandidateMap, Engagement_List_Criteria__c criteria){
                  
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
            for(Engagement_List_Event__c eventCandidate : eventCandidateMap.get(contactId)){
                programEnrollmentIds = setIds(eventCandidate.Program_Enrollment__c, programEnrollmentIds);
                completedCadenceIds = setIds(eventCandidate.Completed_Cadence__c, completedCadenceIds);
                courseConnectionIds = setIds(eventCandidate.Course_Connection__c, courseConnectionIds);
                courseConnectionAssessmentIds = setIds(eventCandidate.Course_Connection_Assessment__c, courseConnectionAssessmentIds);
                programEnrollmentBreachIds = setIds(eventCandidate.Program_Enrollment_Breach__c, programEnrollmentBreachIds);
                leaveOfAbsenceIds = setIds(eventCandidate.Leave_of_Absence__c, leaveOfAbsenceIds);
                EngagementListEventKey eventCandidateKey = generateKey(eventCandidate, contactId, eventCandidate.Engagement_List_Criteria__c); 
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

        Map<Id, Case> openCaseMap = getCaseMap(contactIds);   
        Map<Engagement_List_Event__c, Case> outreachCaseMap = new Map<Engagement_List_Event__c, Case>();
        List<Engagement_List_Event__c> newEvents = new List<Engagement_List_Event__c>();
        for(Engagement_List_Event__c existingEvent : elEventsDAO.getEngagementListEventsByRelatedRecordIds(relatedRecordIdMap, AccessLevel.SYSTEM_MODE)){
            EngagementListEventKey existingEventKey = generateKey(existingEvent, existingEvent.Case__r.ContactId, existingEvent.Engagement_List_Criteria__r.Id);
            for(EngagementListEventKey eventCandidateKey : eventCandidateKeyMap.KeySet()){
                if(!eventCandidateKey.isDuplicate(existingEventKey)){
                    Id eventCandidateContactId = eventCandidateKeyMap.get(eventCandidateKey).getContactId();
                    Engagement_List_Event__c event = eventCandidateKeyMap.get(eventCandidateKey).getEvent();
                    event.Engagement_List_Criteria__c = criteriaId;
                    if(openCaseMap.containsKey(eventCandidateContactId)){
                        event.Case__c = openCaseMap.get(eventCandidateContactId).Id;
                        newEvents.add(event);
                        result.add(new ELECandidateProcessResult(event, ELECandidateProcessResult.Outcome.EVENT_CREATED));
                    }else{
                        outreachCaseMap.put(event, createCase(new Engagement_List_Configuration__c(Id = configId, Name = configName)));
                        result.add(new ELECandidateProcessResult(event, ELECandidateProcessResult.Outcome.CASE_CREATED));
                    }
                }else{
                    result.add(new ELECandidateProcessResult(eventCandidateKeyMap.get(eventCandidateKey).getEvent(), ELECandidateProcessResult.Outcome.EVENT_NOT_CREATED));
                }
                eventCandidateKeyMap.remove(eventCandidateKey);
            }
            
        }

        if(!outreachCaseMap.values().isEmpty()){
            CasesDAO.newInstance().insertRecords(outreachCaseMap.values(), false, AccessLevel.SYSTEM_MODE);   
        }

        for(Engagement_List_Event__c event : outreachCaseMap.keySet()){
            if(outreachCaseMap.get(event).Id != null){
                event.Case__c = outreachCaseMap.get(event).Id;
                newEvents.add(event);
            }
        }

        if(!newEvents.isEmpty()){
            elEventsDAO.insertRecords(newEvents, false, AccessLevel.SYSTEM_MODE);   
        }

        return result;
    }

    private Map<Id, Case> getCaseMap(Set<Id> contactIds){
        
        Map<String, Object> params = new Map<String, Object> {
            'contactIds' => contactIds,
            'statusSet' => new Set<String>{CasesDAO.CASE_STATUS_OPEN},
            'recordTypeId' => CasesDAO.OUTREACH_RECTYPE_ID
        };

        Map<Id, Case> openCaseMap = new Map<Id, Case>();        
        List<Case> openOutreachCases = CasesDAO.newInstance().getCasesByContactIdStatusAndRecordType(params, AccessLevel.SYSTEM_MODE);
        for(Case caseRecord : openOutreachCases){
            openCaseMap.put(caseRecord.ContactId, caseRecord);
        }

        return openCaseMap;
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