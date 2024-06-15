/**
 * @description Batch class to NurturingTrackLeadBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6105              | Created file                                  |
      | mark.j.mahilum                 | Sept 08, 2023         | DEPP-6479              | Added test method to cover exception handling |
 */
@isTest
public with sharing class NurturingTrackLeadBatchTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {            
            List<Account> newAccounts = new List<Account>();
            newAccounts.add(TestDataFactory.createTestAccount(false));
            newAccounts[0].RecordTypeId = AccountsDAO.ACCT_UNIV_DEP_ID;
            AccountsDAO.newInstance().insertRecords(newAccounts, false, AccessLevel.SYSTEM_MODE);

            List<hed__Facility__c> newFacilities = new List<hed__Facility__c>();
            newFacilities.addAll(createTestFacilityRecords(newAccounts[0].Id));
            insert newFacilities;

            List<hed__Term__c> newTerms = new List<hed__Term__c>();
            newTerms.addAll(createTestIntakePeriodRecords(newFacilities[0].Id, newAccounts[0].Id));
            insert newTerms;
            
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Cadence_Name__c = 'TEST 1';
            nurtureConfig.Lead_Score_Threshold__c = 3;
            nurtureConfig.Status__c = 'Active';
            nurtureList.add(nurtureConfig);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);   
        }
    }

    @isTest
    private static void testAutomaticInternationalDirectApplicantEntry() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            // create marketing segmentation
            Marketing_Segmentation__c internationalMS = new Marketing_Segmentation__c(My_Citizenship_Status__c = 'International Student');
            insert internationalMS;
            // create lead
            List<Lead> newLeads = createTestLeadRecords(0, 1);
            newLeads[0].Marketing_Segmentation__c = internationalMS.Id;
            LeadsDAO.newInstance().insertRecords(newLeads, false, AccessLevel.SYSTEM_MODE);
            // SOQL the lead so it includes Marketing_Segmentation__r.My_Citizenship_Status__c
            newLeads[0] = [
                SELECT Id, Marketing_Segmentation__r.My_Citizenship_Status__c, 
                Can_Nurture__c, Calculated_Cadence__c 
                FROM Lead LIMIT 1];
            // create applied intake term
            List<Account> accountList = AccountsDAO.newInstance()
                .getAccountsBySetNames(new Set<String>{'Test Account'});
            hed__Term__c appliedIntakeTerm = new hed__Term__c(
                hed__Start_Date__c = Date.today().addMonths(4),
                hed__Account__c = accountList[0].Id
            );
            insert appliedIntakeTerm;
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newLeads, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            newApplications[0].Applied_Intake_Study_Period__c = appliedIntakeTerm.Id;
            newApplications[0].Is_Agent_Assisted__c = false;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
        }
    
        // call method
        NurturingTrackLeadBatch batchable = new NurturingTrackLeadBatch();
        Id batchableId = Database.executeBatch(batchable);
        Test.stopTest();
        // assert
        System.assert(
            batchableId != null,
            'The batch job failed to execute.'
        );
    }

    @isTest
    private static void testManualInternationalDirectApplicantEntry() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create marketing segmentation
            Marketing_Segmentation__c internationalMS = new Marketing_Segmentation__c(My_Citizenship_Status__c = 'International Student');
            insert internationalMS;
            // create lead
            List<Lead> newLeads = createTestLeadRecords(0, 1);
            newLeads[0].Marketing_Segmentation__c = internationalMS.Id;
            LeadsDAO.newInstance().insertRecords(newLeads, false, AccessLevel.SYSTEM_MODE);
            // SOQL the lead so it includes Marketing_Segmentation__r.My_Citizenship_Status__c
            newLeads[0] = [
                SELECT Id, Marketing_Segmentation__r.My_Citizenship_Status__c, 
                Can_Nurture__c, Calculated_Cadence__c 
                FROM Lead LIMIT 1];
            // create applied intake term
            List<Account> accountList = AccountsDAO.newInstance()
                .getAccountsBySetNames(new Set<String>{'Test Account'});
            hed__Term__c appliedIntakeTerm = new hed__Term__c(
                hed__Start_Date__c = Date.today().addMonths(4),
                hed__Account__c = accountList[0].Id
            );
            insert appliedIntakeTerm;
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newLeads, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            newApplications[0].Applied_Intake_Study_Period__c = appliedIntakeTerm.Id;
            newApplications[0].Is_Agent_Assisted__c = false;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // call method
            NurturingTrackLeadBatch batchable = new NurturingTrackLeadBatch();
            Id batchableId = Database.executeBatch(batchable);
            Test.stopTest();
            // assert
            System.assert(
                batchableId != null,
                'The batch job failed to execute.'
            );
        }
    }

    // Test method for exception handling
    @isTest
    static void testExceptionHandling() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            // Call the batch class execute method
            NurturingTrackLeadBatch batchable = new NurturingTrackLeadBatch();
            batchable.execute(null,null);
            Test.stopTest();
        }       
        //Perform assertions that the batch didn't execute
        System.assert([SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'NurturingTrackLeadBatch'].isEmpty() , 'NurturingTrackLeadBatch Job is not empty');
    }
    
    private static List<hed__Application__c> createTestApplicationRecords(List<Lead> leadList, String recordType, String applicationStatus) {
        List<hed__Application__c> newApplications = new List<hed__Application__c>();
        for (Lead ld: leadList) {
            newApplications.add(
                new hed__Application__c(
                    FirstName__c = FIRSTNAME,
                    LastName__c = LASTNAME,
                    BirthDate__c = Date.valueOf(BIRTHDAY),
                    Email__c = 'work' + EMAIL,
                    Application_Status__c = applicationStatus,
                    Lead__c = ld.Id,
                    RecordTypeId = recordType
                )
            );
        }
        return newApplications;
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

    /**
     * @description This method creates facility records. Refer to the confluence below for
     * a list of expect facility values/records.
     * https://qut.atlassian.net/wiki/spaces/DEP/pages/162136930/hed+Facility+c
     * AVOID ADDING FACILITIES THAT ARE NOT GOING TO BE USED.
     * Add what you need only.
     */
    private static List<hed__Facility__c> createTestFacilityRecords(Id qutAccountId) {
        List<hed__Facility__c> facilities = new List<hed__Facility__c>();
        // UNIVERSITY WIDE
        facilities.add(new hed__Facility__c(Name = 'U', hed__Account__c = qutAccountId));
        return facilities;
    }

    private static List<hed__Term__c> createTestIntakePeriodRecords(Id uniWideFacilityId, Id accountId) {
        List<hed__Term__c> intakePeriods = new List<hed__Term__c>();
        intakePeriods.add(new hed__Term__c(
            Name = 'Previous Intake Period',
            Location__c = uniWideFacilityId,
            hed__Account__c = accountId,
            hed__Start_Date__c = Date.today().toStartOfMonth(),
            hed__End_Date__c = Date.today().toStartOfMonth().addDays(-1).addMonths(3),
            Study_Period_Type_Code__c = 'SUM'
        ));
        intakePeriods.add(new hed__Term__c(
            Name = 'Current Intake Period',
            Location__c = uniWideFacilityId,
            hed__Account__c = accountId,
            hed__Start_Date__c = Date.today().toStartOfMonth().addMonths(4),
            hed__End_Date__c = Date.today().toStartOfMonth().addDays(-1).addMonths(7),
            Study_Period_Type_Code__c = 'SEM-1'
        ));
        return intakePeriods;
    }
}