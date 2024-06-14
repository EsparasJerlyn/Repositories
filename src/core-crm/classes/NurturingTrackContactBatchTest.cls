/**
 * @description Batch class to NurturingTrackContactBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                  |
      |--------------------------------|-----------------------|------------------------|---------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6105              | Created file                    |
      | mark.j.mahilum                 | Sept 08, 2023         | DEPP-6479              | Added method to cover exception |
 */
@isTest
public with sharing class NurturingTrackContactBatchTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
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
            nurtureConfig.Cadence_Name__c = 'International Application Submission - Direct Applicant (Automated)';
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
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            // create applied intake term
            List<Account> accountList = AccountsDAO.newInstance()
                .getAccountsBySetNames(new Set<String>{'Test Account'});
            hed__Term__c appliedIntakeTerm = new hed__Term__c(
                hed__Start_Date__c = Date.today().addMonths(4),
                hed__Account__c = accountList[0].Id
            );
            insert appliedIntakeTerm;
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            newApplications[0].Applied_Intake_Study_Period__c = appliedIntakeTerm.Id;
            newApplications[0].Is_Agent_Assisted__c = false;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
        }

        // call method
        NurturingTrackContactBatch batchable = new NurturingTrackContactBatch();
        Id batchableId = Database.executeBatch(batchable);
        Test.stopTest();
        // assert
        System.assert(
            batchableId != null,
            'The batch job failed to execute.'
        );
        
    }

    // Test method for exception handling
    @isTest
    static void testExceptionHandling() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            // Call the batch class execute method
            NurturingTrackContactBatch batchable = new NurturingTrackContactBatch();
            batchable.execute(null,null);
            Test.stopTest();
        }
        //Perform assertions that the batch didn't execute
        System.assert([SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'NurturingTrackContactBatch'].isEmpty() , 'NurturingTrackContactBatch Job is not empty');
    }
    
    private static List<hed__Application__c> createTestApplicationRecords(List<Contact> conList, String recordType, String applicationStatus) {
        List<hed__Application__c> newApplications = new List<hed__Application__c>();
        for (Contact con: conList) {
            newApplications.add(
                new hed__Application__c(
                    FirstName__c = FIRSTNAME,
                    LastName__c = LASTNAME,
                    BirthDate__c = Date.valueOf(BIRTHDAY),
                    Email__c = 'work' + EMAIL,
                    Application_Status__c = applicationStatus,
                    hed__Applicant__c = con.Id,
                    RecordTypeId = recordType
                )
            );
        }
        return newApplications;
    }
    
    private static List<Contact> createTestContactRecords(
        Integer startAtCount,
        Integer endBeforeCount
    ) {
        List<Contact> newContacts = new List<Contact>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newContacts.add(
                new Contact(
                    FirstName = FIRSTNAME + i,
                    LastName = i + LASTNAME,
                    BirthDate = Date.valueOf(BIRTHDAY),
                    Email = i + EMAIL,
                    Can_Nurture__c = TRUE,
                    QUT_Learner_Email__c = 'learner' + i + EMAIL,
                    QUT_Staff_Email__c = 'staff' + i + EMAIL,
                    Work_Email__c = 'work' + i + EMAIL,
                    hed__Preferred_Email__c = 'Alternate Email',
                    hed__AlternateEmail__c = i + EMAIL,
                    RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID 
                )
            );
        }
        return newContacts;
    }

    private static List<Nurture_Track_Configuration__c> createCensusCadence(String name, String criteriaType, Integer keyDateOffSet){
        
        List<Nurture_Track_Configuration__c> initialNurtureTrackConfigList = TestDataFactory.createNurtureTrackConfigRecords(1);
        
        List<Nurture_Track_Configuration__c> nurtureTrackConfigList = new List<Nurture_Track_Configuration__c>();
        for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureTrackConfigList){
            nurtureTrackConfigList.add(
                new Nurture_Track_Configuration__c(
                    Id = nurtureTrackConfig.Id,
                    Cadence_Name__c = name,
                    Status__c = 'Active',
                    Criteria_Type__c = criteriaType,
                    Key_Date_Offset_Days__c = keyDateOffSet
                )
            );
        }
        
        return nurtureTrackConfigList;
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