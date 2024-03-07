/**
 * @description Batch class to LeadSourceCanNurtureFlagBatchTest
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | March 06, 2024        | DEPP-8069              | Created file                 |
      |                                |                       |                        |                              |
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

    // Test method for exception handling
    @isTest
    static void testExceptionHandling() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            // Call the batch class execute method
            NurturingTrackLeadBatch batchable = new NurturingTrackLeadBatch();
            batchable.execute(null,null);
            Test.stopTest();
        }       
        //Perform assertions that the batch didn't execute
        System.assert([SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'NurturingTrackLeadBatch'].isEmpty() , 'NurturingTrackLeadBatch Job is not empty');
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