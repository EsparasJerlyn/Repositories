/**
 * @description Test class for NurturingTrackLeadService.
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                            |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6105              | Created file                                                                              |
      | mark.j.mahilum                 | Sept 07, 2023         | DEPP-6479              | Added calculated intake date                                                              |
      | arsenio.jr.dayrit              | Feb 27, 2024          | DEPP-8133              | Updated test class method  International Application Submission - Direct Applicant Exit   |
 */
@isTest
public with sharing class NurturingTrackLeadServiceTest {
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
            List<Nurture_Track_Configuration__c> configsList = generateNurtureTrackConfigurations();
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(configsList, false, AccessLevel.SYSTEM_MODE);
            // Alex-offshore: Interesting behavior. Some criterias will always read configs even if there are no valid records for entry/exit
            //                This breaks testing if the test method hasn't set up all the needed configs. Add your config to the method above
            //                instead of creating them in your test method itself.

        }

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
                    Name = 'Enquiries',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                    Domestic_International__c = 'Undetermined',
                    Study_Level__c = 'Undetermined',
                    Description__c = '',
                    Score_Allocation__c = null,
                    Time_Limit_Months__c = null,
                    Max_Score__c = 200,
                    Parent_Category__c = leadScoreParentConfigList[0].Id
                )
            );            
            leadScoreConfigList.add(
                new Lead_Score_Configuration__c(
                    Name = 'Marketing consent',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                    Domestic_International__c = 'Undetermined',
                    Study_Level__c = 'Undetermined',
                    Description__c = '',
                    Score_Allocation__c = null,
                    Time_Limit_Months__c = null,
                    Max_Score__c = 200,
                    Parent_Category__c = leadScoreParentConfigList[0].Id
                )
            );
            leadScoreConfigList.add(
                new Lead_Score_Configuration__c(
                    Name = 'Enquiries',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                    Domestic_International__c = 'International',
                    Study_Level__c = 'Undetermined',
                    Description__c = '',
                    Score_Allocation__c = null,
                    Time_Limit_Months__c = 3,
                    Max_Score__c = 200,
                    Parent_Category__c = leadScoreParentConfigList[0].Id
                )
            );

            LeadScoreConfigurationDAO.newInstance()
                .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

            List<Lead_Score_Configuration__c> leadScoreConfigChildList = new List<Lead_Score_Configuration__c>();
            leadScoreConfigChildList.addAll(TestDataFactory.createUndAndUndeterminedSubCategory(
                leadScoreConfigList[0].Id,
                new List<String>{
                    'Applying for a course'
                    
                },
                new List<Integer>{ 200,200}
            ));
            leadScoreConfigChildList.addAll(TestDataFactory.createUndAndUndeterminedSubCategory(
                leadScoreConfigList[1].Id,
                new List<String>{
                    'Yes',
                    'is blank'
                },
                new List<Integer>{ 200,200}
            ));
            leadScoreConfigChildList.addAll(TestDataFactory.createIntlAndUndeterminedSubCategory(
                leadScoreConfigList[2].Id,
                new List<String>{
                    'Applying for a course'
                    
                },
                new List<Integer>{ 200,200}
            ));

            LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreConfigChildList, true, AccessLevel.SYSTEM_MODE);

            // create lead
            List<Lead> newLead = TestDataFactory.createTestLeadRecords(0,1);
            newLead[0].Email_Opt_In_Datetime__c = System.Today();
            LeadsDAO.newInstance().insertRecords(newLead, true, AccessLevel.SYSTEM_MODE);
    }
    
    @isTest
    private static void testManualInternationalDirectApplicantEntry() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Segmentation__c> marSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id},AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> marsSegToUpdate = new List<Marketing_Segmentation__c>();
            marsSegToUpdate.add(new Marketing_Segmentation__c(Id = marSegList[0].Id, My_Citizenship_Status__c = 'International Student'));
            MarketingSegmentationsDAO.newInstance().updateRecords(marsSegToUpdate,true,AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            // SOQL the lead so it includes Marketing_Segmentation__r.My_Citizenship_Status__c
            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);

            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(leadList, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // call method
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));
            
            // assert
            System.assertEquals(
                'International Application Submission - Direct Applicant (Automated)',
                processLeads[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void getDomesticStrongInterestPreApplicationForEntryAutomatedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Segmentation__c> marSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id},AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> marsSegToUpdate = new List<Marketing_Segmentation__c>();
            marsSegToUpdate.add(new Marketing_Segmentation__c(Id = marSegList[0].Id, My_Citizenship_Status__c = 'Australian Citizen or Permanent Resident'));
            MarketingSegmentationsDAO.newInstance().updateRecords(marsSegToUpdate,true,AccessLevel.SYSTEM_MODE);

            // SOQL the lead so it includes Marketing_Segmentation__r.My_Citizenship_Status__c
            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);

            Case caseRec = new Case (
                    Lead__c = leadList[0].Id,
                    Category__c = 'Applying for a course',
                    Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC
                );
            CasesDAO.newInstance().insertRecords(new List<Case>{caseRec},true,AccessLevel.SYSTEM_MODE);

            Test.stopTest();
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(leadList, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].hed__Application_Date__c = System.Now();
            newApplications[0].Offer_Status__c = 'Deferred';
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            // call method
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));
            
            // assert
            System.assertEquals(
                'Domestic Strong Interest Pre-Application (Automated)',
                processLeads[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void getDomesticStrongInterestPreApplicationForEntryManualTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Segmentation__c> marSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id},AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> marsSegToUpdate = new List<Marketing_Segmentation__c>();
            marsSegToUpdate.add(new Marketing_Segmentation__c(Id = marSegList[0].Id, My_Citizenship_Status__c = 'Australian Citizen or Permanent Resident'));
            MarketingSegmentationsDAO.newInstance().updateRecords(marsSegToUpdate,true,AccessLevel.SYSTEM_MODE);

            // SOQL the lead so it includes Marketing_Segmentation__r.My_Citizenship_Status__c
            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);


            List<Nurture_Track_Configuration__c> nurtureList1 = NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackByCadenceNames(
                new Set<String>{'Domestic Strong Interest Pre-Application (Automated)'},
                'SYSTEM_MODE'
            );

            Case caseRec = new Case (
                    Lead__c = leadList[0].Id,
                    Category__c = 'Applying for a course',
                    Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC
                );

            CasesDAO.newInstance().insertRecords(new List<Case>{caseRec},true,AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(leadList, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].hed__Application_Date__c = System.Now();
            newApplications[0].Offer_Status__c = 'Deferred';
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            completedCadenceList.add(new Completed_Cadence__c(
                Application__c = newApplications[0].Id,
                Lead__c = leadList[0].Id,
                Nurture_Track_Configuration__c = nurtureList1[0].Id,
                Completed_Cadence_Status__c ='Successful'
            ));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);

            // call method
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));
            
            // assert
            System.assertEquals(
                'Domestic Strong Interest Pre-Application',
                processLeads[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void getDomesticStrongInterestPreApplicationForExitAutomatedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Segmentation__c> marSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id},AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> marsSegToUpdate = new List<Marketing_Segmentation__c>();
            marsSegToUpdate.add(new Marketing_Segmentation__c(Id = marSegList[0].Id, My_Citizenship_Status__c = 'Australian Citizen or Permanent Resident'));
            MarketingSegmentationsDAO.newInstance().updateRecords(marsSegToUpdate,true,AccessLevel.SYSTEM_MODE);

        
            leadList[0].Calculated_Cadence__c = 'Domestic Strong Interest Pre-Application (Automated)';
            LeadsDAO.newInstance().updateRecords(leadList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(leadList, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'Submitted');
            newApplications[0].hed__Application_Date__c = System.Now();
            newApplications[0].Offer_Status__c = 'Deferred';
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            // call method
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));
            
            // assert
            System.assertEquals(
                '',
                processLeads[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void testAutomaticInternationalDirectApplicantEntry() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            // get lead
            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Segmentation__c> marSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id},AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> marsSegToUpdate = new List<Marketing_Segmentation__c>();
            marsSegToUpdate.add(new Marketing_Segmentation__c(Id = marSegList[0].Id, My_Citizenship_Status__c = 'International Student'));
            MarketingSegmentationsDAO.newInstance().updateRecords(marsSegToUpdate,true,AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            // SOQL the lead so it includes Marketing_Segmentation__r.My_Citizenship_Status__c
            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);

            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(leadList, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'New');
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4);

            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            // call method
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));
            
            // assert
            System.assertEquals(
                'International Application Submission - Direct Applicant (Automated)',
                processLeads[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void testAutomaticInternationalDirectApplicantExit() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Segmentation__c> marSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id},AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> marsSegToUpdate = new List<Marketing_Segmentation__c>();
            marsSegToUpdate.add(new Marketing_Segmentation__c(Id = marSegList[0].Id, My_Citizenship_Status__c = 'International Student'));
            MarketingSegmentationsDAO.newInstance().updateRecords(marsSegToUpdate,true,AccessLevel.SYSTEM_MODE);

            leadList[0].Calculated_Cadence__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_AUTOMATED;
            LeadsDAO.newInstance().updateRecords(leadList, false, AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            
            // create application0
            List<hed__Application__c> newApplications = createTestApplicationRecords(leadList, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Submitted');
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4).addDays(1);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // call method
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));
            // assert
            System.assertEquals(
                '', processLeads[0].Calculated_Cadence__c, 'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void testManualInternationalDirectApplicantExit() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Segmentation__c> marSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id},AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> marsSegToUpdate = new List<Marketing_Segmentation__c>();
            marsSegToUpdate.add(new Marketing_Segmentation__c(Id = marSegList[0].Id, My_Citizenship_Status__c = 'International Student'));
            MarketingSegmentationsDAO.newInstance().updateRecords(marsSegToUpdate,true,AccessLevel.SYSTEM_MODE);

            leadList[0].Calculated_Cadence__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_MANUAL;
            LeadsDAO.newInstance().updateRecords(leadList, false, AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            
            // create application0
            List<hed__Application__c> newApplications = createTestApplicationRecords(leadList, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Submitted');
            newApplications[0].Calculated_Intake_Date__c = Date.today().addMonths(4).addDays(1);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);
            // call method
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));
            // assert
            System.assertEquals(
                '', processLeads[0].Calculated_Cadence__c, 'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void getDomesticStrongInterestPreApplicationForExitManualTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Segmentation__c> marSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id},AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> marsSegToUpdate = new List<Marketing_Segmentation__c>();
            marsSegToUpdate.add(new Marketing_Segmentation__c(Id = marSegList[0].Id, My_Citizenship_Status__c = 'Australian Citizen or Permanent Resident'));
            MarketingSegmentationsDAO.newInstance().updateRecords(marsSegToUpdate,true,AccessLevel.SYSTEM_MODE);

            leadList[0].Calculated_Cadence__c = 'Domestic Strong Interest Pre-Application';
            LeadsDAO.newInstance().updateRecords(leadList, false, AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(leadList, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'Submitted');
            newApplications[0].hed__Application_Date__c = System.Now();
            newApplications[0].Offer_Status__c = 'Deferred';
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            // call method
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));
            
            // assert
            System.assertEquals(
                '',
                processLeads[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest 
    private static void getEntryInternationalStrongInterestPreApplicationTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Segmentation__c> marSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id},AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> marsSegToUpdate = new List<Marketing_Segmentation__c>();
            marsSegToUpdate.add(new Marketing_Segmentation__c(Id = marSegList[0].Id, My_Citizenship_Status__c = 'International Student'));
            MarketingSegmentationsDAO.newInstance().updateRecords(marsSegToUpdate,true,AccessLevel.SYSTEM_MODE);
            
            // SOQL the lead so it includes Marketing_Segmentation__r.My_Citizenship_Status__c
            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            
            List<Case> caseList = new List<Case>();
            caseList.add(new Case(
                Category__c = 'Applying for a course',
                Lead__c = leadList[0].Id,
                Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
            ));
            CasesDAO.newInstance().insertRecords(caseList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);

            List<hed__Application__c> applList = createTestApplicationRecords(leadList, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Accepted');
            applList[0].hed__Initial_Creation_Date__c = System.today().addYears(-2);
            ApplicationsDAO.newInstance().insertRecords(applList, false, AccessLevel.SYSTEM_MODE);

            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));

            Boolean isAutoEntrySuccess = !processLeads.isEmpty() && processLeads[0].Calculated_Cadence__c == NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED;
            
            leadList[0].Calculated_Cadence__c = '';
            
			List<Nurture_Track_Configuration__c> configList = NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackByCadenceNames(
                new Set<String> {NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED},
                'SYSTEM_MODE'
            );
            
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            completedCadenceList.add(new Completed_Cadence__c(
                Application__c = applList[0].Id,
                Lead__c = leadList[0].Id,
                Nurture_Track_Configuration__c = configList[0].Id,
                Completed_Cadence_Status__c ='Successful'
            ));

            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);

            processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));
            
            Boolean isManualEntrySuccess = !processLeads.isEmpty() && processLeads[0].Calculated_Cadence__c == NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL;

            System.assert(isAutoEntrySuccess, 'Automatic entry calculated cadence population failed.');
            System.assert(isManualEntrySuccess, 'Manual entry calculated cadence population failed.');
        }
    }
    
    @isTest
    private static void getExitInternationalStrongInterestPreApplicationTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Segmentation__c> marSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id},AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> marsSegToUpdate = new List<Marketing_Segmentation__c>();
            marsSegToUpdate.add(new Marketing_Segmentation__c(Id = marSegList[0].Id, My_Citizenship_Status__c = 'International Student'));
            MarketingSegmentationsDAO.newInstance().updateRecords(marsSegToUpdate,true,AccessLevel.SYSTEM_MODE);

            leadList[0].Calculated_Cadence__c = 'International Strong Interest Pre-Application (Automated)';
            LeadsDAO.newInstance().updateRecords(leadList, false, AccessLevel.SYSTEM_MODE);

            Test.stopTest();

            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            
            List<hed__Application__c> applList = createTestApplicationRecords(leadList, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Active');
            applList[0].hed__Application_Date__c = System.now().addYears(-2);
            ApplicationsDAO.newInstance().insertRecords(applList, false, AccessLevel.SYSTEM_MODE);
            
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));
            
            Boolean isAutoExitSuccess = !processLeads.isEmpty() && processLeads[0].Calculated_Cadence__c == '';
            
            leadList[0].Calculated_Cadence__c = 'International Strong Interest Pre-Application';
            
            List<Nurture_Track_Configuration__c> configList = NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackByCadenceNames(
                new Set<String> {'International Strong Interest Pre-Application'},
                'SYSTEM_MODE'
            );
            
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            completedCadenceList.add(new Completed_Cadence__c(
                Application__c = applList[0].Id,
                Lead__c = leadList[0].Id,
                Nurture_Track_Configuration__c = configList[0].Id
            ));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);
            
            processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));
            
            Boolean isManualExitSuccess = !processLeads.isEmpty() && processLeads[0].Calculated_Cadence__c == '';

            
            System.assert(isAutoExitSuccess, 'Automatic exit calculated cadence clearing failed.');
            System.assert(isManualExitSuccess, 'Manual exit calculated cadence clearing failed.');
        }
    }

    @isTest
    private static void getDomesticAcceptedAndAdmittedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();

            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Segmentation__c> marSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id},AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> marsSegToUpdate = new List<Marketing_Segmentation__c>();
            marsSegToUpdate.add(new Marketing_Segmentation__c(Id = marSegList[0].Id, My_Citizenship_Status__c = 'Australian Citizen or Permanent Resident'));
            MarketingSegmentationsDAO.newInstance().updateRecords(marsSegToUpdate,true,AccessLevel.SYSTEM_MODE);

            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);

            List<hed__Program_Enrollment__c> programEnrollmentList = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentList[0].Enrollment_Status__c = 'Admitted';
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            List<hed__Course_Enrollment__c> courseEnrollmentList = new List<hed__Course_Enrollment__c>();
            courseEnrollmentList.add(new hed__Course_Enrollment__c(
                Enrollment_Status__c = 'Test',
                hed__Program_Enrollment__c = programEnrollmentList[0].Id
            )); 
            CourseConnectionsDAO.newInstance().insertRecords(courseEnrollmentList, false, AccessLevel.SYSTEM_MODE);
        
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(leadList, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].Program_Enrollment__c = programEnrollmentList[0].Id;
            newApplications[0].Calculated_Intake_Date__c = System.today().addDays(5);
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            // call method
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));
            
            // assert
            System.assertEquals('Domestic Accepted and Admitted', processLeads[0].Calculated_Cadence__c, 'Calculated cadence is empty.');
        }
    }

    @isTest
    private static void getEntryInternationalApplicationToOfferDirectAutomatedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Lead> leads = LeadsDAO.newInstance().getLeadsWithLimit(1);

            List<Marketing_Segmentation__c> mseg = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(
                new Set<Id>{leads[0].Id},
                AccessLevel.SYSTEM_MODE
            );
            mseg[0].My_Citizenship_Status__c = 'International Student';
            MarketingSegmentationsDAO.newInstance().updateRecords(mseg, false, AccessLevel.SYSTEM_MODE);
            
            List<hed__Application__c> applications = new List<hed__Application__c>();
            applications.add(new hed__Application__c(
                RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID,
                Lead__c = leads[0].Id,
                Application_Status__c = 'Submitted',
                Is_Agent_Assisted__c = false,
                Calculated_Intake_Date__c = Date.today() + 30
            ));
            ApplicationsDAO.newInstance().insertRecords(applications, false, AccessLevel.SYSTEM_MODE);

            Test.startTest();
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leads));
            Test.stopTest();

            System.assertEquals(
                NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTOMATED,
                processLeads[0].Calculated_Cadence__c,
                'Wrong calculated cadence.'
            );
        }
    }

    @isTest
    private static void getExitInternationalApplicationToOfferDirectAutomatedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Lead> leads = LeadsDAO.getLeadsWithLimit(1);
            leads[0].Calculated_Cadence__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTOMATED;
            LeadsDAO.newInstance().updateRecords(leads, false, AccessLevel.SYSTEM_MODE);

            List<Marketing_Segmentation__c> mseg = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(
                new Set<Id>{leads[0].Id},
                AccessLevel.SYSTEM_MODE
            );
            mseg[0].My_Citizenship_Status__c = 'International Student';
            MarketingSegmentationsDAO.newInstance().updateRecords(mseg, false, AccessLevel.SYSTEM_MODE);

            leads = LeadsDAO.getLeadsWithLimit(1);

            List<hed__Application__c> applications = new List<hed__Application__c>();
            applications.add(new hed__Application__c(
                RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID,
                Lead__c = leads[0].Id,
                Application_Status__c = 'Conditional Offer',
                Is_Agent_Assisted__c = false,
                Calculated_Intake_Date__c = Date.today() + 30
            ));
            ApplicationsDAO.newInstance().insertRecords(applications, false, AccessLevel.SYSTEM_MODE);

            Test.startTest();
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leads));
            Test.stopTest();

            System.assert(processLeads.isEmpty() == false, 'No lead is updated.');
            System.assertEquals('', processLeads[0].Calculated_Cadence__c, 'Calculated cadence is not cleared.');
        }
    }
    
    @isTest 
    private static void testEntryInternationalPreApplicationPartnerSourcedManualTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Segmentation__c> marSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id},AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> marsSegToUpdate = new List<Marketing_Segmentation__c>();
            marsSegToUpdate.add(new Marketing_Segmentation__c(Id = marSegList[0].Id, My_Citizenship_Status__c = 'International Student'));
            MarketingSegmentationsDAO.newInstance().updateRecords(marsSegToUpdate,true,AccessLevel.SYSTEM_MODE);
            
            // SOQL the lead so it includes Marketing_Segmentation__r.My_Citizenship_Status__c
            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            
            List<Nurture_Track_Configuration__c> configList = NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackByCadenceNames(
                new Set<String> {NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED},
                'SYSTEM_MODE'
            );
            
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            completedCadenceList.add(new Completed_Cadence__c(
                Lead__c = leadList[0].Id,
                Nurture_Track_Configuration__c = configList[0].Id
            ));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);
            
            Test.stopTest();
            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            leadList[0].Lead_Source_Category__c = LeadsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCED;

            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));

            // assert
            System.assertEquals(
                NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_MANUAL,
                processLeads[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    } 
    
    @isTest 
    private static void testEntryInternationalPreApplicationPartnerSourcedAutomatedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Segmentation__c> marSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id},AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> marsSegToUpdate = new List<Marketing_Segmentation__c>();
            marsSegToUpdate.add(new Marketing_Segmentation__c(Id = marSegList[0].Id, My_Citizenship_Status__c = 'International Student'));
            MarketingSegmentationsDAO.newInstance().updateRecords(marsSegToUpdate,true,AccessLevel.SYSTEM_MODE);
            
            // SOQL the lead so it includes Marketing_Segmentation__r.My_Citizenship_Status__c
            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            Test.stopTest();
            leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            leadList[0].Lead_Source_Category__c = LeadsDAO.LEAD_SOURCE_CATEGORY_PARTNER_SOURCED;

            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));

            // assert
            System.assertEquals(
                NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED,
                processLeads[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }
    
    /**
     * Generate nurture track configurations and return them as a list of records.
     * Some criterias will always read configs even if there are no valid records for entry/exit
     * This breaks testing if the test method hasn't set up all the needed configs. Add your config to the method above
     * instead of creating them in your test method itself.
     * @return {List<Nurture_Track_Configuration__c>} A list of the configuration records
     */
    private static List<Nurture_Track_Configuration__c> generateNurtureTrackConfigurations() {
        List<Nurture_Track_Configuration__c> configsList = new List<Nurture_Track_Configuration__c>();
        // Alex-offshore: This was in the setup already... o- o?
        configsList.add(new Nurture_Track_Configuration__c(
            Cadence_Name__c = 'TEST 1',
            Lead_Score_Threshold__c = 3,
            Status__c = 'Active'
        ));
        //  Domestic Strong Interest Pre-Application (Automated) [Entry]
        configsList.add(new Nurture_Track_Configuration__c(
            Cadence_Name__c = 'Domestic Strong Interest Pre-Application (Automated)',
            Criteria_Type__c = 'Entry',
            Enquiry_Category_L1__c = 'Applying for a course',
            Lead_Score_Threshold__c = 180,
            Status__c = 'Active'
        ));
        // Domestic Strong Interest Pre-Application [Entry]
        configsList.add(new Nurture_Track_Configuration__c(
            Cadence_Name__c = 'Domestic Strong Interest Pre-Application',
            Criteria_Type__c = 'Entry',
            Enquiry_Category_L1__c = 'Applying for a course',
            Lead_Score_Threshold__c = 180,
            Status__c = 'Active'
        ));
        // International Strong Interest Pre-Application (Automated) [Entry]
        configsList.add(new Nurture_Track_Configuration__c(
            Cadence_Name__c = 'International Strong Interest Pre-Application (Automated)',
            Criteria_Type__c = 'Entry',
            Enquiry_Category_L1__c = 'Course information;Applying for a course',
            Lead_Score_Threshold__c = 180,
            Status__c = 'Active'
        ));
        // International Strong Interest Pre-Application [Entry]
        configsList.add(new Nurture_Track_Configuration__c(
            Cadence_Name__c = 'International Strong Interest Pre-Application',
            Criteria_Type__c = 'Entry',
            Enquiry_Category_L1__c = 'Course information;Applying for a course',
            Lead_Score_Threshold__c = 180,
            Status__c = 'Active'
        ));
        // INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED
        configsList.add(new Nurture_Track_Configuration__c(
            Cadence_Name__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED,
            Criteria_Type__c = 'Entry',
            Status__c = 'Active'
        ));
        // INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_MANUAL
        configsList.add(new Nurture_Track_Configuration__c(
            Cadence_Name__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_MANUAL,
            Criteria_Type__c = 'Entry',
            Status__c = 'Active'
        ));
        return configsList;
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