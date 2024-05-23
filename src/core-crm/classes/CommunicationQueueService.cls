/**
 * @description Service Class for CommunicationQueue class getting case related record
 *
 * @see CommunicationQueues
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | gabriel.p.ventayen             | May 21,2024           | DEPP-8833	            | Created File                               |
 */
public inherited sharing class CommunicationQueueService {
    /**
     * @description Create Communication Queue Record and update case Initial_Communication_Status__c to pending
     * @param qualtricsSurveyList
     */
    public static List<Communication_Queue__c> enqueueEmail(
        List<Qualtrics_Survey__c> qualtricsSurveyList,
        AccessLevel accessLevel
    ) {
        Set<Id> qualtricsSurveyIds = (new Map<Id,Qualtrics_Survey__c>(qualtricsSurveyList)).keySet();
        Id orgWideEmailAddressSuccessId = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='success@qut.edu.au']?.Id;
        List<Case> caseRecords = [SELECT Id, ContactId, Engagement_List_Configuration__r.Email_Template__c, Engagement_List_Configuration__r.Communication_Channel__c, Contact.QUT_Learner_Email__c, Qualtrics_Survey__c  FROM Case WHERE Qualtrics_Survey__c IN :qualtricsSurveyIds WITH USER_MODE]; 
        Set<Id> createdCommunicationsQueueIdSet = new Set<Id>();
        List<Communication_Queue__c> createCommunicationQueueList = new List<Communication_Queue__c>();
        List<Communication_Queue__c> createdCommunicationQueues = new List<Communication_Queue__c>();
        List<Case> updateCaseList = new List<Case>();
        if (caseRecords.Size() > 0) {
            for (Case ca : caseRecords) {
                if (
                    (
                        ca.Engagement_List_Configuration__r.Communication_Channel__c == 'Email' 
                        || ca.Engagement_List_Configuration__r.Communication_Channel__c == 'Email & SMS'
                    )
                    && ca.Engagement_List_Configuration__r.Email_Template__c != null
                ) {
                    Communication_Queue__c createCommunicationQueue = new Communication_Queue__c();
                    createCommunicationQueue.Type__c = CommunicationQueuesDAO.TYPE_EMAIL;
                    createCommunicationQueue.Due_Date__c = System.today();
                    createCommunicationQueue.Business_Process__c = CommunicationQueuesDAO.BUSINESS_PROCESS_OUTREACH;
                    createCommunicationQueue.WhoId__c = ca.ContactId;
                    createCommunicationQueue.WhatId__c = ca.Id;
                    createCommunicationQueue.Template_Id__c = ca.Engagement_List_Configuration__r.Email_Template__c;
                    createCommunicationQueue.Sender__c = orgWideEmailAddressSuccessId;
                    createCommunicationQueue.Status__c = CommunicationQueuesDAO.STATUS_SCHEDULED;
                    createCommunicationQueue.Communication_Endpoint__c = CommunicationQueuesDAO.END_POINT_CONTACT_LEARNER_EMAIL;
                    createCommunicationQueueList.add(createCommunicationQueue);

                    Case updateCase = new Case();
                    updateCase.Id = ca.Id;
                    updateCase.Initial_Communication_Status__c = CasesDAO.INITIAL_COMMUNICATION_STATUS_PENDING;
                    updateCaseList.add(updateCase);
                }
            }
            try {
                //insert communication queue records
                List<Database.SaveResult> insertedRecords = new List<Database.SaveResult>();
                insertedRecords = CommunicationQueuesDAO.newInstance().insertRecords(createCommunicationQueueList, true, accessLevel);
                for (Database.SaveResult sr : insertedRecords) {
                    if (sr.isSuccess()){
                        createdCommunicationsQueueIdSet.add(sr.getId());
                    }
                }

                if (createdCommunicationsQueueIdSet.size() > 0) {
                    createdCommunicationQueues = [SELECT Id, Type__c, Due_Date__c, Business_Process__c, WhoId__c, WhatId__c, Template_Id__c, Sender__c, Status__c, Communication_Endpoint__c FROM Communication_Queue__c WHERE Id IN :createdCommunicationsQueueIdSet WITH USER_MODE];
                }
                //update case records.
                CasesDAO.newInstance().updateRecords(updateCaseList, true, accessLevel);
            } catch (Exception e) {
                Logger.error('Exception caught in method enqueueEmail in class CommunicationQueueService.').setExceptionDetails(e);
            } finally {
                if (Logger.getBufferSize() > 0) { Logger.saveLog(); }
            }
        }
        
        return createdCommunicationQueues;
    }

    /**
     * @description Create Communication Queue Record and update case Initial_Communication_Status__c to pending
     * @param caseList
     */
    public static List<Communication_Queue__c> enqueueEmail(
        List<Case> caseList,
        AccessLevel accessLevel
    ) {
        Set<Id> caseIds = (new Map<Id,Case>(caseList)).keySet();
        Id orgWideEmailAddressSuccessId = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='success@qut.edu.au']?.Id;
        Set<Id> createdCommunicationsQueueIdSet = new Set<Id>();
        List<Communication_Queue__c> createCommunicationQueueList = new List<Communication_Queue__c>();
        List<Communication_Queue__c> createdCommunicationQueues = new List<Communication_Queue__c>();
        List<Case> caseRecords = [SELECT Id, ContactId, Engagement_List_Configuration__r.Email_Template__c, Engagement_List_Configuration__r.Communication_Channel__c, Contact.QUT_Learner_Email__c, Qualtrics_Survey__c  FROM Case WHERE Id IN :caseIds WITH USER_MODE];
        List<Case> updateCaseList = new List<Case>();
        if (caseRecords.Size() > 0) {
            for (Case ca : caseRecords) {
                if (
                    (
                        ca.Engagement_List_Configuration__r.Communication_Channel__c == 'Email' 
                        || ca.Engagement_List_Configuration__r.Communication_Channel__c == 'Email & SMS'
                    )
                    && ca.Engagement_List_Configuration__r.Email_Template__c != null
                ) {
                    Communication_Queue__c createCommunicationQueue = new Communication_Queue__c();
                    createCommunicationQueue.Type__c = CommunicationQueuesDAO.TYPE_EMAIL;
                    createCommunicationQueue.Due_Date__c = System.today();
                    createCommunicationQueue.Business_Process__c = CommunicationQueuesDAO.BUSINESS_PROCESS_OUTREACH;
                    createCommunicationQueue.WhoId__c = ca.ContactId;
                    createCommunicationQueue.WhatId__c = ca.Id;
                    createCommunicationQueue.Template_Id__c = ca.Engagement_List_Configuration__r.Email_Template__c;
                    createCommunicationQueue.Sender__c = orgWideEmailAddressSuccessId;
                    createCommunicationQueue.Status__c = CommunicationQueuesDAO.STATUS_SCHEDULED;
                    createCommunicationQueue.Communication_Endpoint__c = CommunicationQueuesDAO.END_POINT_CONTACT_LEARNER_EMAIL;
                    createCommunicationQueueList.add(createCommunicationQueue);

                    Case updateCase = new Case();
                    updateCase.Id = ca.Id;
                    updateCase.Initial_Communication_Status__c = CasesDAO.INITIAL_COMMUNICATION_STATUS_PENDING;
                    updateCaseList.add(updateCase);
                }
            }
            try {
                //insert communication queue records
                List<Database.SaveResult> insertedRecords = new List<Database.SaveResult>();
                insertedRecords = CommunicationQueuesDAO.newInstance().insertRecords(createCommunicationQueueList, true, accessLevel);
                for (Database.SaveResult sr : insertedRecords) {
                    if (sr.isSuccess()){
                        createdCommunicationsQueueIdSet.add(sr.getId());
                    }
                }

                if (createdCommunicationsQueueIdSet.size() > 0) {
                    createdCommunicationQueues = [SELECT Id, Type__c, Due_Date__c, Business_Process__c, WhoId__c, WhatId__c, Template_Id__c, Sender__c, Status__c, Communication_Endpoint__c FROM Communication_Queue__c WHERE Id IN :createdCommunicationsQueueIdSet WITH USER_MODE];
                }
                //update case records.
                CasesDAO.newInstance().updateRecords(updateCaseList, true, accessLevel);
            } catch (Exception e) {
                Logger.error('Exception caught in method enqueueEmail in class CommunicationQueueService.').setExceptionDetails(e);
            } finally {
                if (Logger.getBufferSize() > 0) { Logger.saveLog(); }
            }
        }
        
        return createdCommunicationQueues;
    }

}
