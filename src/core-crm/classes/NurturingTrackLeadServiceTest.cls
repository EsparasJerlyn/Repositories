/**
 * @description Test class for NurturingTrackLeadService
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6105              | Created file                 |
      | mark.j.mahilum                 | Sept 07, 2023         | DEPP-6479              | Added calculated intake date |
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
            
            List<Nurture_Track_Configuration__c> configsList = generateNurtureTrackConfigurations();
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(configsList, false, AccessLevel.SYSTEM_MODE);
            // Alex-offshore: Interesting behavior. Some criterias will always read configs even if there are no valid records for entry/exit
            //                This breaks testing if the test method hasn't set up all the needed configs. Add your config to the method above
            //                instead of creating them in your test method itself.

        }
    }

    @isTest
    private static void testAutomaticInternationalDirectApplicantEntry() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
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
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(newLeads));
            Test.stopTest();
            // assert
            System.assertEquals(
                'International Application Submission - Direct Applicant (Automated)',
                processLeads[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }
    
    @isTest
    private static void testManualInternationalDirectApplicantEntry() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
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
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(newLeads));
            Test.stopTest();
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
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();

            // create Lead Score Detail
            Lead_Score_Detail__c lsd = new Lead_Score_Detail__c();
            lsd.Total_Lead_Score__c = 200;
            insert lsd;

            Marketing_Segmentation__c marketingSeg = new Marketing_Segmentation__c();
            marketingSeg.My_Citizenship_Status__c = 'Australian Citizen or Permanent Resident';
            insert marketingSeg;

            // create contact
            List<Lead> newLeads = createTestLeadRecords(0, 1);
            newLeads[0].Lead_Score_Detail__c = lsd.Id;
            newLeads[0].Marketing_Segmentation__c = marketingSeg.Id;
            LeadsDAO.newInstance().insertRecords(newLeads, false, AccessLevel.SYSTEM_MODE);

            Case caseRec = new Case (
                    Lead__c = newLeads[0].Id,
                    Category__c = 'Applying for a course'
                );
            insert caseRec;
        
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newLeads, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].hed__Application_Date__c = System.Now();
            newApplications[0].Offer_Status__c = 'Deffered';
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            // call method
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(newLeads));
            Test.stopTest();
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
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();

            // create Lead Score Detail
            Lead_Score_Detail__c lsd = new Lead_Score_Detail__c();
            lsd.Total_Lead_Score__c = 200;
            insert lsd;

            List<Nurture_Track_Configuration__c> nurtureList1 = NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackByCadenceNames(
                new Set<String>{'Domestic Strong Interest Pre-Application (Automated)'},
                'SYSTEM_MODE'
            );

            Marketing_Segmentation__c marketingSeg = new Marketing_Segmentation__c();
            marketingSeg.My_Citizenship_Status__c = 'Australian Citizen or Permanent Resident';
            insert marketingSeg;

            // create contact
            List<Lead> newLeads = createTestLeadRecords(0, 1);
            newLeads[0].Lead_Score_Detail__c = lsd.Id;
            newLeads[0].Marketing_Segmentation__c = marketingSeg.Id;
            LeadsDAO.newInstance().insertRecords(newLeads, false, AccessLevel.SYSTEM_MODE);

            Case caseRec = new Case (
                    Lead__c = newLeads[0].Id,
                    Category__c = 'Applying for a course'
                );
            insert caseRec;
        
            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newLeads, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'New');
            newApplications[0].hed__Application_Date__c = System.Now();
            newApplications[0].Offer_Status__c = 'Deffered';
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            completedCadenceList.add(new Completed_Cadence__c(
                Application__c = newApplications[0].Id,
                Lead__c = newLeads[0].Id,
                Nurture_Track_Configuration__c = nurtureList1[0].Id
            ));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);

            // call method
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(newLeads));
            Test.stopTest();
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
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();

            Marketing_Segmentation__c marketingSeg = new Marketing_Segmentation__c();
            marketingSeg.My_Citizenship_Status__c = 'Australian Citizen or Permanent Resident';
            insert marketingSeg;

            // create contact
            List<Lead> newLeads = createTestLeadRecords(0, 1);
            newLeads[0].Marketing_Segmentation__c = marketingSeg.Id;
            newLeads[0].Calculated_Cadence__c = 'Domestic Strong Interest Pre-Application (Automated)';
            LeadsDAO.newInstance().insertRecords(newLeads, false, AccessLevel.SYSTEM_MODE);

            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newLeads, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'Submitted');
            newApplications[0].hed__Application_Date__c = System.Now();
            newApplications[0].Offer_Status__c = 'Deffered';
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            // call method
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(newLeads));
            Test.stopTest();
            // assert
            System.assertEquals(
                '',
                processLeads[0].Calculated_Cadence__c, 
                'Error, wrong calculated cadence value.'
            );
        }
    }

    @isTest
    private static void getDomesticStrongInterestPreApplicationForExitManualTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();

            Marketing_Segmentation__c marketingSeg = new Marketing_Segmentation__c();
            marketingSeg.My_Citizenship_Status__c = 'Australian Citizen or Permanent Resident';
            insert marketingSeg;

            // create contact
            List<Lead> newLeads = createTestLeadRecords(0, 1);
            newLeads[0].Marketing_Segmentation__c = marketingSeg.Id;
            newLeads[0].Calculated_Cadence__c = 'Domestic Strong Interest Pre-Application';
            LeadsDAO.newInstance().insertRecords(newLeads, false, AccessLevel.SYSTEM_MODE);

            // create application
            List<hed__Application__c> newApplications = createTestApplicationRecords(newLeads, ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID, 'Submitted');
            newApplications[0].hed__Application_Date__c = System.Now();
            newApplications[0].Offer_Status__c = 'Deffered';
            ApplicationsDAO.newInstance().insertRecords(newApplications, false, AccessLevel.SYSTEM_MODE);

            // call method
            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(newLeads));
            Test.stopTest();
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
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            Lead_Score_Detail__c leadScoreDetail = new Lead_Score_Detail__c(
                Total_Lead_Score__c = 200
            );
            insert leadScoreDetail;
    
            Marketing_Segmentation__c marSeg = new Marketing_Segmentation__c(
                My_Citizenship_Status__c = 'International Student'
            );
            insert marSeg;
            
            List<Lead> leadList = createTestLeadRecords(0, 1);
            leadList[0].Lead_Score_Detail__c = leadScoreDetail.Id;
            leadList[0].Marketing_Segmentation__c = marSeg.Id;
            LeadsDAO.newInstance().insertRecords(leadList, false, AccessLevel.SYSTEM_MODE);
            // emulate batch job's queryFilter
            leadList[0] = [
                SELECT Id, Can_Nurture__c, Lead_Score__c, Calculated_Cadence__c, 
                HasOptedOutOfEmail, Marketing_Segmentation__r.My_Citizenship_Status__c 
                FROM Lead LIMIT 1
            ];
            
            List<Case> caseList = new List<Case>();
            caseList.add(new Case(
                Category__c = 'Applying for a course',
                Lead__c = leadList[0].Id
            ));
            CasesDAO.newInstance().insertRecords(caseList, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> applList = createTestApplicationRecords(leadList, ApplicationsDAO.STUDYLINK_RECTYPE_ID, 'Accepted');
            applList[0].hed__Application_Date__c = System.now().addYears(-2);
            ApplicationsDAO.newInstance().insertRecords(applList, false, AccessLevel.SYSTEM_MODE);

            List<Lead> processLeads = NurturingTrackLeadService.processLeadForEntryAndExit(new Map<Id, Lead>(leadList));

            Boolean isAutoEntrySuccess = !processLeads.isEmpty() && processLeads[0].Calculated_Cadence__c == 'International Strong Interest Pre-Application (Automated)';
            
            leadList[0].Calculated_Cadence__c = '';
            
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
            
            Boolean isManualEntrySuccess = !processLeads.isEmpty() && processLeads[0].Calculated_Cadence__c == 'International Strong Interest Pre-Application';
            Test.stopTest();

            System.assert(isAutoEntrySuccess, 'Automatic entry calculated cadence population failed.');
            System.assert(isManualEntrySuccess, 'Manual entry calculated cadence population failed.');
        }
    }
    
    @isTest
    private static void getExitInternationalStrongInterestPreApplicationTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            Marketing_Segmentation__c marSeg = new Marketing_Segmentation__c(
                My_Citizenship_Status__c = 'International Student'
            );
            insert marSeg;
            
            List<Lead> leadList = createTestLeadRecords(0, 1);
            leadList[0].Calculated_Cadence__c = 'International Strong Interest Pre-Application (Automated)';
            leadList[0].Marketing_Segmentation__c = marSeg.Id;
            LeadsDAO.newInstance().insertRecords(leadList, false, AccessLevel.SYSTEM_MODE);
            // emulate batch job's queryFilter
            leadList[0] = [
                SELECT Id, Can_Nurture__c, Lead_Score__c, Calculated_Cadence__c, 
                HasOptedOutOfEmail, Marketing_Segmentation__r.My_Citizenship_Status__c 
                FROM Lead LIMIT 1
            ];
            
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
            Test.stopTest();
            
            System.assert(isAutoExitSuccess, 'Automatic exit calculated cadence clearing failed.');
            System.assert(isManualExitSuccess, 'Manual exit calculated cadence clearing failed.');
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