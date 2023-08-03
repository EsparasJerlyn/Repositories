@isTest
public with sharing class NurturingTrackServiceTest {

    @TestSetup
    static void makeData(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    private static void getNurturingTrackRecordsTest() {
            System.runAs(TestDataFactory.getProgramAdminUser()) {
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
    private static void getApplicationIdsWithCompletedCadence(){
        System.runAs(TestDataFactory.getProgramAdminUser()) {
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
            insert cadence1;

            Completed_cadence__c cadence2 = new Completed_Cadence__c();
            cadence2.Lead__c = leadID;
            cadence2.Nurture_Track_Configuration__c = nurtureList[0].Id;
            insert cadence2;
            Map<Id, List<String>> applicationWithCadenceMapContact = NurturingTrackService.getApplicationIdsWithCompletedCadence(new Set<Id>{contactID},new Set<String>{'International Application Submission - Direct Applicant (Automated)'},Contact.getSObjectType());
            System.assertEquals(1,applicationWithCadenceMapContact.size(),'Cadence map should not be empty');
            Map<Id, List<String>> applicationWithCadenceMapLead = NurturingTrackService.getApplicationIdsWithCompletedCadence(new Set<Id>{leadID},new Set<String>{'International Application Submission - Direct Applicant (Automated)'},Lead.getSObjectType());
            System.assertEquals(1,applicationWithCadenceMapLead.size(),'Cadence map should not be empty');
            Test.stopTest();
        }
    }

    @isTest
    private static void populateCalculatedCadenceMultipleTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()) {
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
            insert cadence1;

            Completed_cadence__c cadence2 = new Completed_Cadence__c();
            cadence2.Lead__c = leadID;
            cadence2.Nurture_Track_Configuration__c = nurtureList[0].Id;
            insert cadence2;
            Map<Id, List<String>> applicationWithCadenceMapContact = NurturingTrackService.getApplicationIdsWithCompletedCadence(new Set<Id>{contactID},new Set<String>{'International Application Submission - Direct Applicant (Automated)'},Contact.getSObjectType());
            Map<Id, List<String>> applicationWithCadenceMapLead = NurturingTrackService.getApplicationIdsWithCompletedCadence(new Set<Id>{leadID},new Set<String>{'International Application Submission - Direct Applicant (Automated)'},Lead.getSObjectType());

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
        System.runAs(TestDataFactory.getProgramAdminUser()) {
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
            insert cadence1;

            Completed_cadence__c cadence2 = new Completed_Cadence__c();
            cadence2.Lead__c = leadID;
            cadence2.Nurture_Track_Configuration__c = nurtureList[0].Id;
            insert cadence2;
            Map<Id, List<String>> applicationWithCadenceMapContact = new Map<Id, List<String>>();
            Map<Id, List<String>> applicationWithCadenceMapLead = new Map<Id, List<String>>();

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
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            accounts[0].RecordTypeId = AccountsDAO.ACCT_UNIV_DEP_ID;
            AccountsDAO.newInstance().insertRecords(accounts, false, AccessLevel.USER_MODE);
            hed__Facility__c facility = new hed__Facility__c(Name = 'U', hed__Facility_Type__c='Classroom');
            insert facility;
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(3, accounts[0].Id);
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
        System.runAs(TestDataFactory.getProgramAdminUser()){
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
        System.runAs(TestDataFactory.getProgramAdminUser()){
            Test.startTest();
            Date dateToCheck = System.today();
            Date upperDate = System.today().addMonths(-15);
            Date lowerDate = System.today().addMonths(15);
            Boolean result = NurturingTrackService.isDateWithinRange(dateToCheck, lowerDate, upperDate);

            System.assert(result, 'isDateWithinRange should return true');
            Test.stopTest();
        }
    }
}