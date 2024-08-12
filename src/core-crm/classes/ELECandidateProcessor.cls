/**
 * @description Class for Processing Engagement List Event Candidate
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 15, 2024         | DEPP-8484              | Created file                 |
      | kim.howard.capanas             |  May 22, 2024         | DEPP-7526              | Added caseRecord             |
      |                                |                       |                        | to ELECandidateProcessResult |
      | julie.jane.alegre              |  July 25, 2024        | DEPP-9953              | Update logic on updating     |
      |                                |                       |                        | Cases_Created__c field       |
 */
public with sharing class ELECandidateProcessor {

    public List<ELECandidateProcessResult> process(Map<Id, List<Engagement_List_Event__c>> eventCandidateMap, Engagement_List_Criteria__c criteria){
                  
        List<ELECandidateProcessResult> result = new List<ELECandidateProcessResult>();        
        
        Set<Id> programEnrollmentIds = new Set<Id>();
        Set<Id> completedCadenceIds = new Set<Id>();
        Set<Id> courseConnectionIds = new Set<Id>();
        Set<Id> courseConnectionAssessmentIds = new Set<Id>();
        Set<Id> programEnrollmentBreachIds = new Set<Id>();
        Set<Id> leaveOfAbsenceIds = new Set<Id>();

        String configId = criteria.Engagement_List_Configuration__r.Id;
        String configName = criteria.Engagement_List_Configuration__r.Name;
        Id criteriaId = criteria.Id;

        Map<EngagementListEventKey, ELECandidate> eventCandidateKeyMap = new Map<EngagementListEventKey, ELECandidate>();
        Set<Id> contactIds = eventCandidateMap.keySet();
        for(Id contactId : contactIds){
            for(Engagement_List_Event__c eventCandidate : eventCandidateMap.get(contactId)){
                programEnrollmentIds = addRecordToIdSet(eventCandidate.Program_Enrollment__c, programEnrollmentIds);
                completedCadenceIds = addRecordToIdSet(eventCandidate.Completed_Cadence__c, completedCadenceIds);
                courseConnectionIds = addRecordToIdSet(eventCandidate.Course_Connection__c, courseConnectionIds);
                courseConnectionAssessmentIds = addRecordToIdSet(eventCandidate.Course_Connection_Assessment__c, courseConnectionAssessmentIds);
                programEnrollmentBreachIds = addRecordToIdSet(eventCandidate.Program_Enrollment_Breach__c, programEnrollmentBreachIds);
                leaveOfAbsenceIds = addRecordToIdSet(eventCandidate.Leave_of_Absence__c, leaveOfAbsenceIds);
                EngagementListEventKey eventCandidateKey = generateKey(eventCandidate, contactId, eventCandidate.Engagement_List_Criteria__c); 
                eventCandidateKeyMap.put(eventCandidateKey, new ELECandidate(eventCandidate, contactId));
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

        for(Engagement_List_Event__c existingEvent : EngagementListEventsDAO.newInstance().getEngagementListEventsByRelatedRecordIds(relatedRecordIdMap, AccessLevel.SYSTEM_MODE)){
            EngagementListEventKey eventKey = generateKey(existingEvent, existingEvent.Case__r.ContactId, existingEvent.Engagement_List_Criteria__r.Id);
            if(eventCandidateKeyMap.containsKey(eventKey)){
                result.add(new ELECandidateProcessResult(eventCandidateKeyMap.get(eventKey).getEvent(), ELECandidateProcessResult.Outcome.EVENT_NOT_CREATED));
                eventCandidateKeyMap.remove(eventKey);
            }
        }

        List<Engagement_List_Event__c> newEvents = new List<Engagement_List_Event__c>();
        Map<Id, Case> openCaseMap = getCaseMap(contactIds, configId);

        ELECandidate candidate;
        Case caseRecord;
        Engagement_List_Event__c event;
        Id eventCandidateContactId;
        for(EngagementListEventKey candidateKey : eventCandidateKeyMap.keySet()){   
            candidate = eventCandidateKeyMap.get(candidateKey);
            eventCandidateContactId = candidate.getContactId();
            event = candidate.getEvent();
            event.Engagement_List_Criteria__c = criteriaId;

            if(openCaseMap.containsKey(eventCandidateContactId)){
                caseRecord = openCaseMap.get(eventCandidateContactId);
                event.Case__c = caseRecord.Id;
                newEvents.add(event);
                result.add(new ELECandidateProcessResult(event, ELECandidateProcessResult.Outcome.EVENT_CREATED, caseRecord));
                eventCandidateKeyMap.remove(candidateKey);
            }
        }

        Engagement_List_Configuration__c config = new Engagement_List_Configuration__c(Id = configId, Name = configName);
        Map<Id, Case> outreachCaseMap = new Map<Id, Case>();
        Set<String> outreachKeySet = new Set<String>();
        Id studentRetentionQueue = GroupsDAO.newInstance().getQueueByName(GroupsDAO.STUDENT_RETENTION_QUEUE);
        for(EngagementListEventKey candidateKey : eventCandidateKeyMap.keySet()){   
            candidate = eventCandidateKeyMap.get(candidateKey);
            eventCandidateContactId = candidate.getContactId();
            event = candidate.getEvent();

            List<String> parts = new List<String>{configId, eventCandidateContactId};
            String outreachKey = String.join(parts, '_'); 

            if(!outreachKeySet.contains(outreachKey)){
                outreachKeySet.add(outreachKey);
                caseRecord = createCase(config, studentRetentionQueue, outreachKey);
                outreachCaseMap.put(eventCandidateContactId, caseRecord);
                result.add(new ELECandidateProcessResult(event, ELECandidateProcessResult.Outcome.CASE_CREATED, caseRecord));
            }
        }

        Map<String, Object> saveRecordParam = new Map<String, Object>{
            'outreachCaseMap' => outreachCaseMap,
            'newEvents' => newEvents,
            'eventCandidateKeyMap' => eventCandidateKeyMap,
            'criteria' => criteria
        };

        saveRecords(saveRecordParam);

        return result;
    }

    private void saveRecords(Map<String, Object> saveRecordParam){
        Map<Id, Case> outreachCaseMap = (Map<Id, Case>) saveRecordParam.get('outreachCaseMap');
        List<Engagement_List_Event__c> newEvents = (List<Engagement_List_Event__c>) saveRecordParam.get('newEvents'); 
        Map<EngagementListEventKey, ELECandidate> eventCandidateKeyMap = (Map<EngagementListEventKey, ELECandidate>) saveRecordParam.get('eventCandidateKeyMap');
        Engagement_List_Criteria__c criteria = (Engagement_List_Criteria__c) saveRecordParam.get('criteria');

        try{
            if(!outreachCaseMap.values().isEmpty()){
                CasesDAO.newInstance().insertRecords(outreachCaseMap.values(), true, AccessLevel.SYSTEM_MODE);
                Map<Id,Case> caseMap = new Map<Id,Case>(outreachCaseMap.values());
                List<Case> caseList = CasesDAO.newInstance().getCasesByIdsImported(caseMap.keySet(), AccessLevel.SYSTEM_MODE);
                checkOutreachCases(caseList); 
            }

            ELECandidate eLECandidate;
            Id eventCandidateContactId;
            Engagement_List_Event__c event;
            for(EngagementListEventKey eventKey : eventCandidateKeyMap.keySet()){
                eLECandidate = eventCandidateKeyMap.get(eventKey);
                eventCandidateContactId = eLECandidate.getContactId();
                event = eLECandidate.getEvent();                
                event.Engagement_List_Criteria__c = criteria.Id;
                event.Case__c = outreachCaseMap.get(eventCandidateContactId).Id;
                newEvents.add(event);
            }

            if(!newEvents.isEmpty()){
                EngagementListEventsDAO.newInstance().insertRecords(newEvents, true, AccessLevel.SYSTEM_MODE);   
            }
            
            if(!outreachCaseMap.values().isEmpty()){
                //Query the current criteria to get the latest number of case created
                Engagement_List_Criteria__c currentCriteria = EngagementListCriteriasDAO.newinstance().getEntryCriteriaById(criteria.Id, AccessLevel.USER_MODE);
                Integer numberOfCaseCreated = currentCriteria.Cases_Created__c != null ? Integer.valueOf(currentCriteria.Cases_Created__c) : 0;
                criteria.Cases_Created__c = numberOfCaseCreated + outreachCaseMap.values().size();
                List<Engagement_List_Criteria__c> eventCriterias = new List<Engagement_List_Criteria__c>();
                eventCriterias.add(criteria);
                EngagementListCriteriasDAO.newInstance().updateRecords(eventCriterias, true, AccessLevel.SYSTEM_MODE);   
            }

        } catch(Exception e){
            Logger.error('Error in processing Engagement List Event Candidates.').setExceptionDetails(e);
        } finally {
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    private void checkOutreachCases(List<Case> caseList){
        List<Case> caseWithQualtricsIntrument = new List<Case>();
        List<Case> caseWithoutQualtricsIntrument = new List<Case>();
        for(Case caseRec : caseList){
            if(caseRec.Engagement_List_Configuration__r.Qualtrics_Instrument_Id__c != null){
                caseWithQualtricsIntrument.add(caseRec);
            }
            else{
                caseWithoutQualtricsIntrument.add(caseRec);
            }
        }

        if(!caseWithQualtricsIntrument.isEmpty()){
            OutreachCasePostCreationQueuable queueableCalls = new OutreachCasePostCreationQueuable(caseWithQualtricsIntrument);
            System.enqueueJob(queueableCalls);
        }
        if(!caseWithoutQualtricsIntrument.isEmpty()){
            CommunicationQueueService.enqueueEmail(caseWithoutQualtricsIntrument, AccessLevel.USER_MODE);
        }
    }

    private Map<Id, Case> getCaseMap(Set<Id> contactIds, Id configId){
        Map<Id, Case> openCaseMap = new Map<Id, Case>();  
        List<Case> openOutreachCases = CasesDAO.newInstance().getOpenOutreachCasesByConfigAndContactIds(contactIds, configId, AccessLevel.SYSTEM_MODE);
        for(Case caseRecord : openOutreachCases){
            openCaseMap.put(caseRecord.ContactId, caseRecord);
        }

        return openCaseMap;
    }

    public Case createCase(Engagement_List_Configuration__c engagementListConfig, Id studentRetentionQueue, String outreachKey){
        Case newCase = new Case(); 
        newCase.Outreach_Key__c = outreachKey;
        newCase.RecordTypeId = CasesDAO.OUTREACH_RECTYPE_ID;
        newCase.Case_Type__c = CasesDAO.CASE_TYPE_STUDENT_SUCCESS_RETENTION;
        newCase.Origin = CasesDAO.ORIGIN_ENGAGEMENT_LIST;
        newCase.Subject = engagementListConfig.Name;
        newCase.OwnerId = studentRetentionQueue;
        newCase.Description = CasesDAO.DESCRIPTION_ENGAGEMENT_LIST;
        newCase.Engagement_List_Configuration__c = engagementListConfig.Id;
        newCase.Status = CasesDAO.STATUS_CREATED;
        newCase.Priority = CasesDAO.PRIORITY_LOW;
        newCase.ContactId = outreachKey.substringAfter('_');

        return newCase;
    }

    private Set<Id> addRecordToIdSet(Id recordId, Set<Id> idSet){
        if(recordId != null){
            idSet.add(recordId);
        }
        return idSet;
    }
    
    private EngagementListEventKey generateKey(Engagement_List_Event__c event, Id contactId, Id criteriaId){
        return new EngagementListEventKey(event, contactId, criteriaId);
    }

    public class ELECandidate {

        private Engagement_List_Event__c event;
        private Id contactId;

        public ELECandidate(Engagement_List_Event__c event, Id contactId){
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