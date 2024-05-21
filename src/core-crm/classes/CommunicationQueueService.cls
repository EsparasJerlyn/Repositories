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
     * @param qualtricsSurvey
     */
    public static Communication_Queue__c enqueueEmail(
        Qualtrics_Survey__c qualtricsSurvey,
        AccessLevel accessLevel
    ) {
        Id qsId = qualtricsSurvey.Id;
        Id orgWideEmailAddressSuccessId = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='success@qut.edu.au']?.Id;
        List<Case> caseRecords = [SELECT Id, ContactId, Engagement_List_Configuration__r.Email_Template__c, Engagement_List_Configuration__r.Communication_Channel__c, Contact.QUT_Learner_Email__c, Qualtrics_Survey__c  FROM Case WHERE Qualtrics_Survey__c = :qsId WITH USER_MODE LIMIT 1]; 
        Set<Id> createdCommunicationsQueueIdSet = new Set<Id>();

        if (
            caseRecords.Size() > 0 
            && ( 
                caseRecords[0].Engagement_List_Configuration__r.Communication_Channel__c == 'Email' 
                || caseRecords[0].Engagement_List_Configuration__r.Communication_Channel__c == 'Email & SMS'
            )
            && caseRecords[0].Engagement_List_Configuration__r.Email_Template__c != null
        ) {
            try {
                //create communication queue record
                List<Communication_Queue__c> createCommunicationQueueList = new List<Communication_Queue__c>();
                Communication_Queue__c createCommunicationQueue = new Communication_Queue__c();
                createCommunicationQueue.Type__c = 'Email';
                createCommunicationQueue.Due_Date__c = System.today();
                createCommunicationQueue.Business_Process__c = 'Outreach Initial Email';
                createCommunicationQueue.WhoId__c = caseRecords[0].ContactId;
                createCommunicationQueue.WhatId__c = caseRecords[0].Id;
                createCommunicationQueue.Template_Id__c = caseRecords[0].Engagement_List_Configuration__r.Email_Template__c;
                createCommunicationQueue.Sender__c = orgWideEmailAddressSuccessId;
                createCommunicationQueue.Status__c = 'Scheduled';
                createCommunicationQueue.Communication_Endpoint__c = 'Contact QUT Learner Email';
                createCommunicationQueueList.Add(createCommunicationQueue);

                List<Database.SaveResult> insertedRecords = new List<Database.SaveResult>();
                insertedRecords = CommunicationQueuesDAO.newInstance().insertRecords(createCommunicationQueueList, true, accessLevel);
                
                
                for (Database.SaveResult sr : insertedRecords) {
                    if (sr.isSuccess()){
                        createdCommunicationsQueueIdSet.add(sr.getId());
                    }
                }
            
                //update case's Initial_Communication_Status__C to pending
                List<Case> updateCaseList = new List<Case>();
                Case updateCase = new Case();
                updateCase.Id = caseRecords[0].Id;
                updateCase.Initial_Communication_Status__c = 'Pending';
                updateCaseList.add(updateCase);
                CasesDAO.newInstance().updateRecords(updateCaseList, true, accessLevel);
            } catch (Exception e) {
                Logger.error('Exception caught in method enqueueEmail in class CommunicationQueueService.').setExceptionDetails(e);
            } finally {
                if (Logger.getBufferSize() > 0) { Logger.saveLog(); }
            }
        }

        return [SELECT Id, Type__c, Due_Date__c, Business_Process__c, WhoId__c, WhatId__c, Template_Id__c, Sender__c, Status__c, Communication_Endpoint__c FROM Communication_Queue__c WHERE Id IN :createdCommunicationsQueueIdSet WITH USER_MODE LIMIT 1];
    }

}
