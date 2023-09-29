/**
 * @description Test class for EmailTriggerSalesCadenceBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz      	       | August 31, 2023       | DEPP-6138              | Created file                 | 
 */
@isTest
public with sharing class EmailTriggerSalesCadenceBatchTest {

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

            Lead_Score_Detail__c lsd = new Lead_Score_Detail__c();
            lsd.Total_Lead_Score__c = 350;
            insert lsd;

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
                CommunicationQueuesDAO.STATUS_SCHEDULED,
                emailTemplate.Id
            );
            
            CommunicationQueuesDAO.newInstance().insertRecords(commsQueueList, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    private static void executeBatchTest() {
        Id batchableId;
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            Test.startTest();
            EmailTriggerSalesCadenceBatch batchable = new EmailTriggerSalesCadenceBatch();
            batchableId = Database.executeBatch(batchable);            
            Test.stopTest();
        }

        System.assert(
            batchableId != null,
            'The batch job failed to execute.'
        );
    }

}
