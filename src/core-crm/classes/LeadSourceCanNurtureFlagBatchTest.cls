/**
 * @description Batch class to LeadSourceCanNurtureFlagBatchTest
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                  |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------------------------|
      | arsenio.jr.dayrit              | March 06, 2024        | DEPP-8069              | Created file                                                    |
      | mark.j.mahilum                 | March 15, 2024        | DEPP-8314              | Added test method to cover the test scenario for contact having |
      |                                |                       |                        | application and method to test contact with no application      |
 */
@isTest
public with sharing class LeadSourceCanNurtureFlagBatchTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
        System.runAs(TestDataFactory.getProgramAdminUser()) {           
            
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Cadence_Name__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED;
            nurtureConfig.Lead_Score_Threshold__c = 3;
            nurtureConfig.Status__c = 'Active';
            nurtureList.add(nurtureConfig);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);   
        }
    }

    @isTest
    private static void testAutomaticInternationalPreApplicationPartnerSourcedEntry() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            // create marketing segmentation
            Marketing_Segmentation__c internationalMS = new Marketing_Segmentation__c(My_Citizenship_Status__c = 'International Student');
            insert internationalMS;
            // create lead
            List<Lead> newLeads = createTestLeadRecords(0, 1);
            newLeads[0].Marketing_Segmentation__c = internationalMS.Id;
            newLeads[0].Lead_Source_Category__c = 'Partner Sourced';
            newLeads[0].Calculated_Cadence__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED;
            LeadsDAO.newInstance().insertRecords(newLeads, false, AccessLevel.SYSTEM_MODE);
            // SOQL the lead so it includes Marketing_Segmentation__r.My_Citizenship_Status__c
            newLeads[0] = [
                SELECT Id, Marketing_Segmentation__r.My_Citizenship_Status__c, 
                Can_Nurture__c, Calculated_Cadence__c 
                FROM Lead LIMIT 1];

            List<Nurture_Track_Configuration__c> nt = [SELECT Id FROM Nurture_Track_Configuration__c LIMIT 1];
            Completed_cadence__c cadence1 = new Completed_Cadence__c();
            cadence1.Lead__c = newLeads[0].Id;
            cadence1.Nurture_Track_Configuration__c = nt[0].Id;
            cadence1.Completed_Cadence_Status__c ='';
            
            insert cadence1;
            
            Datetime todaysDate = Datetime.now().addYears(-4);
            Test.setCreatedDate(cadence1.Id, todaysDate);

        }
    	Test.startTest();
        // call method
        LeadSourceCanNurtureFlagBatch batchable = new LeadSourceCanNurtureFlagBatch();
        Id batchableId = Database.executeBatch(batchable);
        Test.stopTest();
        // assert
        System.assert(
            batchableId != null,
            'The batch job failed to execute.'
        );
        
        List<Lead> leadList = [SELECT Id,Can_Nurture__c FROM Lead WHERE Lead_Source_Category__c = 'Partner Sourced'];
        System.assert(!leadList[0].Can_Nurture__c,'is can_nurture not false');
    }
    
    
    @isTest
    private static void testContactAndLeadWithNoActiveApplicantions(){
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            conList[0].recordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            conList[0].Lead_Source_Category__c = LeadsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCED;
            conList[0].QUT_Applicant__c = TRUE;
            List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
            leadList[0].Lead_Source_Category__c = LeadsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCED;
            leadList[0].Can_Nurture__c = TRUE;
            leadList[0].Lead_Type__c = LeadsDAO.LEARNER_LEAD_TYPE;
            ContactsDAO.newInstance().insertRecords(conList, false, AccessLevel.SYSTEM_MODE);
            LeadsDAO.newInstance().insertRecords(leadList, false, AccessLevel.SYSTEM_MODE);
            
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Cadence_Name__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED;
            nurtureConfig.Lead_Score_Threshold__c = 3;
            nurtureConfig.Status__c = 'Active';
            nurtureList.add(nurtureConfig);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);
            
            Id contactID = ContactsDAO.newInstance().getPersonContactsWithLimit(1)[0].Id;
            Id leadID = LeadsDAO.newInstance().getLeadsWithLimit(1)[0].Id;
            Completed_cadence__c cadence1 = new Completed_Cadence__c();
            cadence1.Contact__c = contactID;
            cadence1.Nurture_Track_Configuration__c = nurtureList[0].Id;
            cadence1.Completed_Cadence_Status__c ='Successful';
            insert cadence1;
            
            Test.setCreatedDate(cadence1.Id, Datetime.now().addYears(-4));
            
            Completed_cadence__c cadence2 = new Completed_Cadence__c();
            cadence2.Lead__c = leadID;
            cadence2.Nurture_Track_Configuration__c = nurtureList[0].Id;
            cadence2.Completed_Cadence_Status__c ='Successful';
            insert cadence2;
            
            Test.setCreatedDate(cadence2.Id, Datetime.now().addYears(-4));
        }
        
        Test.startTest();
        // call method
        LeadSourceCanNurtureFlagBatch batchable = new LeadSourceCanNurtureFlagBatch();
        Id batchableId = Database.executeBatch(batchable);
        Test.stopTest();
        // assert
        System.assert(
            batchableId != null,
            'The batch job failed to execute.'
        );
        
        List<Lead> leadList = [SELECT Id,Can_Nurture__c FROM Lead WHERE Lead_Source_Category__c =: LeadsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCED];
        List<Contact> contactList = [SELECT Id,Can_Nurture__c FROM Contact WHERE Lead_Source_Category__c =: LeadsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCED];
        System.assert(!leadList[0].Can_Nurture__c,'Lead can_nurture not reset');
        System.assert(!contactList[0].Can_Nurture__c,'Contact can_nurture not reset');
    }
    
    @isTest
    private static void testContactAndLeadWithaAssociatedActiveApplicantions(){
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            conList[0].recordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            conList[0].Lead_Source_Category__c = LeadsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCED;
            conList[0].QUT_Applicant__c = TRUE;
            List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
            leadList[0].Lead_Source_Category__c = LeadsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCED;
            leadList[0].Can_Nurture__c = TRUE;
            leadList[0].Lead_Type__c = LeadsDAO.LEARNER_LEAD_TYPE;
            ContactsDAO.newInstance().insertRecords(conList, false, AccessLevel.SYSTEM_MODE);
            LeadsDAO.newInstance().insertRecords(leadList, false, AccessLevel.SYSTEM_MODE);
            
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Cadence_Name__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED;
            nurtureConfig.Lead_Score_Threshold__c = 3;
            nurtureConfig.Status__c = 'Active';
            nurtureList.add(nurtureConfig);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);
            
            Id contactID = ContactsDAO.newInstance().getPersonContactsWithLimit(1)[0].Id;
            Id leadID = LeadsDAO.newInstance().getLeadsWithLimit(1)[0].Id;
            Completed_cadence__c cadence1 = new Completed_Cadence__c();
            cadence1.Contact__c = contactID;
            cadence1.Nurture_Track_Configuration__c = nurtureList[0].Id;
            cadence1.Completed_Cadence_Status__c ='Successful';
            insert cadence1;
            
            Test.setCreatedDate(cadence1.Id, Datetime.now().addYears(-4));
            
            Completed_cadence__c cadence2 = new Completed_Cadence__c();
            cadence2.Lead__c = leadID;
            cadence2.Nurture_Track_Configuration__c = nurtureList[0].Id;
            cadence2.Completed_Cadence_Status__c ='Successful';
            insert cadence2;
            
            Test.setCreatedDate(cadence2.Id, Datetime.now().addYears(-4));
            
            List<hed__Application__c> appList = new List<hed__Application__c>();
            hed__Application__c appLead = new hed__Application__c();
            appLead.Lead__c = leadID;
            appLead.Application_Status__c = ApplicationsDAO.STATUS_SUBMITTED;
            appLead.RecordTypeId = ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            appList.add(appLead);
            
            hed__Application__c appContact = new hed__Application__c();
            appContact.hed__Applicant__c = contactID;
            appContact.Application_Status__c = ApplicationsDAO.STATUS_SUBMITTED;
            appContact.RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            appList.add(appContact);
            
            ApplicationsDAO.newInstance().insertRecords(appList, false, AccessLevel.SYSTEM_MODE);
        }
        
        Test.startTest();
        // call method
        LeadSourceCanNurtureFlagBatch batchable = new LeadSourceCanNurtureFlagBatch();
        Id batchableId = Database.executeBatch(batchable);
        Test.stopTest();
        // assert
        System.assert(
            batchableId != null,
            'The batch job failed to execute.'
        );
        
        List<Lead> leadList = [SELECT Id,Can_Nurture__c FROM Lead WHERE Lead_Source_Category__c =: LeadsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCED];
        List<Contact> contactList = [SELECT Id,Can_Nurture__c FROM Contact WHERE Lead_Source_Category__c =: LeadsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCED];
        System.assert(leadList[0].Can_Nurture__c,'Lead can_nurture updated to false');
        System.assert(contactList[0].Can_Nurture__c,'Contact can_nurture updated to false');
    }
    
    // Test method for exception handling
    @isTest
    static void testExceptionHandling() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            // Call the batch class execute method
            LeadSourceCanNurtureFlagBatch batchable = new LeadSourceCanNurtureFlagBatch();
            batchable.execute(null,null);
            Test.stopTest();
        }       
        //Perform assertions that the batch didn't execute
        System.assert([SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'LeadSourceCanNurtureFlagBatch'].isEmpty() , 'LeadSourceCanNurtureFlagBatch Job is not empty');
    }

    
    private static List<Lead> createTestLeadRecords(Integer startAtCount, Integer endBeforeCount) {
        List<Lead> newLeads = new List<Lead>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newLeads.add(
                new Lead(
                    FirstName = FIRSTNAME,
                    LastName = LASTNAME + i,
                    Email = i + EMAIL,
                    Can_Nurture__c = TRUE,
                    Work_Email__c = 'work' + i + EMAIL,
                    Company = 'Learner' + i
                )
            );
        }
        return newLeads;
    }
}