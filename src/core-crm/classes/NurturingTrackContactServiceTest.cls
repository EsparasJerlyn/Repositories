/**
 * @description Batch class to NurturingTrackContactService
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum       	       | July 25, 2023         | DEPP-6105              | Created file                 | 
 */
@isTest
public with sharing class NurturingTrackContactServiceTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
        System.runAs(TestDataFactory.getProgramAdminUser()) {   
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
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
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
            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            // assert
            System.assertEquals(
                'International Application Submission - Direct Applicant (Automated)',
                processContacts[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }
    
    @isTest
    private static void testManualInternationalDirectApplicantEntry() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
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
            // create completed cadence
            Completed_Cadence__c completedCadence = new Completed_Cadence__c(
                Application__c = newApplications[0].Id,
                Contact__c = newContacts[0].Id,
                Nurture_Track_Configuration__c = [SELECT Id FROM Nurture_Track_Configuration__c LIMIT 1].Id
            );
            insert completedCadence;
            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            // assert
            System.assertEquals(
                'International Application Submission - Direct Applicant',
                processContacts[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void testInternationalAcceptanceDepositNotPaidEntry() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
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
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Acceptance - Pending Payment');
            newApplications[0].Applied_Intake_Study_Period__c = appliedIntakeTerm.Id;
            newApplications[0].Is_Agent_Assisted__c = false;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            // assert
            System.assertEquals(
                'International Acceptance Deposit not Paid',
                processContacts[0].Calculated_Cadence__c,
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void testAutomatedDomesticFirstOffertoAcceptanceEntry() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
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
            newApplications[0].RecordTypeId = ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            newApplications[0].Offer_Status__c = 'Offer';
            newApplications[0].hed__Application_Date__c = Date.today().addMonths(4);
            newApplications[0].Offer_Start_Date__c = Date.today().addDays(3);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            // assert
            System.assertEquals(
                'Domestic First Offer to Acceptance (Automated)',
                processContacts[0].Calculated_Cadence__c,
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void testManualDomesticFirstOffertoAcceptanceEntryHasCompleteCadence() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
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
            newApplications[0].RecordTypeId = ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            newApplications[0].Offer_Status__c = 'Offer';
            newApplications[0].hed__Application_Date__c = Date.today().addMonths(4);
            newApplications[0].Offer_Start_Date__c = Date.today().addDays(2);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplicationsSecond = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            newApplicationsSecond[0].RecordTypeId = ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            newApplicationsSecond[0].Offer_Status__c = 'Offer';
            newApplicationsSecond[0].hed__Application_Date__c = Date.today().addMonths(3);
            newApplicationsSecond[0].Offer_Start_Date__c = Date.today().addDays(3);
            ApplicationsDAO.newInstance().insertRecords(newApplicationsSecond, false, AccessLevel.SYSTEM_MODE);

            // Create Nurture Track Configuration
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Cadence_Name__c = 'Domestic First Offer to Acceptance (Automated)';
            nurtureList.add(nurtureConfig);

            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);

            // create completed cadence
             Completed_Cadence__c completedCadence = new Completed_Cadence__c(
                Application__c = newApplications[0].Id,
                Contact__c = newContacts[0].Id,
                Nurture_Track_Configuration__c = nurtureList[0].Id
            );
            insert completedCadence;

            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            // assert
            System.assertEquals(
                'Domestic First Offer to Acceptance',
                processContacts[0].Calculated_Cadence__c,
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void testMultipleRecordsNoCompleteCadenceDomesticFirstOffertoAcceptanceEntry() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
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
            List<hed__Application__c> newApplicationsOne = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            newApplicationsOne[0].RecordTypeId = ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            newApplicationsOne[0].Offer_Status__c = 'Offer';
            newApplicationsOne[0].hed__Application_Date__c = Date.today().addMonths(1);
            newApplicationsOne[0].Offer_Start_Date__c = Date.today().addDays(-1);
            ApplicationsDAO.newInstance().insertRecords(newApplicationsOne, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplicationsTwo = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            newApplicationsTwo[0].RecordTypeId = ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            newApplicationsTwo[0].Offer_Status__c = 'Offer';
            newApplicationsTwo[0].hed__Application_Date__c = Date.today().addMonths(2);
            newApplicationsTwo[0].Offer_Start_Date__c = Date.today().addDays(3);
            ApplicationsDAO.newInstance().insertRecords(newApplicationsTwo, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplicationsThree = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            newApplicationsThree[0].RecordTypeId = ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            newApplicationsThree[0].Offer_Status__c = 'Offer';
            newApplicationsThree[0].hed__Application_Date__c = Date.today().addMonths(3);
            newApplicationsThree[0].Offer_Start_Date__c = Date.today().addDays(1);
            ApplicationsDAO.newInstance().insertRecords(newApplicationsThree, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplicationsFour = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            newApplicationsFour[0].RecordTypeId = ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            newApplicationsFour[0].Offer_Status__c = 'Offer';
            newApplicationsFour[0].hed__Application_Date__c = Date.today().addMonths(4);
            newApplicationsFour[0].Offer_Start_Date__c = Date.today().addDays(2);
            ApplicationsDAO.newInstance().insertRecords(newApplicationsFour, false, AccessLevel.SYSTEM_MODE);

            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            // assert
            System.assertEquals(
                'Domestic First Offer to Acceptance (Automated)',
                processContacts[0].Calculated_Cadence__c,
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void testInternationalAcceptanceDepositNotPaidExit() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            newContacts[0].Calculated_Cadence__c = 'International Acceptance Deposit not Paid';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            // create applied intake term
            List<Account> accountList = AccountsDAO.newInstance()
                .getAccountsBySetNames(new Set<String>{'Test Account'});
            hed__Term__c appliedIntakeTerm = new hed__Term__c(
                hed__Start_Date__c = Date.today().addMonths(4),
                hed__Account__c = accountList[0].Id
            );
            insert appliedIntakeTerm;
            // create application0
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Accepted');
            newApplications[0].Applied_Intake_Study_Period__c = appliedIntakeTerm.Id;
            newApplications[0].Is_Agent_Assisted__c = false;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            // assert
            System.assertEquals(
                '',
                processContacts[0].Calculated_Cadence__c,
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void testAutomaticInternationalDirectApplicantExit() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            newContacts[0].Calculated_Cadence__c = 'International Application Submission - Direct Applicant (Automated)';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            // create applied intake term
            List<Account> accountList = AccountsDAO.newInstance()
                .getAccountsBySetNames(new Set<String>{'Test Account'});
            hed__Term__c appliedIntakeTerm = new hed__Term__c(
                hed__Start_Date__c = Date.today().addMonths(4),
                hed__Account__c = accountList[0].Id
            );
            insert appliedIntakeTerm;
            // create application0
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Submitted');
            newApplications[0].Applied_Intake_Study_Period__c = appliedIntakeTerm.Id;
            newApplications[0].Is_Agent_Assisted__c = false;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            // assert
            System.assertEquals(
                '', processContacts[0].Calculated_Cadence__c, 'Error, wrong calculated cadence value.'
            );
        }
    }
    
    @isTest
    private static void testManualInternationalDirectApplicantExit() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            newContacts[0].Calculated_Cadence__c = 'International Application Submission - Direct Applicant (Automated)';
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
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Submitted');
            newApplications[0].Applied_Intake_Study_Period__c = appliedIntakeTerm.Id;
            newApplications[0].Is_Agent_Assisted__c = false;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // create completed cadence
            Completed_Cadence__c completedCadence = new Completed_Cadence__c(
                Application__c = newApplications[0].Id,
                Nurture_Track_Configuration__c = [SELECT Id FROM Nurture_Track_Configuration__c LIMIT 1].Id
            );
            insert completedCadence;
            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            // assert
            System.assertEquals(
                '', processContacts[0].Calculated_Cadence__c, 'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void getDomesticAcceptanceToEnrollmentForEntryManualTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = '';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Cadence_Name__c = 'Domestic Acceptance to Enrolment';
            nurtureConfig.Lead_Score_Threshold__c = 3;
            nurtureConfig.Status__c = 'Active';
            nurtureConfig.Criteria_Type__c = 'Entry';
            nurtureConfig.Key_Date_Offset_Days__c = 10;
            nurtureList.add(nurtureConfig);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);   

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today();
            insert programList;

            List<hed__Application__c> newQtacApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.QTAC_RECTYPE_ID, 'New');
            newQtacApplications[0].Offer_Status__c = 'Accepted unconditionally';
            ApplicationsDAO.newInstance().insertRecords(newQtacApplications, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].QTAC_ApplicantID__c = newQtacApplications[0].Id;
            newApplications[0].Offered_Program_Plan__c = programList[0].Id;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('Domestic Acceptance to Enrolment', processContacts[0].Calculated_Cadence__c, 'Calculated calculated should be populated');
        }
    }

    @isTest
    private static void getDomesticAcceptanceToEnrollmentForEntryAutomatedTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = '';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newQtacApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.QTAC_RECTYPE_ID, 'New');
            newQtacApplications[0].Offer_Status__c = 'Accepted unconditionally';
            ApplicationsDAO.newInstance().insertRecords(newQtacApplications, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].QTAC_ApplicantID__c = newQtacApplications[0].Id;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('Domestic Acceptance to Enrolment (Automated)', processContacts[0].Calculated_Cadence__c, 'Calculated calculated should be populated');
        }

    }

    @isTest
    private static void getDomesticAcceptanceToEnrollmentForExitAutomatedTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = 'Domestic Acceptance to Enrolment (Automated)';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);   

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today();
            insert programList;

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'Admitted');
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('', processContacts[0].Calculated_Cadence__c, 'Calculated calculated should not be populated');
        }

    }

    @isTest
    private static void getDomesticAcceptanceToEnrollmentForExitManualTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = 'Domestic Acceptance to Enrolment';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);   

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today();
            insert programList;

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'Admitted');
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('', processContacts[0].Calculated_Cadence__c, 'Calculated calculated should not be populated');
        }

    }

    @isTest
    private static void getDomesticDeferredOfferToAcceptanceForEntryTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = '';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today();
            insert programList;

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].Offered_Program_Plan__c = programList[0].Id;
            newApplications[0].Admission_Process__c = 'RTN_DEFER';
            newApplications[0].Offer_Status__c = 'Offered';
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('Domestic Deferred Offer to Acceptance', processContacts[0].Calculated_Cadence__c, 'Calculated calculated should be populated');
        }

    }

    @isTest
    private static void getDomesticDeferredOfferToAcceptanceForExitTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = 'Domestic Deferred Offer to Acceptance';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);   

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today();
            insert programList;

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].Offer_Status__c = 'Accepted';
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('', processContacts[0].Calculated_Cadence__c, 'Calculated calculated should not be populated');
        }

    }

    @isTest
    private static void testAutomatedDomesticFirstOffertoAcceptanceExit() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = 'Domestic First Offer to Acceptance (Automated)';
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
            newApplications[0].Offer_Status__c = 'Accepted';
            newApplications[0].RecordTypeId = ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            // assert
            System.assertEquals(
                '',
                processContacts[0].Calculated_Cadence__c,
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void testManualDomesticFirstOffertoAcceptanceExit() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = 'Domestic First Offer to Acceptance';
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
            newApplications[0].Offer_Status__c = 'Accepted';
            newApplications[0].RecordTypeId = ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            // assert
            System.assertEquals(
                '',
                processContacts[0].Calculated_Cadence__c,
                'Error, wrong calculated cadence value.'
            );
        }
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