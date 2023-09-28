/**
 * @description Test class for CompleteCadenceBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz      	       | September 27, 2023    | DEPP-6763              | Created file                 | 
 */
@isTest
public with sharing class CompleteCadenceBatchTest {
    @TestSetup
    static void setupData(){
        
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_System_Administrator' });
        System.runAs(TestDataFactory.getSystemAdminUser()) { 
            List<Nurture_Track_Configuration__c> initialNurtureList = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureList){
                nurtureList.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'International Application Submission - Direct Applicant (Automated)',
                        Lead_Score_Threshold__c = 3,
                        Status__c = 'Active'
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);  

            List<Lead_Score_Detail__c> lsdList = new List<Lead_Score_Detail__c>();
            Lead_Score_Detail__c lsd = new Lead_Score_Detail__c();
            lsd.Total_Lead_Score__c = 350;
            lsdList.add(lsd);
            LeadScoreDetailsDAO.newInstance().insertRecords(lsdList, false, AccessLevel.SYSTEM_MODE); 

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1,2);
            for(Contact c :contactList ){
                c.Calculated_Cadence__c = 'International Application Submission - Direct Applicant (Automated)';
                c.hed__Citizenship_Status__c = 'Domestic';
                c.Lead_Score_Detail__c = lsd.Id;
            }
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
            EmailTemplate emailTemplate = new EmailTemplate();
            emailTemplate.Name = 'Test Email Temp';
            emailTemplate.Subject = 'Test Subject';
            emailTemplate.HtmlValue = '<html></html>';
            emailTemplate.TemplateType = 'custom';
            emailTemplate.UiType = 'SFX';
            emailTemplates.add(emailTemplate);
            EmailTemplatesDAO.newInstance().insertRecords(emailTemplates, false, AccessLevel.SYSTEM_MODE);

            Set<Id> resultIds = (new Map<Id,SObject>(contactList)).keySet();
            List<Communication_Queue__c> commsQueueList = TestDataFactory.createCommunicationQueuePerContactOrLead(
                resultIds, 
                CommunicationQueuesDAO.STATUS_SENT,
                emailTemplate.Id
            );

            ImplementationSelector.DAO.setMock(new ActionCadenceStepTrackersDAOMock());
            List<ActionCadenceStepTracker> actionCadenceTracker = ActionCadenceStepTrackersDAO.newInstance().getActionCadenceStepTrackerForEmail(new List<String>(), AccessLevel.SYSTEM_MODE);

            for(Communication_Queue__c comsQueue : commsQueueList){
                comsQueue.ActionCadenceStepTrackerId__c = actionCadenceTracker[0].Id;
            }

            CommunicationQueuesDAO.newInstance().insertRecords(commsQueueList, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    private static void executeBatchTest() {
        Id batchableId;
        
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            Test.startTest();
            ImplementationSelector.DAO.setMock(new ActionCadenceStepTrackersDAOMock());
            CompleteCadenceBatch batchable = new CompleteCadenceBatch();
            batchableId = Database.executeBatch(batchable);            
            Test.stopTest();
        }

        System.assert(
            batchableId != null,
            'The batch job failed to execute.'
        );
    }
}