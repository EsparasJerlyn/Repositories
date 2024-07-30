/**
 * @description Test class for NurturingTrackContactService.
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                            |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6105              | Created file                                                                              |
      | eccarius.munoz                 | August 08, 2023       | DEPP-5760              | Added handling for Domestic and                                                           |
      |                                |                       |                        | International Enrolment to Census                                                         |
      | mark.j.mahilum                 | Sept 07,2023          | DEPP-6479              | Updated test class to include Calculated Intake Date                                      |
      | mark.j.mahilum                 | Oct 04, 2023          | DEPP-6682              | Added test class coverage for getDomesticAccepted                                         | 
      | eccarius.munoz                 | January 22, 2024      | DEPP-7651              | Added new test method                                                                     |
      |                                |                       |                        | getExitInternationalStrongInterestPreApplicationTest                                      |
      | mark.j.mahilum                 | Feb 06, 2024          | DEPP-7862              | Added test class data DomesticAcceptanceToEnrollment                                      |    
      |                                |                       |                        | entry and exit method                                                                     |
      | arsenio.jr.dayrit              | Feb 27, 2024          | DEPP-8133              | Updated test class method  International Application Submission - Direct Applicant Exit   |
      | eccarius.munoz                 | Feb 29, 2024          | DEPP-7838              | Added test method for International Offer to Acceptance - Agent                           |
      | mark.j.mahilum                 | March 04, 2024        | DEPP-7708              | Added test method for International Pre Application Partner Sourced                       |
 */
@isTest
public with sharing class NurturingTrackContactServiceTest { //NOPMD
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        
        TestDataFactoryUser.generateUserQUTESB();
        
            Test.startTest();
            List<Account> newAccounts = new List<Account>();
            newAccounts.add(TestDataFactory.createTestAccount(false));
            newAccounts[0].RecordTypeId = AccountsDAO.ACCT_UNIV_DEP_ID;
            AccountsDAO.newInstance().insertRecords(newAccounts, false, AccessLevel.SYSTEM_MODE);

            List<hed__Facility__c> newFacilities = new List<hed__Facility__c>();
            newFacilities.addAll(createTestFacilityRecords(newAccounts[0].Id));
            FacilitiesDAO.newInstance().insertRecords(newFacilities, false, AccessLevel.SYSTEM_MODE);

            List<hed__Term__c> newTerms = new List<hed__Term__c>();
            newTerms.addAll(createTestIntakePeriodRecords(newFacilities[0].Id, newAccounts[0].Id));
            TermsDAO.newInstance().insertRecords(newTerms, false, AccessLevel.SYSTEM_MODE);

            List<Lead_Score_Configuration__c> leadScoreParentConfigList = new List<Lead_Score_Configuration__c>();
            leadScoreParentConfigList.add(
                new Lead_Score_Configuration__c(
                    Name = 'Total Max Score DUG',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG,
                    Domestic_International__c = 'Domestic',
                    Study_Level__c = 'Undetermined'
                )
            );

            LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreParentConfigList, true, AccessLevel.SYSTEM_MODE);

            List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

            leadScoreConfigList.add(
                new Lead_Score_Configuration__c(
                    Name = 'Enquiries',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                    Domestic_International__c = 'Domestic',
                    Study_Level__c = 'Undetermined',
                    Description__c = '',
                    Score_Allocation__c = null,
                    Time_Limit_Months__c = 10,
                    Max_Score__c = 200,
                    Parent_Category__c = leadScoreParentConfigList[0].Id
                )
            );

            LeadScoreConfigurationDAO.newInstance()
                .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

            List<Lead_Score_Configuration__c> leadScoreConfigChildList = new List<Lead_Score_Configuration__c>();
            leadScoreConfigChildList.addAll(TestDataFactory.createDomestcAndUndeterminedSubCategory(
                leadScoreConfigList[0].Id,
                new List<String>{
                    'Applying for a course'
                },
                new List<Integer>{ 200}
            ));

            LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreConfigChildList, true, AccessLevel.SYSTEM_MODE);

            // create contact
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(1,'Domestic');
            ContactsDAO.newInstance().insertRecords(newContacts, true, AccessLevel.SYSTEM_MODE);
            
            List<Nurture_Track_Configuration__c> initialNurtureList = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureList){
                nurtureList.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'International Application Submission - Direct Applicant (Automated)',
                        Lead_Score_Threshold__c = 3
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);     
            Test.stopTest();  
    }
    
    @isTest
    private static void testAutomaticInternationalDirectApplicantEntry() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4);
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
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // create completed cadence
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            completedCadenceList.add(new Completed_Cadence__c(
                Application__c = newApplications[0].Id,
                Contact__c = newContacts[0].Id,
                Nurture_Track_Configuration__c = [SELECT Id FROM Nurture_Track_Configuration__c LIMIT 1].Id,
                Completed_Cadence_Status__c ='Successful'
            ));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);
            
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
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            // create applied intake term
            List<Account> accountList = AccountsDAO.newInstance()
                .getAccountsBySetNames(new Set<String>{'Test Account'});

            List<hed__Term__c> newTerms  = new List<hed__Term__c>();
            newTerms.add(new hed__Term__c(
                hed__Start_Date__c = Date.today().addMonths(4),
                hed__Account__c = accountList[0].Id
            ));
            TermsDAO.newInstance().insertRecords(newTerms, false, AccessLevel.SYSTEM_MODE);
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Acceptance - Pending Payment');
            newApplications[0].Applied_Intake_Study_Period__c = newTerms[0].Id;
            newApplications[0].Is_Agent_Assisted__c = false;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4);
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

    // @isTest
    // private static void testAutomatedDomesticFirstOffertoAcceptanceEntry() {
    //     System.runAs(TestDataFactoryUser.selectUserQUTESB) {
    //         Test.startTest();
    //         // create contact
    //         List<Contact> newContacts = createTestContactRecords(0, 1);
    //         newContacts[0].hed__Citizenship_Status__c = 'Domestic';
    //         ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

    //         List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
    //         programList[0].Program_Level__c = 'Undergraduate';
    //         insert programList;

    //         List<hed__Program_Enrollment__c> programEnrollmentList = TestDataFactory.createTestProgramEnrollmentRecords(1);
    //         programEnrollmentList[0].hed__Contact__c = newContacts[0].Id;
    //         programEnrollmentList[0].Enrollment_Status__c = 'Passed';
    //         programEnrollmentList[0].Enrollment_Status_Date__c = System.today().addMonths(-13);
    //         insert programEnrollmentList;

    //         List<hed__Application__c> newQtacApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.QTAC_RECTYPE_ID, 'New');
    //         ApplicationsDAO.newInstance().insertRecords(newQtacApplications, false, AccessLevel.SYSTEM_MODE);

    //         // create application
    //         List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID, 'New');
    //         newApplications[0].Offer_Status__c = ApplicationsDAO.STATUS_OFFERED;
    //         newApplications[0].hed__Application_Date__c = Date.today().addMonths(4);
    //         newApplications[0].Offer_Status_Date__c = Date.today().addDays(1);
    //         newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
    //         newApplications[0].Offered_Program_Plan__c = programList[0].Id;
    //         newApplications[0].Related_QTAC_Application__c = newQtacApplications[0].Id;
    //         ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
    //         // call method
    //         List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
    //         Test.stopTest();
    //         // assert
    //         System.assertEquals(
    //             'Domestic First Offer to Acceptance (Automated)',
    //             processContacts[0].Calculated_Cadence__c,
    //             'Error, wrong calculated cadence value.'
    //         );
    //     }
    // }

    @isTest
    private static void testAutomatedInternationalOffertoAcceptanceEntry() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Unconditional Offer');
            newApplications[0].RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4);
            newApplications[0].Is_Agent_Assisted__c = false;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            // assert
            System.assertEquals(
                'International Offer to Acceptance - Direct (Automated)',
                processContacts[0].Calculated_Cadence__c,
                'Error, wrong calculated cadence value.'
            );
        }
    }
    
    @isTest
    private static void testManualInternationalOffertoAcceptanceEntryHasCompleteCadence() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            // Create Nurture Track Configuration
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Cadence_Name__c = 'International Offer to Acceptance - Direct';
            nurtureConfig.Lead_Score_Threshold__c = 3;
            nurtureConfig.Status__c = 'Active';
            nurtureConfig.Criteria_Type__c = 'Entry';
            nurtureConfig.Key_Date_Offset_Days__c = 10;
            nurtureList.add(nurtureConfig);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);   

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today();
            insert programList;
            
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Unconditional Offer');
            newApplications[0].RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            newApplications[0].Offered_Program_Plan__c = programList[0].Id;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4);
            newApplications[0].Offer_Status_Date__c = Date.today().addDays(-10);
            newApplications[0].Is_Agent_Assisted__c = false;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            
            // Create Nurture Track Configuration
            List<Nurture_Track_Configuration__c> nurtureListCon = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureTrackConfig = new Nurture_Track_Configuration__c();
            nurtureTrackConfig.Cadence_Name__c = 'International Offer to Acceptance - Direct (Automated)';
            nurtureListCon.add(nurtureTrackConfig);

            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureListCon, false, AccessLevel.SYSTEM_MODE);

            // create completed cadence
             Completed_Cadence__c completedCadence = new Completed_Cadence__c(
                Application__c = newApplications[0].Id,
                Contact__c = newContacts[0].Id,
                Nurture_Track_Configuration__c = nurtureListCon[0].Id,
                Completed_Cadence_Status__c ='Successful'
            );
            insert completedCadence;
			
            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            // assert
            System.assertEquals(
                'International Offer to Acceptance - Direct',
                processContacts[0].Calculated_Cadence__c,
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void testDomesticFirstOfferToAcceptanceManualEntryNoEnrollments() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            contacts[0].hed__Citizenship_Status__c = 'Domestic';
            contacts[0].Can_Nurture__c = true;
            ContactsDAO.newInstance().insertRecords(contacts, true, AccessLevel.SYSTEM_MODE);
            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(1);
            programPlans[0].Program_Level__c = 'Undergraduate';
            ProgramPlansDAO.newInstance().insertRecords(programPlans, true, AccessLevel.SYSTEM_MODE);
            List<hed__Application__c> qtacApps = createTestApplicationRecords(contacts, ApplicationsDAO.QTAC_RECTYPE_ID, 'New');
            ApplicationsDAO.newInstance().insertRecords(qtacApps, true, AccessLevel.SYSTEM_MODE);
            List<hed__Application__c> legacyApps = createTestApplicationRecords(contacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            legacyApps[0].Calculated_Intake_Date__c = Date.today().addMonths(12);
            legacyApps[0].hed__Application_Date__c = Date.today().addMonths(1);
            legacyApps[0].Admission_Process__c = 'RTN_TEST';
            legacyApps[0].Offered_Program_Plan__c = programPlans[0].Id;
            legacyApps[0].Offer_Status__c = ApplicationsDAO.STATUS_OFFERED;
            legacyApps[0].Related_QTAC_Application__c = qtacApps[0].Id;
            ApplicationsDAO.newInstance().insertRecords(legacyApps, true, AccessLevel.SYSTEM_MODE);
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(contacts));
            Test.stopTest();
            System.assert(!processContacts.isEmpty(), 'The contact was not evaluated.');
            System.assert(processContacts[0].Calculated_Cadence__c != '', 'The contact was evaluated but did not enter any cadence.');
            System.assert(
                processContacts[0].Calculated_Cadence__c == 'Domestic First Offer to Acceptance', 
                'The contact entered the wrong cadence, ' + processContacts[0].Calculated_Cadence__c
            );
        }
    }

    @isTest
    private static void testDomesticFirstOfferToAcceptanceManualEntryLegacy() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            contacts[0].hed__Citizenship_Status__c = 'Domestic';
            contacts[0].Can_Nurture__c = true;
            ContactsDAO.newInstance().insertRecords(contacts, true, AccessLevel.SYSTEM_MODE);
            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(1);
            programPlans[0].Program_Level__c = 'Undergraduate';
            ProgramPlansDAO.newInstance().insertRecords(programPlans, true, AccessLevel.SYSTEM_MODE);
            List<hed__Program_Enrollment__c> enrollments = TestDataFactory.createTestProgramEnrollmentRecords(2);
            enrollments[0].Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            enrollments[0].Enrollment_Status_Date__c = Date.today().addMonths(-1);
            enrollments[1].Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_PASSED;
            enrollments[1].Enrollment_Status_Date__c = Date.today().addMonths(-15);
            ProgramEnrollmentsDAO.newInstance().insertRecords(enrollments, true, AccessLevel.SYSTEM_MODE);
            List<hed__Application__c> qtacApps = createTestApplicationRecords(contacts, ApplicationsDAO.QTAC_RECTYPE_ID, 'New');
            ApplicationsDAO.newInstance().insertRecords(qtacApps, true, AccessLevel.SYSTEM_MODE);
            List<hed__Application__c> legacyApps = createTestApplicationRecords(contacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            legacyApps[0].Calculated_Intake_Date__c = Date.today().addMonths(12);
            legacyApps[0].hed__Application_Date__c = Date.today().addMonths(1);
            legacyApps[0].Admission_Process__c = 'RTN_TEST';
            legacyApps[0].Offered_Program_Plan__c = programPlans[0].Id;
            legacyApps[0].Offer_Status__c = ApplicationsDAO.STATUS_OFFERED;
            legacyApps[0].Related_QTAC_Application__c = qtacApps[0].Id;
            legacyApps[0].Program_Enrollment__c = enrollments[0].Id;
            List<hed__Application__c> legacyAppsOld = createTestApplicationRecords(contacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, '');
            legacyAppsOld[0].Calculated_Intake_Date__c = Date.today().addMonths(6);
            legacyAppsOld[0].Application_Status__c = '';
            legacyAppsOld[0].Program_Enrollment__c = enrollments[1].Id;
            legacyApps.addAll(legacyAppsOld);
            ApplicationsDAO.newInstance().insertRecords(legacyApps, true, AccessLevel.SYSTEM_MODE);
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(contacts));
            Test.stopTest();
            System.assert(!processContacts.isEmpty(), 'The contact was not evaluated.');
            System.assert(!processContacts.isEmpty(), 'The contact was not evaluated.');
            System.assert(processContacts[0].Calculated_Cadence__c != '', 'The contact was evaluated but did not enter any cadence.');
            System.assert(
                processContacts[0].Calculated_Cadence__c == 'Domestic First Offer to Acceptance', 
                'The contact entered the wrong cadence, ' + processContacts[0].Calculated_Cadence__c
            );
        }
    }
    // @isTest
    // private static void testManualDomesticFirstOffertoAcceptanceEntryHasCompleteCadence() {
    //     System.runAs(TestDataFactoryUser.selectUserQUTESB) {
    //         Test.startTest();
    //         // create contact
    //         List<Contact> newContacts = createTestContactRecords(0, 1);
    //         newContacts[0].hed__Citizenship_Status__c = 'Domestic';
    //         ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
        
    //         List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
    //         programList[0].Program_Level__c = 'Undergraduate';
    //         insert programList;

    //         List<hed__Program_Enrollment__c> programEnrollmentList = TestDataFactory.createTestProgramEnrollmentRecords(1);
    //         programEnrollmentList[0].hed__Contact__c = newContacts[0].Id;
    //         programEnrollmentList[0].Enrollment_Status__c = 'Passed';
    //         programEnrollmentList[0].Enrollment_Status_Date__c = System.today().addMonths(-13);
    //         insert programEnrollmentList;

    //         List<hed__Application__c> newQtacApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.QTAC_RECTYPE_ID, 'New');
    //         newQtacApplications[0].Offer_Status__c = 'Accepted';
    //         ApplicationsDAO.newInstance().insertRecords(newQtacApplications, false, AccessLevel.SYSTEM_MODE);

    //         // create application
    //         List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID, 'New');
    //         newApplications[0].Offer_Status__c = ApplicationsDAO.STATUS_OFFERED;
    //         newApplications[0].hed__Application_Date__c = Date.today().addMonths(4);
    //         newApplications[0].Offer_Status_Date__c = Date.today().addDays(2);
    //         newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4);
    //         newApplications[0].Offered_Program_Plan__c = programList[0].Id;
    //         newApplications[0].Related_QTAC_Application__c = newQtacApplications[0].Id;

    //         List<hed__Application__c> newApplicationsSecond = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID, 'New');
    //         newApplicationsSecond[0].Offer_Status__c = ApplicationsDAO.STATUS_OFFERED;
    //         newApplicationsSecond[0].hed__Application_Date__c = Date.today().addMonths(3);
    //         newApplicationsSecond[0].Offer_Status_Date__c = Date.today().addDays(3);
    //         newApplicationsSecond[0].Calculated_Intake_Date__c = Date.today().addMonths(4);
    //         newApplicationsSecond[0].Offered_Program_Plan__c = programList[0].Id;
    //         newApplicationsSecond[0].Related_QTAC_Application__c = newQtacApplications[0].Id;
    //         newApplications.addAll(newApplicationsSecond);
            
    //         Test.stopTest();
    //         ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

    //         // Create Nurture Track Configuration
    //         // List<Nurture_Track_Configuration__c> initialNurtureList = TestDataFactory.createNurtureTrackConfigRecords(1);
    //         // List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
    //         // for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureList){
    //         //     nurtureList.add(
    //         //         new Nurture_Track_Configuration__c(
    //         //             Id = nurtureTrackConfig.Id,
    //         //             Cadence_Name__c = 'Domestic First Offer to Acceptance (Automated)'
    //         //         )
    //         //     );
    //         // }

    //         // NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE); 

    //         // // create completed cadence
    //         // List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
    //         // completedCadenceList.add(new Completed_Cadence__c(
    //         //     Application__c = newApplications[0].Id,
    //         //     Contact__c = newContacts[0].Id,
    //         //     Nurture_Track_Configuration__c = nurtureList[0].Id,
    //         //     Completed_Cadence_Status__c ='Successful'
    //         // ));
    //         // CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);
    //         // call method
    //         List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
    //         // assert
    //         System.assertEquals(
    //             'Domestic First Offer to Acceptance',
    //             processContacts[0].Calculated_Cadence__c,
    //             'Error, wrong calculated cadence value.'
    //         );
    //     }
    // }

    // @isTest
    // private static void testMultipleRecordsNoCompleteCadenceDomesticFirstOffertoAcceptanceEntry() {
    //     System.runAs(TestDataFactoryUser.selectUserQUTESB) {
    //         Test.startTest();
    //         // create contact
    //         List<Contact> newContacts = createTestContactRecords(0, 1);
    //         newContacts[0].hed__Citizenship_Status__c = 'Domestic';
    //         ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
    //         List<hed__Application__c> applicationsToInsert = new List<hed__Application__c>();

    //         List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
    //         programList[0].Program_Level__c = 'Undergraduate';
    //         insert programList;

    //         List<hed__Program_Enrollment__c> programEnrollmentList = TestDataFactory.createTestProgramEnrollmentRecords(1);
    //         programEnrollmentList[0].hed__Contact__c = newContacts[0].Id;
    //         programEnrollmentList[0].Enrollment_Status__c = 'Passed';
    //         programEnrollmentList[0].Enrollment_Status_Date__c = System.today().addMonths(-13);
    //         insert programEnrollmentList;

    //         List<hed__Application__c> newQtacApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.QTAC_RECTYPE_ID, 'New');
    //         newQtacApplications[0].Offer_Status__c = 'Accepted';
    //         ApplicationsDAO.newInstance().insertRecords(newQtacApplications, false, AccessLevel.SYSTEM_MODE);

    //         // create application
    //         List<hed__Application__c> newApplicationsOne = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID, 'New');
    //         newApplicationsOne[0].Offer_Status__c = ApplicationsDAO.STATUS_OFFERED;
    //         newApplicationsOne[0].hed__Application_Date__c = Date.today().addMonths(1);
    //         newApplicationsOne[0].Offer_Status_Date__c = Date.today().addDays(-1);
    //         newApplicationsOne[0].Calculated_Intake_Date__c = Date.today().addMonths(4);
    //         newApplicationsOne[0].Offered_Program_Plan__c = programList[0].Id;
    //         newApplicationsOne[0].Related_QTAC_Application__c = newQtacApplications[0].Id;
    //         applicationsToInsert.addAll(newApplicationsOne);

    //         List<hed__Application__c> newApplicationsTwo = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID, 'New');
    //         newApplicationsTwo[0].Offer_Status__c = ApplicationsDAO.STATUS_OFFERED;
    //         newApplicationsTwo[0].hed__Application_Date__c = Date.today().addMonths(2);
    //         newApplicationsTwo[0].Offer_Status_Date__c = Date.today().addDays(3);
    //         newApplicationsTwo[0].Calculated_Intake_Date__c = Date.today().addMonths(4);
    //         newApplicationsTwo[0].Offered_Program_Plan__c = programList[0].Id;
    //         newApplicationsTwo[0].Related_QTAC_Application__c = newQtacApplications[0].Id;
    //         applicationsToInsert.addAll(newApplicationsTwo);
            
    //         List<hed__Application__c> newApplicationsThree = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID, 'New');
    //         newApplicationsThree[0].Offer_Status__c = ApplicationsDAO.STATUS_OFFERED;
    //         newApplicationsThree[0].hed__Application_Date__c = Date.today().addMonths(3);
    //         newApplicationsThree[0].Offer_Status_Date__c = Date.today().addDays(1);
    //         newApplicationsThree[0].Calculated_Intake_Date__c = Date.today().addMonths(4);
    //         newApplicationsThree[0].Offered_Program_Plan__c = programList[0].Id;
    //         newApplicationsThree[0].Related_QTAC_Application__c = newQtacApplications[0].Id;
    //         applicationsToInsert.addAll(newApplicationsThree);

    //         List<hed__Application__c> newApplicationsFour = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID, 'New');
    //         newApplicationsFour[0].Offer_Status__c = ApplicationsDAO.STATUS_OFFERED;
    //         newApplicationsFour[0].hed__Application_Date__c = Date.today().addMonths(4);
    //         newApplicationsFour[0].Offer_Start_Date__c = Date.today().addDays(2);
    //         newApplicationsFour[0].Calculated_Intake_Date__c = Date.today().addMonths(4);
    //         newApplicationsFour[0].Offered_Program_Plan__c = programList[0].Id;
    //         newApplicationsFour[0].Related_QTAC_Application__c = newQtacApplications[0].Id;
    //         applicationsToInsert.addAll(newApplicationsFour);

    //         ApplicationsDAO.newInstance().insertRecords(applicationsToInsert, true, AccessLevel.SYSTEM_MODE);

    //         // call method
    //         List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
    //         Test.stopTest();
    //         // assert
    //         System.assertEquals(
    //             'Domestic First Offer to Acceptance (Automated)',
    //             processContacts[0].Calculated_Cadence__c,
    //             'Error, wrong calculated cadence value.'
    //         );
    //     }
    // }

    @isTest
    private static void testInternationalAcceptanceDepositNotPaidExit() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            newContacts[0].Calculated_Cadence__c = 'International Acceptance Deposit not Paid';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            // create applied intake term
            List<Account> accountList = AccountsDAO.newInstance().getAccountsBySetNames(new Set<String>{'Test Account'});
            
            List<hed__Term__c> newTerms  = new List<hed__Term__c>();
            newTerms.add(new hed__Term__c(
                hed__Start_Date__c = Date.today().addMonths(4),
                hed__Account__c = accountList[0].Id
            ));
            TermsDAO.newInstance().insertRecords(newTerms, false, AccessLevel.SYSTEM_MODE);
            
            
            // create application0
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Accepted');
            newApplications[0].Applied_Intake_Study_Period__c = newTerms[0].Id;
            newApplications[0].Is_Agent_Assisted__c = false;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4).addDays(1);
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
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            newContacts[0].Calculated_Cadence__c = 'International Application Submission - Direct Applicant (Automated)';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            // create application0
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Submitted');
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4).addDays(1);
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
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            newContacts[0].Calculated_Cadence__c = 'International Application Submission - Direct Applicant (Automated)';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
           
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Submitted');
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4).addDays(1);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // create completed cadence
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            completedCadenceList.add(new Completed_Cadence__c(
                Application__c = newApplications[0].Id,
                Nurture_Track_Configuration__c = [SELECT Id FROM Nurture_Track_Configuration__c LIMIT 1].Id
            ));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);
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
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = '';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            // Create Nurture Track Configuration
            List<Nurture_Track_Configuration__c> initialNurtureListAuto = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureListAuto = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureListAuto){
                nurtureListAuto.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'Domestic Accepted not yet Enrolled (Automated)',
                        Status__c = 'Active',
                        Criteria_Type__c = 'Entry',
                        Key_Date_Offset_Days__c = 10
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureListAuto, false, AccessLevel.SYSTEM_MODE); 

            List<Nurture_Track_Configuration__c> initialNurtureListManual = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureListManual = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureListManual){
                nurtureListManual.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'Domestic Accepted not yet Enrolled',
                        Status__c = 'Active',
                        Criteria_Type__c = 'Entry',
                        Key_Date_Offset_Days__c = 10
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureListManual, false, AccessLevel.SYSTEM_MODE); 

            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            completedCadenceList.add(new Completed_Cadence__c(
                Contact__c = newContacts[0].Id,
                Nurture_Track_Configuration__c = nurtureListAuto[0].Id,
                Completed_Cadence_Status__c ='Successful'
            ));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today();
            ProgramPlansDAO.newInstance().insertRecords(programList, false, AccessLevel.SYSTEM_MODE);
            
            List<hed__Program_Enrollment__c> programEnrollmentList = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentList[0].hed__Contact__c = newContacts[0].Id;
            programEnrollmentList[0].Enrollment_Status__c = 'New';
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newQtacApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.QTAC_RECTYPE_ID, 'New');
            newQtacApplications[0].Offer_Status__c = 'Accepted';
            ApplicationsDAO.newInstance().insertRecords(newQtacApplications, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].Program_Enrollment__c = programEnrollmentList[0].Id;
            newApplications[0].Related_QTAC_Application__c = newQtacApplications[0].Id;
            newApplications[0].Offered_Program_Plan__c = programList[0].Id;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('Domestic Accepted not yet Enrolled', processContacts[0].Calculated_Cadence__c, 'Calculated calculated should be populated');
        }
    }

    @isTest
    private static void getDomesticAcceptanceToEnrollmentForEntryAutomatedTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = '';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            List<hed__Program_Enrollment__c> programEnrollmentList = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentList[0].hed__Contact__c = newContacts[0].Id;
            programEnrollmentList[0].Enrollment_Status__c = 'New';
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newQtacApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.QTAC_RECTYPE_ID, 'New');
            newQtacApplications[0].Offer_Status__c = 'Accepted';
            ApplicationsDAO.newInstance().insertRecords(newQtacApplications, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].Related_QTAC_Application__c = newQtacApplications[0].Id;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            newApplications[0].Program_Enrollment__c = programEnrollmentList[0].Id;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('Domestic Accepted not yet Enrolled (Automated)', processContacts[0].Calculated_Cadence__c, 'Calculated calculated should be populated');
        }

    }

    @isTest
    private static void getDomesticAcceptanceToEnrollmentForExitAutomatedTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = 'Domestic Accepted not yet Enrolled (Automated)';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);   

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today();
            ProgramPlansDAO.newInstance().insertRecords(programList, false, AccessLevel.SYSTEM_MODE);
            
            List<hed__Program_Enrollment__c> programEnrollmentList = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentList[0].hed__Contact__c = newContacts[0].Id;
            programEnrollmentList[0].Enrollment_Status__c = 'Admitted';
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'Admitted');
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            newApplications[0].Program_Enrollment__c = programEnrollmentList[0].Id;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('', processContacts[0].Calculated_Cadence__c, 'Calculated calculated should not be populated');
        }

    }

    @isTest
    private static void getDomesticAcceptanceToEnrollmentForExitManualTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = 'Domestic Accepted not yet Enrolled';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);   

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today();
            ProgramPlansDAO.newInstance().insertRecords(programList, false, AccessLevel.SYSTEM_MODE);
            
            List<hed__Program_Enrollment__c> programEnrollmentList = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentList[0].hed__Contact__c = newContacts[0].Id;
            programEnrollmentList[0].Enrollment_Status__c = 'Admitted';
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'Admitted');
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            newApplications[0].Program_Enrollment__c = programEnrollmentList[0].Id;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('', processContacts[0].Calculated_Cadence__c, 'Calculated calculated should not be populated');
        }

    }

    @isTest
    private static void getDomesticDeferredOfferToAcceptanceForEntryTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            
            List<Nurture_Track_Configuration__c> initialNurtureList = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureList){
                nurtureList.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'Domestic Deferred Offer to Acceptance',
                        Key_Date_Offset_Days__c = 35,
                        Status__c = 'Active',
                        Criteria_Type__c = 'Entry'
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE); 

            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = '';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today();
            ProgramPlansDAO.newInstance().insertRecords(programList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].Offered_Program_Plan__c = programList[0].Id;
            newApplications[0].Admission_Process__c = 'RTN_DEFER';
            newApplications[0].Offer_Status__c = 'Offered';
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('Domestic Deferred Offer to Acceptance', processContacts[0].Calculated_Cadence__c, 'Calculated calculated should be populated');
        }

    }

    @isTest
    private static void getDomesticDeferredOfferToAcceptanceForExitTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = 'Domestic Deferred Offer to Acceptance';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);   

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today();
            ProgramPlansDAO.newInstance().insertRecords(programList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].Offer_Status__c = 'Accepted';
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('', processContacts[0].Calculated_Cadence__c, 'Calculated calculated should not be populated');
        }

    }

    @isTest
    private static void testAutomatedDomesticFirstOffertoAcceptanceExit() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = 'Domestic First Offer to Acceptance (Automated)';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID, 'New');
            newApplications[0].Offer_Status__c = 'Accepted';
            newApplications[0].RecordTypeId = ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
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
    private static void getDomesticAcceptedAndAdmittedExitTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = 'Domestic Accepted and Admitted';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID, 'New');
            newApplications[0].Offer_Status__c = 'Deferred';
            newApplications[0].RecordTypeId = ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
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
    private static void testAutomatedInternationalOffertoAcceptanceExit() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            newContacts[0].Calculated_Cadence__c = 'International Offer to Acceptance - Direct (Automated)';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Unconditional Offer');
            newApplications[0].Application_Status__c = 'Accepted';
            newApplications[0].RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
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
    private static void getInternationalOfferToAcceptanceAgentForEntryTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Unconditional Offer');
            newApplications[0].RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4);
            newApplications[0].Is_Agent_Assisted__c = true;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            // assert
            System.assertEquals(
                'International Offer to Acceptance - Agent (Automated)',
                processContacts[0].Calculated_Cadence__c,
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void getInternationalOfferToAcceptanceAgentForExitTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            newContacts[0].Calculated_Cadence__c = 'International Offer to Acceptance - Agent (Automated)';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Unconditional Offer');
            newApplications[0].Application_Status__c = 'Accepted';
            newApplications[0].RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
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
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = 'Domestic First Offer to Acceptance';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            // create applied intake term
            List<Account> accountList = AccountsDAO.newInstance().getAccountsBySetNames(new Set<String>{'Test Account'});
            
            List<hed__Term__c> newTerms  = new List<hed__Term__c>();
            newTerms.add(new hed__Term__c(
                hed__Start_Date__c = Date.today().addMonths(4),
                hed__Account__c = accountList[0].Id
            ));
            TermsDAO.newInstance().insertRecords(newTerms, false, AccessLevel.SYSTEM_MODE);
            
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID, 'New');
            newApplications[0].Offer_Status__c = 'Accepted';
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
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
    private static void testManualInternationalOffertoAcceptanceExit() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            newContacts[0].Calculated_Cadence__c = 'International Offer to Acceptance - Direct';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Unconditional Offer');
            newApplications[0].Application_Status__c = 'Accepted';
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
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
    private static void getDomesticEnrollmentToCensusForEntryTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Nurture_Track_Configuration__c> nurtureList = createCensusCadence('Domestic and International Enrolment to Census', 'Entry', 14);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);

            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today();
            ProgramPlansDAO.newInstance().insertRecords(programList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Enrollment__c> programEnrollmentList = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentList[0].hed__Contact__c = newContacts[0].Id;
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Course_Enrollment__c> courseEnrollmentList = new List<hed__Course_Enrollment__c>();
            courseEnrollmentList.add(new hed__Course_Enrollment__c(
                hed__Contact__c = newContacts[0].Id, 
                Enrollment_Status__c = 'Test',
                hed__Program_Enrollment__c = programEnrollmentList[0].Id
            )); 
            CourseConnectionsDAO.newInstance().insertRecords(courseEnrollmentList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].Offered_Program_Plan__c = programList[0].Id;
            newApplications[0].Program_Enrollment__c = programEnrollmentList[0].Id;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('Domestic and International Enrolment to Census', processContacts[0].Calculated_Cadence__c, 'Calculated cadence is empty.');
        }
    }

    @isTest
    private static void getDomesticEnrollmentToCensusForExitTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Nurture_Track_Configuration__c> nurtureList = createCensusCadence('Domestic and International Enrolment to Census', 'Exit', 14);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);

            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = 'Domestic and International Enrolment to Census';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today().addDays(-14);
            ProgramPlansDAO.newInstance().insertRecords(programList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].Offered_Program_Plan__c = programList[0].Id;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('', processContacts[0].Calculated_Cadence__c, 'Calculated calculated must be cleared.');
        }
    }

    @isTest
    private static void getEntryDomesticOfferLapsedAutomatedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            //Create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = '';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            //Create nurture track record for Key Date Offset Days
            List<Nurture_Track_Configuration__c> initialNurtureListAuto = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureListAutomated = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureListAuto){
                nurtureListAutomated.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'Domestic Offer Lapsed (Automated)',
                        Key_Date_Offset_Days__c = 3,
                        Status__c = 'Active',
                        Criteria_Type__c = 'Entry'
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureListAutomated, false, AccessLevel.SYSTEM_MODE); 
            
            //Create nurture track record for Key Date Offset Days != null
            List<Nurture_Track_Configuration__c> initialNurtureListManual = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureListManual = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureListManual){
                nurtureListManual.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'Domestic Offer Lapsed',
                        Key_Date_Offset_Days__c = 4,
                        Status__c = 'Active',
                        Criteria_Type__c = 'Entry'
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureListManual, false, AccessLevel.SYSTEM_MODE); 

            //Create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(
                newContacts,
                ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID,
                'New'
            );
            newApplications[0].Offer_Status__c = 'Lapsed';
            newApplications[0].Offer_Lapse_Date__c = System.today().addDays(-(Integer) nurtureListAutomated[0].Key_Date_Offset_Days__c);
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            ApplicationsDAO.newInstance()
                .insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(
                new Map<Id, Contact>(newContacts)
            );
            Test.stopTest();

            System.assertEquals(
                'Domestic Offer Lapsed (Automated)',
                processContacts[0].Calculated_Cadence__c,
                'Domestic Offer Lapsed (Automated): Entry criteria met'
            );
        }
    }

    @isTest
    private static void getEntryDomesticOfferLapsedManualTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            //Create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = '';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            //Create nurture track record for Key Date Offset Days
            List<Nurture_Track_Configuration__c> initialNurtureListManual = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureListManual = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureListManual){
                nurtureListManual.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'Domestic Offer Lapsed',
                        Key_Date_Offset_Days__c = 4,
                        Status__c = 'Active',
                        Criteria_Type__c = 'Entry'
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureListManual, false, AccessLevel.SYSTEM_MODE); 

            //Create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(
                newContacts,
                ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID,
                'New'
            );
            newApplications[0].Offer_Status__c = 'Lapsed';
            newApplications[0].Offer_Lapse_Date__c = System.today().addDays(-(Integer)nurtureListManual[0].Key_Date_Offset_Days__c);
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            ApplicationsDAO.newInstance()
                .insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            //Create nurture track record for Completed Cadence
            List<Nurture_Track_Configuration__c> initialNurtureListAuto = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureListAutomated = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureListAuto){
                nurtureListAutomated.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'Domestic Offer Lapsed (Automated)',
                        Key_Date_Offset_Days__c = 3,
                        Status__c = 'Active',
                        Criteria_Type__c = 'Entry'
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureListAutomated, false, AccessLevel.SYSTEM_MODE);
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            completedCadenceList.add(new Completed_Cadence__c(
                Application__c = newApplications[0].Id,
                Contact__c = newContacts[0].Id,
                Nurture_Track_Configuration__c = nurtureListAutomated[0].Id,
                Completed_Cadence_Status__c ='Successful'
            ));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(
                new Map<Id, Contact>(newContacts)
            );
            Test.stopTest();

            System.assertEquals(
                'Domestic Offer Lapsed',
                processContacts[0].Calculated_Cadence__c,
                'Domestic Offer Lapsed: Entry criteria met'
            );
        }
    }

    @isTest
    private static void getEntryInternationalApplicationToOfferTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            //Create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            newContacts[0].Calculated_Cadence__c = '';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            // create applied intake term
            List<Account> accountList = AccountsDAO.newInstance().getAccountsBySetNames(new Set<String>{'Test Account'});
            List<hed__Facility__c> newFacilities = new List<hed__Facility__c>();
            newFacilities.addAll(createTestFacilityRecords(accountList[0].Id));
            FacilitiesDAO.newInstance().insertRecords(newFacilities, false, AccessLevel.SYSTEM_MODE);
            List<hed__Term__c> newTerms  = new List<hed__Term__c>();
            hed__Term__c appliIntake = new hed__Term__c(
                hed__Start_Date__c = Date.today().addDays(2).addMonths(2),
                hed__Account__c = accountList[0].Id
            );
            newTerms.add(appliIntake);
            newTerms.add(new hed__Term__c(
                Name = 'Current Intake Period',
                Location__c = newFacilities[0].Id,
                hed__Account__c = accountList[0].Id,
                hed__Start_Date__c = Date.today().toStartOfMonth().addMonths(1),
                hed__End_Date__c = Date.today().toStartOfMonth().addDays(-1).addMonths(6),
                Study_Period_Type_Code__c = 'SEM-1'
            ));
            TermsDAO.newInstance().insertRecords(newTerms, false, AccessLevel.SYSTEM_MODE);

            //create program list
            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today().addDays(10);
            ProgramPlansDAO.newInstance().insertRecords(programList, false, AccessLevel.SYSTEM_MODE);

            //Create nurture track record for Key Date Offset Days
            List<Nurture_Track_Configuration__c> initialNurtureListManual = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureListManual = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureListManual){
                nurtureListManual.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'International Application to Offer',
                        Nurture_Track_Name__c = 'International Application to Offer',
                        Key_Date_Name__c = 'Class Start Date',
                        Date_Offset_Type__c = 'Before',
                        Key_Date_Offset_Days__c = 90,
                        Sequence_Number__c = 1,
                        Status__c = 'Active',
                        Criteria_Type__c = 'Entry'
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureListManual, false, AccessLevel.SYSTEM_MODE); 

            //Create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(
                newContacts,
                ApplicationsDAO.STUDYLINK_RECTYPE_ID,
                'New'
            );
            newApplications[0].Application_Status__c = 'Submitted';
            newApplications[0].Offer_Status__c = '';
            newApplications[0].Is_Agent_Assisted__c = false;
            newApplications[0].Applied_Intake_Study_Period__c = appliIntake.Id;
            newApplications[0].Offered_Program_Plan__c = programList[0].Id;
            newApplications[0].Calculated_Intake_Date__c = System.today().addDays(90);
            ApplicationsDAO.newInstance()
                .insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(
                new Map<Id, Contact>(newContacts)
            );
            Test.stopTest();

            System.assertEquals(
                'International Application to Offer',
                processContacts[0].Calculated_Cadence__c,
                'International Application to Offer: Entry criteria met'
            );
        }
    }

    @isTest
    private static void getInternationalEnrollmentToCensusForEntryTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            List<Nurture_Track_Configuration__c> nurtureList = createCensusCadence('Domestic and International Enrolment to Census', 'Entry', 14);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);

            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today();
            ProgramPlansDAO.newInstance().insertRecords(programList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Enrollment__c> programEnrollmentList = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentList[0].hed__Contact__c = newContacts[0].Id;
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Course_Enrollment__c> courseEnrollmentList = new List<hed__Course_Enrollment__c>();
            courseEnrollmentList.add(new hed__Course_Enrollment__c(
                hed__Contact__c = newContacts[0].Id, 
                Enrollment_Status__c = 'Test',
                hed__Program_Enrollment__c = programEnrollmentList[0].Id
            )); 
            CourseConnectionsDAO.newInstance().insertRecords(courseEnrollmentList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            newApplications[0].Offered_Program_Plan__c = programList[0].Id;
            newApplications[0].Program_Enrollment__c = programEnrollmentList[0].Id;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addDays(14);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('Domestic and International Enrolment to Census', processContacts[0].Calculated_Cadence__c, 'Calculated cadence is empty.');
        }
    }

    @isTest
    private static void getInternationalEnrollmentToCensusForExitTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Nurture_Track_Configuration__c> nurtureList = createCensusCadence('Domestic and International Enrolment to Census', 'Exit', 14);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);

            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            newContacts[0].Calculated_Cadence__c = 'Domestic and International Enrolment to Census';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Availability_Start_Date__c = System.today().addDays(-14);
            ProgramPlansDAO.newInstance().insertRecords(programList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            newApplications[0].Offered_Program_Plan__c = programList[0].Id;
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            System.assertEquals('', processContacts[0].Calculated_Cadence__c, 'Calculated calculated must be cleared.');
        }
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
    

    @isTest
    private static void getExitDomesticOfferLapsedAutomatedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            //Create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = 'Domestic Offer Lapsed (Automated)';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            // create applied intake term
            List<Account> accountList = AccountsDAO.newInstance().getAccountsBySetNames(new Set<String>{'Test Account'});
            List<hed__Term__c> newTerms = new List<hed__Term__c>();
            newTerms.add(new hed__Term__c(
                hed__Start_Date__c = Date.today().addMonths(4),
                hed__Account__c = accountList[0].Id,
                Last_Admission_Date__c = Date.today().addDays(-1)
            ));
            TermsDAO.newInstance().insertRecords(newTerms, false, AccessLevel.SYSTEM_MODE);

            //Create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(
                newContacts,
                ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID,
                'New'
            );
            newApplications[0].Offer_Status__c = 'Offered'; //Offer Status is not Lapsed
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            newApplications[0].Applied_Intake_Study_Period__c = newTerms[0].Id;
            ApplicationsDAO.newInstance()
                .insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(
                new Map<Id, Contact>(newContacts)
            );
            Test.stopTest();

            System.assertEquals(
                '',
                processContacts[0].Calculated_Cadence__c,
                'Domestic Offer Lapsed (Automated): Exit criteria met'
            );
        }
    }

    

    @isTest
    private static void getExitInternationalApplicationToOfferTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            //Create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            newContacts[0].Calculated_Cadence__c = 'International Application to Offer';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            //Create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(
                newContacts,
                ApplicationsDAO.STUDYLINK_RECTYPE_ID,
                'Withdrawn'
            );
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            ApplicationsDAO.newInstance()
                .insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(
                new Map<Id, Contact>(newContacts)
            );
            Test.stopTest();
            System.assertEquals(
                '',
                processContacts[0].Calculated_Cadence__c,
                'International Application to Offer: Exit criteria met'
            );
        }
    }

    @isTest
    private static void getExitDomesticOfferLapsedManualTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            //Create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = 'Domestic Offer Lapsed';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
			// create applied intake term
            List<Account> accountList = AccountsDAO.newInstance().getAccountsBySetNames(new Set<String>{'Test Account'});
            List<hed__Term__c> newTerms = new List<hed__Term__c>();
            newTerms.add(new hed__Term__c(
                hed__Start_Date__c = Date.today().addMonths(4),
                hed__Account__c = accountList[0].Id,
                Last_Admission_Date__c = Date.today().addDays(-1)
            ));
            TermsDAO.newInstance().insertRecords(newTerms, false, AccessLevel.SYSTEM_MODE);
            //Create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(
                newContacts,
                ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID,
                'New'
            );
            newApplications[0].Offer_Status__c = 'Offered'; //Offer Status is not Lapsed
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            newApplications[0].Applied_Intake_Study_Period__c = newTerms[0].Id;
            ApplicationsDAO.newInstance()
                .insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(
                new Map<Id, Contact>(newContacts)
            );
            Test.stopTest();
            
            System.assertEquals(
                '',
                processContacts[0].Calculated_Cadence__c,
                'Domestic Offer Lapsed: Exit criteria met'
            );
        }
    }

    @isTest
    private static void getDomesticStrongInterestPreApplicationForEntryAutomatedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();

            Nurture_Track_Configuration__c ntc = new Nurture_Track_Configuration__c(
                        Cadence_Name__c = NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED,
                        Lead_Score_Threshold__c = -1,
                        Criteria_Type__c = 'Entry',
                        Enquiry_Category_L1__c = 'Applying for a course',
                        Status__c = 'Active'
                    );
            nurtureList.add(ntc);
            
            Nurture_Track_Configuration__c ntc1 = new Nurture_Track_Configuration__c(
                        Cadence_Name__c = NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
                        Lead_Score_Threshold__c = -1,
                        Criteria_Type__c = 'Entry',
                        Enquiry_Category_L1__c = 'Applying for a course',
                        Status__c = 'Active'
                    );
            nurtureList.add(ntc1);
            
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);  
            
            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(1);

            Case caseRec = new Case (
                    ContactId = contactList[0].Id,
                    Category__c = 'Applying for a course',
                    Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC
                );
            CasesDAO.newInstance().insertRecords(new List<Case>{caseRec},true,AccessLevel.USER_MODE);
            Test.stopTest();
        
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(contactList, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].hed__Application_Date__c = System.Now();
            newApplications[0].Offer_Status__c = 'Deferred';
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            
            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(contactList));
            // assert
            System.assertEquals(
                NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED,
                processContacts[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }
    
    @isTest
    private static void getDomesticStrongInterestPreApplicationForEntryManualTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();

            nurtureList.add(new Nurture_Track_Configuration__c(
                        Cadence_Name__c = NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
                        Lead_Score_Threshold__c = -1,
                        Criteria_Type__c = 'Entry',
                        Enquiry_Category_L1__c = 'Applying for a course',
                        Status__c = 'Active'
                    ));

            nurtureList.add(new Nurture_Track_Configuration__c(
                        Cadence_Name__c = NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED,
                        Lead_Score_Threshold__c = -1,
                        Criteria_Type__c = 'Entry',
                        Enquiry_Category_L1__c = 'Applying for a course',
                        Status__c = 'Active'
                    ));

            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList,false,AccessLevel.SYSTEM_MODE);
            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(1);
            Case caseRec = new Case (
                    ContactId = contactList[0].Id,
                    Category__c = 'Applying for a course',
                    Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC
                );
            CasesDAO.newInstance().insertRecords(new List<Case>{caseRec},true,AccessLevel.USER_MODE);
            Test.stopTest();
            
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(contactList, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].hed__Application_Date__c = System.Now();
            newApplications[0].Offer_Status__c = 'Deferred';
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            completedCadenceList.add(new Completed_Cadence__c(
                Application__c = newApplications[0].Id,
                Contact__c = contactList[0].Id,
                Nurture_Track_Configuration__c = nurtureList[1].Id,
                Completed_Cadence_Status__c ='Successful'
            ));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);

            // call method
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(contactList));
            
            // assert
            System.assertEquals(
                NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
                processContacts[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void getDomesticStrongInterestPreApplicationForExitAutomatedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
        
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'Submitted');
            newApplications[0].hed__Application_Date__c = System.Now();
            newApplications[0].Offer_Status__c = 'Deferred';
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
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
    private static void getDomesticStrongInterestPreApplicationForExitManualTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            // create contact
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            newContacts[0].Calculated_Cadence__c = NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
        
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'Submitted');
            newApplications[0].hed__Application_Date__c = System.Now();
            newApplications[0].Offer_Status__c = 'Deferred';
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(5);
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
    private static void getExitInternationalStrongInterestPreApplicationTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();

            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            newContacts[0].Calculated_Cadence__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
        
            List<hed__Application__c> newApplications = TestDataFactory.createApplicationRecords(newContacts[0].Id, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 1);
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(-5);
            newApplications[0].Application_Status__c = 'Active';
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            
            Test.stopTest();

            System.assertEquals(
                '',
                processContacts[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }

	@isTest
    private static void getDomesticAcceptedAndAdmittedTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
           
            List<Nurture_Track_Configuration__c> nurtureList = createCensusCadence('Domestic Accepted and Admitted', 'Entry', 14);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);
            
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'Domestic';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

            
            List<hed__Program_Enrollment__c> programEnrollmentList = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentList[0].hed__Contact__c = newContacts[0].Id;
            programEnrollmentList[0].Enrollment_Status__c = 'Admitted';
            programEnrollmentList[0].Enrollment_Status_Date__c = System.today().addMonths(-13);
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Enrollment__c> programEnrollmentListOne = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentListOne[0].hed__Contact__c = newContacts[0].Id;
            programEnrollmentListOne[0].Enrollment_Status__c = 'Admitted';
            programEnrollmentListOne[0].hed__Admission_Date__c = System.today().addMonths(-13);
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentListOne, false, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Plan__c> programList = TestDataFactory.createTestProgramPlanRecords(1);
            programList[0].Program_Level__c = 'Undergraduate';
            insert programList;

            List<hed__Application__c> newQtacApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.QTAC_RECTYPE_ID, 'New');
            newQtacApplications[0].Offer_Status__c = 'Accepted';
            ApplicationsDAO.newInstance().insertRecords(newQtacApplications, false, AccessLevel.SYSTEM_MODE);
            
            List<hed__Application__c> newApplications = createTestApplicationRecords(newContacts, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].Calculated_Intake_Date__c = System.today().addDays(5);
            newApplications[0].Offered_Program_Plan__c = programList[0].Id;
            newApplications[0].Related_QTAC_Application__c = null;
            newApplications[0].Program_Enrollment__c = programEnrollmentListOne[0].Id;
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
            
            System.assertEquals('Domestic Accepted and Admitted', processContacts[0].Calculated_Cadence__c, 'Calculated cadence is empty.');
        }
    }

    @isTest
    private static void getEntryInternationalApplicationToOfferDirectAutomatedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> contacts = new List<Contact>();
            contacts.add(new Contact(
                LastName = 'Test',
                hed__Citizenship_Status__c = 'International'
            ));
            ContactsDAO.newInstance().insertRecords(contacts, false, AccessLevel.SYSTEM_MODE);
            
            List<hed__Application__c> applications = new List<hed__Application__c>();
            applications.add(new hed__Application__c(
                RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID,
                hed__Applicant__c = contacts[0].Id,
                Application_Status__c = 'Submitted',
                Is_Agent_Assisted__c = false,
                Calculated_Intake_Date__c = Date.today() + 30
            ));
            ApplicationsDAO.newInstance().insertRecords(applications, false, AccessLevel.SYSTEM_MODE);

            Test.startTest();
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(contacts));
            Test.stopTest();

            System.assertEquals(
                NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTOMATED,
                processContacts[0].Calculated_Cadence__c,
                'Wrong calculated cadence.'
            );
        }
    }

    @isTest
    private static void getExitInternationalApplicationToOfferDirectAutomatedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> contacts = new List<Contact>();
            contacts.add(new Contact(
                LastName = 'Test',
                hed__Citizenship_Status__c = 'International',
                Calculated_Cadence__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTOMATED
            ));
            ContactsDAO.newInstance().insertRecords(contacts, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> applications = new List<hed__Application__c>();
            applications.add(new hed__Application__c(
                RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID,
                hed__Applicant__c = contacts[0].Id,
                Application_Status__c = 'Conditional Offer',
                Is_Agent_Assisted__c = false,
                Calculated_Intake_Date__c = Date.today() + 30
            ));
            ApplicationsDAO.newInstance().insertRecords(applications, false, AccessLevel.SYSTEM_MODE);

            Test.startTest();
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(contacts));
            Test.stopTest();

            System.assert(processContacts.isEmpty() == false, 'No contact is updated.');
            System.assertEquals('', processContacts[0].Calculated_Cadence__c, 'Calculated cadence is not cleared.');
        }
    }

    @isTest
    private static void getEntryInternationalApplicationToOfferAgentAutomatedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> contacts = new List<Contact>();
            contacts.add(new Contact(
                LastName = 'Test',
                hed__Citizenship_Status__c = 'International'
            ));
            ContactsDAO.newInstance().insertRecords(contacts, false, AccessLevel.SYSTEM_MODE);
            
            List<hed__Application__c> applications = new List<hed__Application__c>();
            applications.add(new hed__Application__c(
                RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID,
                hed__Applicant__c = contacts[0].Id,
                Application_Status__c = 'Submitted',
                Is_Agent_Assisted__c = true,
                Calculated_Intake_Date__c = Date.today() + 30
            ));
            ApplicationsDAO.newInstance().insertRecords(applications, false, AccessLevel.SYSTEM_MODE);

            Test.startTest();
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(contacts));
            Test.stopTest();

            System.assertEquals(
                NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_AGENT_AUTOMATED,
                processContacts[0].Calculated_Cadence__c,
                'Wrong calculated cadence.'
            );
        }
    }

    @isTest
    private static void getExitInternationalApplicationToOfferAgenttAutomatedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> contacts = new List<Contact>();
            contacts.add(new Contact(
                LastName = 'Test',
                hed__Citizenship_Status__c = 'International',
                Calculated_Cadence__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_AGENT_AUTOMATED
            ));
            ContactsDAO.newInstance().insertRecords(contacts, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> applications = new List<hed__Application__c>();
            applications.add(new hed__Application__c(
                RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID,
                hed__Applicant__c = contacts[0].Id,
                Application_Status__c = 'Conditional Offer',
                Is_Agent_Assisted__c = true,
                Calculated_Intake_Date__c = Date.today() + 30
            ));
            ApplicationsDAO.newInstance().insertRecords(applications, false, AccessLevel.SYSTEM_MODE);

            Test.startTest();
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(contacts));
            Test.stopTest();

            System.assert(processContacts.isEmpty() == false, 'No contact is updated.');
            System.assertEquals('', processContacts[0].Calculated_Cadence__c, 'Calculated cadence is not cleared.');
        }
    }
    @isTest
    private static void testEntryInternationalPreApplicationPartnerSourcedAutomatedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            
            Nurture_Track_Configuration__c ntc = new Nurture_Track_Configuration__c(
                Cadence_Name__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED,
                Lead_Score_Threshold__c = -1,
                Criteria_Type__c = 'Entry',
                Enquiry_Category_L1__c = 'Applying for a course',
                Status__c = 'Active'
            );
            nurtureList.add(ntc);
            
            Nurture_Track_Configuration__c ntc1 = new Nurture_Track_Configuration__c(
                Cadence_Name__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_MANUAL,
                Lead_Score_Threshold__c = -1,
                Criteria_Type__c = 'Entry',
                Enquiry_Category_L1__c = 'Applying for a course',
                Status__c = 'Active'
            );
            nurtureList.add(ntc1);
            
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);  
            
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = 'International';
            newContacts[0].Lead_Source_Category__c = ContactsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCE;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
			
            // call method
            Test.startTest();
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
                       
            // assert
            System.assertEquals(
                NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED,
                processContacts[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }
    
    @isTest
    private static void testEntryInternationalPreApplicationPartnerSourcedManualTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            
            Nurture_Track_Configuration__c ntc = new Nurture_Track_Configuration__c(
                Cadence_Name__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED,
                Lead_Score_Threshold__c = -1,
                Criteria_Type__c = 'Entry',
                Enquiry_Category_L1__c = 'Applying for a course',
                Status__c = 'Active'
            );
            nurtureList.add(ntc);
            
            Nurture_Track_Configuration__c ntc1 = new Nurture_Track_Configuration__c(
                Cadence_Name__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_MANUAL,
                Lead_Score_Threshold__c = -1,
                Criteria_Type__c = 'Entry',
                Enquiry_Category_L1__c = 'Applying for a course',
                Status__c = 'Active'
            );
            nurtureList.add(ntc1);
            
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);  
            
            List<Contact> newContacts = createTestContactRecords(0, 1);
            newContacts[0].hed__Citizenship_Status__c = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            newContacts[0].Lead_Source_Category__c = ContactsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCE;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            completedCadenceList.add(new Completed_Cadence__c(
                Contact__c = newContacts[0].Id,
                Nurture_Track_Configuration__c = nurtureList[0].Id,
                Completed_Cadence_Status__c ='Successful'
            ));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);
			
            // call method
            Test.startTest();
            List<Contact> processContacts = NurturingTrackContactService.processContactForEntryAndExit(new Map<Id, Contact>(newContacts));
            Test.stopTest();
                       
            // assert
            System.assertEquals(
                NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_MANUAL,
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