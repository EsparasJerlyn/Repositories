/**
 * @description Test class for SalesCadenceEmailRequestCommand
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                    |
      |--------------------------------|-----------------------|------------------------|-----------------------------------|
      | eccarius.munoz      	       | September 2, 2023     | DEPP-6138              | Created file                      |
      | eccarius.munoz      	       | September 2, 2023     | DEPP-6138              | added method for domestic         |
      | sebastianne.k.trias            | June 06, 2024         | DEPP-8474              | Modify method setOptOutAndInDates |
 */

@isTest
public with sharing class SalesCadenceEmailRequestCommandTest {

    @TestSetup
    static void setupData(){
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) { 

            List<Lead_Score_Configuration__c> leadScoreParentConfigList = new List<Lead_Score_Configuration__c>();
            leadScoreParentConfigList.add(
                new Lead_Score_Configuration__c(
                    Name = 'Total Max Score DUG',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG,
                    Domestic_International__c = 'Undetermined',
                    Study_Level__c = 'Undetermined'
                )
            );

            LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreParentConfigList, true, AccessLevel.SYSTEM_MODE);

            List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

            leadScoreConfigList.add(
                new Lead_Score_Configuration__c(
                    Name = 'Marketing consent',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                    Domestic_International__c = 'Domestic',
                    Study_Level__c = 'Undetermined',
                    Description__c = '',
                    Score_Allocation__c = null,
                    Time_Limit_Months__c = null,
                    Max_Score__c = 20,
                    Parent_Category__c = leadScoreParentConfigList[0].Id
                )
            );

            leadScoreConfigList.add(
                new Lead_Score_Configuration__c(
                    Name = 'Marketing consent',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                    Domestic_International__c = 'International',
                    Study_Level__c = 'Undetermined',
                    Description__c = '',
                    Score_Allocation__c = null,
                    Time_Limit_Months__c = null,
                    Max_Score__c = 20,
                    Parent_Category__c = leadScoreParentConfigList[0].Id
                )
            );

            LeadScoreConfigurationDAO.newInstance()
                .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

            List<Lead_Score_Configuration__c> leadScoreConfigChildList = new List<Lead_Score_Configuration__c>();
            leadScoreConfigChildList.addAll(TestDataFactory.createDomestcAndUndeterminedSubCategory(
                leadScoreConfigList[0].Id,
                new List<String>{
                    'Yes',
                    'is blank'
                },
                new List<Integer>{200,200}
            ));
            leadScoreConfigChildList.addAll(TestDataFactory.createIntlAndUndeterminedSubCategory(
                leadScoreConfigList[1].Id,
                new List<String>{
                    'Yes',
                    'is blank'
                },
                new List<Integer>{200,200}
            ));

            LeadScoreConfigurationDAO.newInstance()
                .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1,3);
            contactList[0].Calculated_Cadence__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED;
            contactList[0].hed__Citizenship_Status__c = 'International';
            contactList[1].Calculated_Cadence__c = 'Domestic Offer Lapsed (Automated)';
            contactList[1].hed__Citizenship_Status__c = 'Domestic';
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();

            List<Nurture_Track_Configuration__c> initialNurtureListInt = TestDataFactory.createNurtureTrackConfigRecords(1);
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureListInt){
                nurtureList.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED,
                        Lead_Score_Threshold__c = 3,
                        Status__c = 'Active'
                    )
                );
            }

            List<Nurture_Track_Configuration__c> initialNurtureListDom = TestDataFactory.createNurtureTrackConfigRecords(1);
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureListDom){
                nurtureList.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'Domestic Offer Lapsed (Automated)',
                        Lead_Score_Threshold__c = 3,
                        Status__c = 'Active'
                    )
                );
            }

            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);  

            List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
            EmailTemplate emailTemplate = new EmailTemplate();
            emailTemplate.Name = 'Test Email Temp';
            emailTemplate.Subject = 'Test Subject';
            emailTemplate.HtmlValue = '<html></html>';
            emailTemplate.TemplateType = 'custom';
            emailTemplate.UiType = 'SFX';
            emailTemplates.add(emailTemplate);
            EmailTemplatesDAO.newInstance().insertRecords(emailTemplates, false, AccessLevel.SYSTEM_MODE);
        }
    }

    @isTest
    private static void sendEmailWithSentStatusTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            
            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(2);
            List<EmailTemplate> emailTemplates = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{'Test Email Temp'}, AccessLevel.USER_MODE);

            for(Contact con: contactList){
                con.HasOptedOutOfEmail = true;
            }

            ContactsDAO.newInstance().updateRecords(contactList, false, AccessLevel.SYSTEM_MODE);
            Set<Id> resultIds = (new Map<Id,SObject>(contactList)).keySet();
            List<Communication_Queue__c> commsQueueList = TestDataFactory.createCommunicationQueuePerContactOrLead(
                resultIds,                 
                CommunicationQueuesDAO.STATUS_SCHEDULED,
                emailTemplates[0].Id
            );
            CommunicationQueuesDAO.newInstance().insertRecords(commsQueueList, false, AccessLevel.USER_MODE);
            
            List<Communication_Queue__c> communicationQueueList = CommunicationQueuesDAO.newInstance().getComminicationQueueRecordsByStatus(
                new Set<String>{CommunicationQueuesDAO.STATUS_SCHEDULED},
                AccessLevel.USER_MODE
            );
            Test.startTest();
            for(Contact con : contactList){
                con.Email_Opt_In_DateTime__c = Date.today();
                con.HasOptedOutOfEmail = false;
                con.QUT_Applicant__c = true;
            }
            MarketingConsentHelper.runSetOptOutAndInDates.clear();
            ContactsDAO.newInstance().updateRecords(contactList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            RequestCommand cmd = new RequestCommand();
            cmd.setCommand(new SalesCadenceEmailRequestCommand(communicationQueueList));
            cmd.executeCommand();     
        }

        List<Communication_Queue__c> commsQueue = CommunicationQueuesDAO.newInstance().getComminicationQueueRecordsByStatus(
            new Set<String>{CommunicationQueuesDAO.STATUS_SENT},
            AccessLevel.USER_MODE
        );

        System.assert(!commsQueue.isEmpty(), 'List should not be empty.');
    }

    /* @isTest
    private static void sendEmailWithSentStatusTestDomestic() {
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            Lead_Score_Detail__c lsd = new Lead_Score_Detail__c();
            lsd.Total_Lead_Score__c = 350;
            insert lsd;

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1,2);
            for(Contact c :contactList ){
                c.Calculated_Cadence__c = 'Domestic Offer Lapsed (Automated)';
                c.hed__Citizenship_Status__c = 'Domestic';
                c.Lead_Score_Detail__c = lsd.Id;
            }
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
            List<EmailTemplate> emailTemplates = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{'Test Email Temp'}, 'USER_MODE');

            Set<Id> resultIds = (new Map<Id,SObject>(contactList)).keySet();
            List<Communication_Queue__c> commsQueueList = TestDataFactory.createCommunicationQueuePerContactOrLead(
                resultIds, 
                CommunicationQueuesDAO.STATUS_SCHEDULED,
                emailTemplates[0].Id
            );
            for(Communication_Queue__c cq : commsQueueList){
                cq.Business_Process__c = 'Domestic Automated Cadence Email';
            }
            CommunicationQueuesDAO.newInstance().insertRecords(commsQueueList, false, AccessLevel.USER_MODE);
            
            List<Communication_Queue__c> communicationQueueList = CommunicationQueuesDAO.newInstance().getComminicationQueueRecordsByStatus(
                new Set<String>{CommunicationQueuesDAO.STATUS_SCHEDULED},
                AccessLevel.USER_MODE
            );
            Test.startTest();
            RequestCommand cmd = new RequestCommand();
            cmd.setCommand(new SalesCadenceEmailRequestCommand(communicationQueueList));
            cmd.executeCommand();     
            Test.stopTest();
        }

        List<Communication_Queue__c> commsQueue = CommunicationQueuesDAO.newInstance().getComminicationQueueRecordsByStatus(
            new Set<String>{CommunicationQueuesDAO.STATUS_SENT},
            AccessLevel.USER_MODE
        );

        System.assert(!commsQueue.isEmpty(), 'List should not be empty.');
    } */
}