/**
 * @description helper class for NurturingTrackContactService
 * @see NurturingTrackContactBatch
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------------------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6105              | Created file                                                                                      |
      | mark.j.mahilum                 | Sept 19, 2023         | DEPP-6479              | Revert methods getCurrentIntakePeriodTest,isDateWithinRangeTest and isDateWithinRangeFailsafeTest |
      | kenneth.f.alsay                | December 27, 2023     |                        | Removed unused variables                                                                          |
      | alexander.cadalin              | August 8, 2024        | DEPP-8724              | Updated tests for getApplicantIdsWithCompletedCadence/getApplicantIdsWithAllCompletedCadence      |
 */
@isTest
public with sharing class NurturingTrackServiceTest {

    @TestSetup
    static void makeData(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
    }

    @isTest
    private static void getNurturingTrackRecordsTest() {
            System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            ImplementationSelector.DAO.setMock(new NurtureTrackConfigurationsDAOMock());
            Test.startTest(); 
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Cadence_Name__c = 'International Application Submission - Direct Applicant (Automated)';
            nurtureConfig.Lead_Score_Threshold__c = 3;
            nurtureConfig.Status__c = 'Active';
            nurtureList.add(nurtureConfig);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);
            Map<String, Nurture_Track_Configuration__c>  nurtureTrackMap = NurturingTrackService.getNurturingTrackRecords();
            System.assert(nurtureTrackMap != null, 'Nurture track map is empty');
            System.assertEquals( 1 , nurtureTrackMap.size(), 'Nurture track Map should have 1 item');
            Test.stopTest();
        }
    }

    @isTest
    private static void getApplicantIdsWithCompletedCadenceTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            conList[0].recordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
            ContactsDAO.newInstance().insertRecords(conList, false, AccessLevel.SYSTEM_MODE);
            LeadsDAO.newInstance().insertRecords(leadList, false, AccessLevel.SYSTEM_MODE);

            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Cadence_Name__c = 'International Application Submission - Direct Applicant (Automated)';
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

            Completed_cadence__c cadence2 = new Completed_Cadence__c();
            cadence2.Lead__c = leadID;
            cadence2.Nurture_Track_Configuration__c = nurtureList[0].Id;
            cadence2.Completed_Cadence_Status__c ='Successful';
            insert cadence2;
            Map<Id, Set<String>> applicationWithCadenceMapContact = NurturingTrackService.getApplicantIdsWithCompletedCadence(
                new List<Completed_Cadence__c>{cadence1},
                Contact.getSObjectType(),
                false
            );
            System.assertEquals(1,applicationWithCadenceMapContact.size(),'Cadence map should not be empty');
            Map<Id, Set<String>> applicationWithCadenceMapLead = NurturingTrackService.getApplicantIdsWithCompletedCadence(
                new List<Completed_Cadence__c>{cadence2},
                Lead.getSObjectType(),
                false
            );
            System.assertEquals(1,applicationWithCadenceMapLead.size(),'Cadence map should not be empty');
            applicationWithCadenceMapContact = NurturingTrackService.getApplicantIdsWithCompletedCadence(
                new List<Completed_Cadence__c>{cadence1},
                Contact.getSObjectType(),
                true
            );
            System.assertEquals(1,applicationWithCadenceMapContact.size(),'Cadence map should not be empty');
            applicationWithCadenceMapLead = NurturingTrackService.getApplicantIdsWithCompletedCadence(
                new List<Completed_Cadence__c>{cadence2},
                Lead.getSObjectType(),
                true
            );
            System.assertEquals(1,applicationWithCadenceMapLead.size(),'Cadence map should not be empty');
            Test.stopTest();
        }
    }

    @isTest
    private static void populateCalculatedCadenceMultipleTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            String automatedCadence = 'International Application Submission - Direct Applicant (Automated)';
            String manualCadence = 'International Application Submission - Direct Applicant';
            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            conList[0].recordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
            ContactsDAO.newInstance().insertRecords(conList, false, AccessLevel.SYSTEM_MODE);
            LeadsDAO.newInstance().insertRecords(leadList, false, AccessLevel.SYSTEM_MODE);

            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Cadence_Name__c = 'International Application Submission - Direct Applicant (Automated)';
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

            Completed_cadence__c cadence2 = new Completed_Cadence__c();
            cadence2.Lead__c = leadID;
            cadence2.Nurture_Track_Configuration__c = nurtureList[0].Id;
            cadence2.Completed_Cadence_Status__c ='Successful';
            insert cadence2;
            Map<Id, Set<String>> applicationWithCadenceMapContact = NurturingTrackService.getApplicantIdsWithCompletedCadence(
                new List<Completed_Cadence__c>{cadence1},
                Contact.getSObjectType(),
                false
            );
            Map<Id, Set<String>> applicationWithCadenceMapLead = NurturingTrackService.getApplicantIdsWithCompletedCadence(
                new List<Completed_Cadence__c>{cadence2},
                Lead.getSObjectType(),
                false
            );

            List<hed__Application__c> appListContact = new List<hed__Application__c>();
            hed__Application__c appContact = new hed__Application__c();
            appContact.hed__Applicant__c = contactID;
            appListContact.add(appContact);
            ApplicationsDAO.newInstance().insertRecords(appListContact, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> appListLead = new List<hed__Application__c>();
            hed__Application__c appLead = new hed__Application__c();
            appLead.Lead__c = leadID;
            appListLead.add(appLead);
            ApplicationsDAO.newInstance().insertRecords(appListLead, false, AccessLevel.SYSTEM_MODE);

            NurturingTrackService.CadenceWrapper cad = new NurturingTrackService.CadenceWrapper(Contact.getSObjectType(),automatedCadence,manualCadence);
            List<Contact> contacts = NurturingTrackService.populateCalculatedCadenceMultiple(applicationWithCadenceMapContact,appListContact,cad);
            System.assertEquals(1, contacts.size(),'contact list should not be empty');
            cad = new NurturingTrackService.CadenceWrapper(Lead.getSObjectType(),automatedCadence,manualCadence);
            List<Lead> leads = NurturingTrackService.populateCalculatedCadenceMultiple(applicationWithCadenceMapLead,appListLead,cad);
            System.assertEquals(1, leads.size(),'lead list should not be empty');
            Test.stopTest();
        }
    }

    @isTest
    private static void populateCalculatedCadenceSingleTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            String automatedCadence = 'International Application Submission - Direct Applicant (Automated)';
            String manualCadence = null;
            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            conList[0].recordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
            ContactsDAO.newInstance().insertRecords(conList, false, AccessLevel.SYSTEM_MODE);
            LeadsDAO.newInstance().insertRecords(leadList, false, AccessLevel.SYSTEM_MODE);

            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Cadence_Name__c = 'International Application Submission - Direct Applicant (Automated)';
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

            Completed_cadence__c cadence2 = new Completed_Cadence__c();
            cadence2.Lead__c = leadID;
            cadence2.Nurture_Track_Configuration__c = nurtureList[0].Id;
            cadence2.Completed_Cadence_Status__c ='Successful';
            insert cadence2;
            Map<Id, Set<String>> applicationWithCadenceMapContact = new Map<Id, Set<String>>();
            Map<Id, Set<String>> applicationWithCadenceMapLead = new Map<Id, Set<String>>();

            List<hed__Application__c> appListContact = new List<hed__Application__c>();
            hed__Application__c appContact = new hed__Application__c();
            appContact.hed__Applicant__c = contactID;
            appListContact.add(appContact);
            ApplicationsDAO.newInstance().insertRecords(appListContact, false, AccessLevel.SYSTEM_MODE);

            List<hed__Application__c> appListLead = new List<hed__Application__c>();
            hed__Application__c appLead = new hed__Application__c();
            appLead.Lead__c = leadID;
            appListLead.add(appLead);
            ApplicationsDAO.newInstance().insertRecords(appListLead, false, AccessLevel.SYSTEM_MODE);

            NurturingTrackService.CadenceWrapper cad = new NurturingTrackService.CadenceWrapper(Contact.getSObjectType(),automatedCadence,manualCadence);
            List<Contact> contacts = NurturingTrackService.populateCalculatedCadenceSingle(applicationWithCadenceMapContact,appListContact,cad);
            System.assertEquals(1, contacts.size(),'contact list should not be empty');
            cad = new NurturingTrackService.CadenceWrapper(Lead.getSObjectType(),automatedCadence,manualCadence);
            List<Lead> leads = NurturingTrackService.populateCalculatedCadenceSingle(applicationWithCadenceMapLead,appListLead,cad);
            System.assertEquals(1, leads.size(),'lead list should not be empty');
            Test.stopTest();
        }
    }
    @isTest
    private static void getCurrentIntakePeriodTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<Account> newAccounts = new List<Account>();
            newAccounts.add(TestDataFactory.createTestAccount(false));
            newAccounts[0].RecordTypeId = AccountsDAO.ACCT_UNIV_DEP_ID;
            AccountsDAO.newInstance().insertRecords(newAccounts, false, AccessLevel.SYSTEM_MODE);
            hed__Facility__c facility = new hed__Facility__c(Name = 'U', hed__Facility_Type__c='Classroom');
            insert facility;
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(3, newAccounts[0].Id);
            terms[0].Location__c = facility.Id;
            terms[1].Location__c = facility.Id;
            terms[2].Location__c = facility.Id;
            terms[0].Study_Period_Type_Code__c = 'SEM-1';
            terms[1].Study_Period_Type_Code__c = 'SEM-2';
            terms[2].Study_Period_Type_Code__c = 'SUM';
            terms[0].hed__Start_Date__c = System.today() + 50;
            terms[0].hed__End_Date__c = System.today() + 60;
            terms[1].hed__Start_Date__c = System.today() + 70;
            terms[1].hed__End_Date__c = System.today() + 80;
            terms[2].hed__Start_Date__c = System.today() + 100;
            terms[2].hed__End_Date__c = System.today() + 120;
            insert terms;
            Map<String, Date> currentIntakePeriod= NurturingTrackService.getCurrentIntakePeriod();
            System.assert(currentIntakePeriod!= null, 'currentIntakePeriod is null');
            System.assertEquals(currentIntakePeriod.get('START_DATE'), System.today() + 50, 'Incorrect start date');
            System.assertEquals(currentIntakePeriod.get('END_DATE'), System.today() + 60, 'Incorrect end date');
            Test.stopTest();
        }
    }
    @isTest
    private static void isDateWithinRangeTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            Date dateToCheck = System.today();
            Date lowerDate = System.today().addMonths(-15);
            Date upperDate = System.today().addMonths(15);
            Boolean result = NurturingTrackService.isDateWithinRange(dateToCheck, lowerDate, upperDate);
            System.assert(result, 'isDateWithinRange should return true');
            Test.stopTest();
        }
    }
    @isTest
    private static void isDateWithinRangeFailsafeTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            Date dateToCheck = System.today();
            Date upperDate = System.today().addMonths(-15);
            Date lowerDate = System.today().addMonths(15);
            Boolean result = NurturingTrackService.isDateWithinRange(dateToCheck, lowerDate, upperDate);
            System.assert(result, 'isDateWithinRange should return true');
            Test.stopTest();
        }
    }

    @isTest
    private static void getFilteredApplicantWithCompletedCadenceTest() {//NOPMD Test class is mocked
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        List<Contact> contactList = TestDataFactory.createTestContactRecords(0, 2);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        Set<Id> applicantIdSet = new Set<Id>{ contactList[0].Id, contactList[1].Id };

        Map<Id, Set<String>> applicantIdsWithCompletedCadence = new Map<Id, Set<String>>{
            contactList[0].Id => new Set<String>{
                NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED,
                NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL
            },
            contactList[1].Id => new Set<String>{
                NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL
            }
        };

        System.assert(
            NurturingTrackService.getFilteredApplicantWithCompletedCadence(
                    applicantIdSet,
                    new List<String>{
                        NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED
                    },
                    applicantIdsWithCompletedCadence
                )
                .keySet()
                .size() == 1,
            'filtered applicant to completed cadence map size should be 1'
        );
        System.assert(
            NurturingTrackService.getFilteredApplicantWithCompletedCadence(
                    applicantIdSet,
                    new List<String>{
                        NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
                        NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED
                    },
                    applicantIdsWithCompletedCadence
                )
                .keySet()
                .size() == 2,
            'filtered applicant to completed cadence map size should be 2'
        );
    }

    @isTest
    private static void getApplicantIdToRelatedCaseCategoriesMapTest() { //NOPMD Test class is mocked
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadsDAOMock());
        ImplementationSelector.DAO.setMock(new CasesDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(0, 1);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
        LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.USER_MODE);

        List<Case> caseList = TestDataFactory.createTestCaseRecords(1, null, contactList);
        caseList.addAll(TestDataFactory.createTestCaseRecords(1, leadList, null));
        caseList[0].Category__c = 'Category 1';
        caseList[1].Category__c = 'Category 2';
        CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.USER_MODE);

        System.assert(
            !NurturingTrackService.getApplicantIdToRelatedCaseCategoriesMap(
                    new Set<Id>{ contactList[0].Id, leadList[0].Id },
                    1
                )
                .keySet()
                .isEmpty(),
            'applicantidtorelatedcasecategoriesmap should not be empty'
        );
    }
}