/**
 * @description Test Class for MarketingStagingHandlerTrigger
 * @see ..MarketingStagingHandlerTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 23, 2022          | DEPP-2103              | Created file                 |
 */

@IsTest(SeeAllData=false)
public with sharing class MarketingStagingTriggerHandlerTest {
    @IsTest
    public static void testOneContactMatch() {
        Test.startTest();
        Contact newCon = new Contact(  FirstName = 'Test1', 
                                        QUT_Student_ID__c='123456', 
                                        LastName = 'Test1 LastName', 
                                        Email = 'Test1@email.com', 
                                        Company_Name__c = 'test company'
                                        );
        insert newCon;
        List<Marketing_Staging__c> msList = new List<Marketing_Staging__c>();
        msList.add(new Marketing_Staging__c());
        msList[0].First_Name__c = 'Test1';
        msList[0].Last_Name__c = 'Test1 LastName';
        msList[0].Email__c = 'Test1@email.com';
        msList[0].QUT_Student_ID__c = '123456';
        msList[0].Salutation__c = 'Mr';
        msList[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList[0].Interaction_DateTime__c = Date.Today();
        msList[0].Lead_Source_Category__c = 'Enquiry';
        msList[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList[0].SPAD__c = 'TESTSPAD1';
        msList[0].Event_Name__c = 'TESTEVENTNAME1';

        insert msList;
        Contact contact = [  SELECT Id, 
                            (SELECT Id FROM Marketing_Segmentations__r ),
                            (SELECT Id FROM Marketing_Course_Applications__r ),
                            (SELECT Id FROM Marketing_Interactions__r ) 
                            FROM Contact WHERE Salutation = 'Mr' 
                            LIMIT 1];
        system.assert(contact != null,'No contact created');
        system.assert(!contact.Marketing_Segmentations__r.isEmpty(),'No Marketing segmentation created');
        system.assert(!contact.Marketing_Interactions__r.isEmpty(),'No Marketing interaction created');
        Test.stopTest();
    }

    @IsTest
    public static void testOneContactMatchNoId() {
        Test.startTest();
        Contact newCon = new Contact(   FirstName = 'Test1',  
                                        LastName = 'Test1 LastName', 
                                        Email = 'Test1@email.com', 
                                        Company_Name__c = 'test company'
                                        );
        insert newCon;

        system.debug([  SELECT Id, Name_and_Email__c
        FROM Contact]);
        List<Marketing_Staging__c> msList = new List<Marketing_Staging__c>();
        msList.add(new Marketing_Staging__c());
        msList[0].First_Name__c = 'Test1';
        msList[0].Last_Name__c = 'Test1 LastName';
        msList[0].Email__c = 'Test1@email.com';
        msList[0].Salutation__c = 'Mr';
        msList[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList[0].Interaction_DateTime__c = Date.Today();
        msList[0].Lead_Source_Category__c = 'Enquiry';
        msList[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList[0].SPAD__c = 'TESTSPAD1';
        msList[0].Event_Name__c = 'TESTEVENTNAME1';

        insert msList;
        Contact contact = [  SELECT Id, 
                            (SELECT Id FROM Marketing_Segmentations__r ),
                            (SELECT Id FROM Marketing_Course_Applications__r ),
                            (SELECT Id FROM Marketing_Interactions__r ) 
                            FROM Contact WHERE Salutation = 'Mr' 
                            LIMIT 1];
        system.assert(contact != null,'No contact created');
        system.assert(!contact.Marketing_Segmentations__r.isEmpty(),'No Marketing segmentation created');
        system.assert(!contact.Marketing_Interactions__r.isEmpty(),'No Marketing interaction created');
        Test.stopTest();
    }


    @IsTest
    public static void testOneContactMatchSegAppQTACTest() {
        
        Test.startTest();

        Contact newCon = new Contact(  FirstName = 'Test1', 
                                        LastName = 'Test1 LastName', 
                                        Email = 'Test1@email.com', 
                                        Company_Name__c = 'test company'
                                        );
        insert newCon;
        List<Marketing_Staging__c> msList = new List<Marketing_Staging__c>();
        msList.add(new Marketing_Staging__c());
        msList[0].First_Name__c = 'Test1';
        msList[0].Last_Name__c = 'Test1 LastName';
        msList[0].Email__c = 'Test1@email.com';
        msList[0].Salutation__c = 'Mr';
        msList[0].Applicant_Id__c = '12345';
        msList[0].Preference_Number__c = 1;
        msList[0].Application_Source__c = 'QTAC';
        msList[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList[0].Interaction_DateTime__c = Date.Today();
        msList[0].Lead_Source_Category__c = 'Enquiry';
        msList[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList[0].SPAD__c = 'TESTSPAD1';
        msList[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList;

        List<Marketing_Staging__c> msList2 = new List<Marketing_Staging__c>();
        msList2.add(new Marketing_Staging__c());
        msList2[0].First_Name__c = 'Test1';
        msList2[0].Last_Name__c = 'Test1 LastName';
        msList2[0].Email__c = 'Test1@email.com';
        msList2[0].Salutation__c = 'Mr';
        msList2[0].Applicant_Id__c = '12345';
        msList2[0].Preference_Number__c = 1;
        msList2[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList2[0].Interaction_DateTime__c = Date.Today();
        msList2[0].Lead_Source_Category__c = 'Enquiry';
        msList2[0].Application_Source__c = 'QTAC';
        msList2[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList2[0].SPAD__c = 'TESTSPAD1';
        msList2[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList2;

        Contact contact = [    SELECT Id, 
                            (SELECT Id FROM Marketing_Segmentations__r ),
                            (SELECT Id FROM Marketing_Course_Applications__r ),
                            (SELECT Id FROM Marketing_Interactions__r ) 
                            FROM Contact WHERE Salutation = 'Mr'  
                            LIMIT 1];
        system.assert(contact != null,'No contact created');
        system.assert(!contact.Marketing_Segmentations__r.isEmpty(),'No Marketing segmentation created');
        system.assert(!contact.Marketing_Interactions__r.isEmpty(),'No Marketing interaction created');

        Test.stopTest();
    }

    @IsTest
    public static void testOneContactMatchWithIdSegAppQTACTest() {
        
        Test.startTest();

        Contact newCon = new Contact(  FirstName = 'Test1', 
                                        QUT_Student_ID__c='123456', 
                                        LastName = 'Test1 LastName', 
                                        Email = 'Test1@email.com', 
                                        Company_Name__c = 'test company'
                                        );
        insert newCon;
        List<Marketing_Staging__c> msList = new List<Marketing_Staging__c>();
        msList.add(new Marketing_Staging__c());
        msList[0].First_Name__c = 'Test1';
        msList[0].Last_Name__c = 'Test1 LastName';
        msList[0].Email__c = 'Test1@email.com';
        msList[0].Salutation__c = 'Mr';
        msList[0].QUT_Student_ID__c = '123456';
        msList[0].Applicant_Id__c = '12345';
        msList[0].Preference_Number__c = 1;
        msList[0].Application_Source__c = 'QTAC';
        msList[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList[0].Interaction_DateTime__c = Date.Today();
        msList[0].Lead_Source_Category__c = 'Enquiry';
        msList[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList[0].SPAD__c = 'TESTSPAD1';
        msList[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList;

        List<Marketing_Staging__c> msList2 = new List<Marketing_Staging__c>();
        msList2.add(new Marketing_Staging__c());
        msList2[0].First_Name__c = 'Test1';
        msList2[0].Last_Name__c = 'Test1 LastName';
        msList2[0].Email__c = 'Test1@email.com';
        msList2[0].Salutation__c = 'Mr';
        msList2[0].QUT_Student_ID__c = '123456';
        msList2[0].Applicant_Id__c = '12345';
        msList2[0].Preference_Number__c = 1;
        msList2[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList2[0].Interaction_DateTime__c = Date.Today();
        msList2[0].Lead_Source_Category__c = 'Enquiry';
        msList2[0].Application_Source__c = 'QTAC';
        msList2[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList2[0].SPAD__c = 'TESTSPAD1';
        msList2[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList2;

        Contact contact = [    SELECT Id, 
                            (SELECT Id FROM Marketing_Segmentations__r ),
                            (SELECT Id FROM Marketing_Course_Applications__r ),
                            (SELECT Id FROM Marketing_Interactions__r ) 
                            FROM Contact WHERE Salutation = 'Mr'  
                            LIMIT 1];
        system.assert(contact != null,'No contact created');
        system.assert(!contact.Marketing_Segmentations__r.isEmpty(),'No Marketing segmentation created');
        system.assert(!contact.Marketing_Interactions__r.isEmpty(),'No Marketing interaction created');

        Test.stopTest();
    }

    @IsTest
    public static void testTwoContactMatch() {

        Test.startTest();

        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(    FirstName = 'Test1', 
                                        QUT_Student_ID__c='123456', 
                                        LastName = 'Test1 LastName', 
                                        Email = 'Test1@email.com', 
                                        Company_Name__c = 'test company'
                                    ));

        contactList.add(new Contact(    FirstName = 'Test1', 
                                        QUT_Student_ID__c='123456', 
                                        LastName = 'Test1 LastName', 
                                        Email = 'Test1@email.com', 
                                        Company_Name__c = 'test company2'
                                    ));
        insert contactList;
        List<Marketing_Staging__c> msList = new List<Marketing_Staging__c>();
        msList.add(new Marketing_Staging__c());
        msList[0].First_Name__c = 'Test1';
        msList[0].Last_Name__c = 'Test1 LastName';
        msList[0].Email__c = 'Test1@email.com';
        msList[0].QUT_Student_ID__c = '123456';
        msList[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList[0].Interaction_DateTime__c = Date.Today();
        msList[0].Lead_Source_Category__c = 'Enquiry';
        msList[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList[0].SPAD__c = 'TESTSPAD1';
        msList[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList;

        Lead newLead = [    SELECT Id, 
                            (SELECT Id FROM Marketing_Segmentations__r ),
                            (SELECT Id FROM Marketing_Interactions__r ) 
                            FROM Lead WHERE Lead_Type__c = 'Learner' 
                            LIMIT 1];

        system.assert(newLead != null,'No lead created');
        system.assert(!newLead.Marketing_Segmentations__r.isEmpty(),'No Marketing segmentation created');
        system.assert(!newLead.Marketing_Interactions__r.isEmpty(),'No Marketing interaction created');

        Test.stopTest();
    }

    @IsTest
    public static void testTwoContactMatchNoId() {

        Test.startTest();

        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(    FirstName = 'Test1',  
                                        LastName = 'Test1 LastName', 
                                        Email = 'Test1@email.com', 
                                        Company_Name__c = 'test company'
                                    ));

        contactList.add(new Contact(    FirstName = 'Test1', 
                                        QUT_Student_ID__c='123456', 
                                        LastName = 'Test1 LastName', 
                                        Email = 'Test1@email.com', 
                                        Company_Name__c = 'test company2'
                                    ));
        insert contactList;
        List<Marketing_Staging__c> msList = new List<Marketing_Staging__c>();
        msList.add(new Marketing_Staging__c());
        msList[0].First_Name__c = 'Test1';
        msList[0].Last_Name__c = 'Test1 LastName';
        msList[0].Email__c = 'Test1@email.com';
        msList[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList[0].Interaction_DateTime__c = Date.Today();
        msList[0].Lead_Source_Category__c = 'Enquiry';
        msList[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList[0].SPAD__c = 'TESTSPAD1';
        msList[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList;

        Lead newLead = [    SELECT Id, 
                            (SELECT Id FROM Marketing_Segmentations__r ),
                            (SELECT Id FROM Marketing_Interactions__r ) 
                            FROM Lead WHERE Lead_Type__c = 'Learner' 
                            LIMIT 1];

        system.assert(newLead != null,'No lead created');
        system.assert(!newLead.Marketing_Segmentations__r.isEmpty(),'No Marketing segmentation created');
        system.assert(!newLead.Marketing_Interactions__r.isEmpty(),'No Marketing interaction created');

        Test.stopTest();
    }

    @IsTest
    public static void testOneLeadMatch() {

        Test.startTest();

        Lead lead = new Lead(FirstName = 'Test1', LastName = 'Test1 LastName', Email = 'Test1@email.com', Company ='Test Company');
        insert lead;
        List<Marketing_Staging__c> msList = new List<Marketing_Staging__c>();
        msList.add(new Marketing_Staging__c());
        msList[0].First_Name__c = 'Test1';
        msList[0].Last_Name__c = 'Test1 LastName';
        msList[0].Email__c = 'Test1@email.com';
        msList[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList[0].Interaction_DateTime__c = Date.Today();
        msList[0].Lead_Source_Category__c = 'Enquiry';
        msList[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList[0].SPAD__c = 'TESTSPAD1';
        msList[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList;

        Lead newLead = [    SELECT Id, 
                            (SELECT Id FROM Marketing_Segmentations__r ),
                            (SELECT Id FROM Marketing_Interactions__r ) 
                            FROM Lead WHERE Lead_Type__c = 'Learner' 
                            LIMIT 1];

        system.assert(newLead != null,'No lead created');
        system.assert(!newLead.Marketing_Segmentations__r.isEmpty(),'No Marketing segmentation created');
        system.assert(!newLead.Marketing_Interactions__r.isEmpty(),'No Marketing interaction created');

        Test.stopTest();
    }

    @IsTest
    public static void testOneLeadMatchSegAppStudylinkTest() {

        Test.startTest();

        Lead lead = new Lead(FirstName = 'Test1', LastName = 'Test1 LastName', Email = 'Test1@email.com', Company ='Test Company');
        insert lead;
        List<Marketing_Staging__c> msList = new List<Marketing_Staging__c>();
        msList.add(new Marketing_Staging__c());
        msList[0].First_Name__c = 'Test1';
        msList[0].Last_Name__c = 'Test1 LastName';
        msList[0].Email__c = 'Test1@email.com';
        msList[0].Applicant_Id__c = '12345';
        msList[0].Preference_Number__c = 1;
        msList[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList[0].Interaction_DateTime__c = Date.Today();
        msList[0].Lead_Source_Category__c = 'Enquiry';
        msList[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList[0].Application_Source__c = 'Studylink';
        msList[0].Application_Id__c = '12345';
        msList[0].QUT_Student_ID__c = '12345';
        msList[0].Admission_Period__c ='12345';
        msList[0].Course_Code__c = '12345';
        msList[0].Admission_Year__c = 2202;
        msList[0].SPAD__c = 'TESTSPAD1';
        msList[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList;

        List<Marketing_Staging__c> msList2 = new List<Marketing_Staging__c>();
        msList2.add(new Marketing_Staging__c());
        msList2[0].First_Name__c = 'Test1';
        msList2[0].Last_Name__c = 'Test1 LastName';
        msList2[0].Email__c = 'Test1@email.com';
        msList2[0].Applicant_Id__c = '12345';
        msList2[0].Preference_Number__c = 1;
        msList2[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList2[0].Interaction_DateTime__c = Date.Today();
        msList2[0].Lead_Source_Category__c = 'Enquiry';
        msList2[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList2[0].Application_Id__c = '12345';
        msList2[0].Application_Source__c = 'Studylink';
        msList2[0].QUT_Student_ID__c = '12345';
        msList2[0].Admission_Period__c ='12345';
        msList2[0].Course_Code__c = '12345';
        msList2[0].Admission_Year__c = 2202;
        msList2[0].SPAD__c = 'TESTSPAD1';
        msList2[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList2;

        Lead newLead = [    SELECT Id, 
                            (SELECT Id FROM Marketing_Segmentations__r ),
                            (SELECT Id FROM Marketing_Course_Applications__r ),
                            (SELECT Id FROM Marketing_Interactions__r ) 
                            FROM Lead WHERE Lead_Type__c = 'Learner' 
                            LIMIT 1];

        system.assert(newLead != null,'No lead created');
        system.assert(!newLead.Marketing_Segmentations__r.isEmpty(),'No Marketing segmentation created');
        system.assert(!newLead.Marketing_Course_Applications__r.isEmpty(),'No Marketing application created');
        system.assert(!newLead.Marketing_Interactions__r.isEmpty(),'No Marketing interaction created');

        Test.stopTest();
    }

    @IsTest
    public static void testOneLeadMatchSegAppQTACTest() {

        Test.startTest();

        Lead lead = new Lead(FirstName = 'Test1', LastName = 'Test1 LastName', Email = 'Test1@email.com', Company ='Test Company');
        insert lead;
        List<Marketing_Staging__c> msList = new List<Marketing_Staging__c>();
        msList.add(new Marketing_Staging__c());
        msList[0].First_Name__c = 'Test1';
        msList[0].Last_Name__c = 'Test1 LastName';
        msList[0].Email__c = 'Test1@email.com';
        msList[0].Applicant_Id__c = '12345';
        msList[0].Preference_Number__c = 1;
        msList[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList[0].Interaction_DateTime__c = Date.Today();
        msList[0].Lead_Source_Category__c = 'Enquiry';
        msList[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList[0].Application_Source__c = 'QTAC';
        msList[0].QUT_Student_ID__c = '12345';
        msList[0].Admission_Period__c ='12345';
        msList[0].Course_Code__c = '12345';
        msList[0].Admission_Year__c = 2202;
        msList[0].SPAD__c = 'TESTSPAD1';
        msList[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList;

        List<Marketing_Staging__c> msList2 = new List<Marketing_Staging__c>();
        msList2.add(new Marketing_Staging__c());
        msList2[0].First_Name__c = 'Test1';
        msList2[0].Last_Name__c = 'Test1 LastName';
        msList2[0].Email__c = 'Test1@email.com';
        msList2[0].Applicant_Id__c = '12345';
        msList2[0].Preference_Number__c = 1;
        msList2[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList2[0].Interaction_DateTime__c = Date.Today();
        msList2[0].Lead_Source_Category__c = 'Enquiry';
        msList2[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList2[0].Application_Source__c = 'QTAC';
        msList2[0].QUT_Student_ID__c = '12345';
        msList2[0].Admission_Period__c ='12345';
        msList2[0].Course_Code__c = '12345';
        msList2[0].Admission_Year__c = 2202;
        msList2[0].SPAD__c = 'TESTSPAD1';
        msList2[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList2;

        Lead newLead = [    SELECT Id, 
                            (SELECT Id FROM Marketing_Segmentations__r ),
                            (SELECT Id FROM Marketing_Course_Applications__r ),
                            (SELECT Id FROM Marketing_Interactions__r ) 
                            FROM Lead WHERE Lead_Type__c = 'Learner' 
                            LIMIT 1];

        system.assert(newLead != null,'No lead created');
        system.assert(!newLead.Marketing_Segmentations__r.isEmpty(),'No Marketing segmentation created');
        system.assert(!newLead.Marketing_Course_Applications__r.isEmpty(),'No Marketing application created');
        system.assert(!newLead.Marketing_Interactions__r.isEmpty(),'No Marketing interaction created');

        Test.stopTest();
    }

    @IsTest
    public static void testTwoLeadMatch() {

        Test.startTest();

        List<Lead> leadList = new List<Lead>();
        leadList.add(new Lead(FirstName = 'Test1', LastName = 'Test1 LastName', Email = 'Test1@email.com', Company ='Test Company'));
        leadList.add(new Lead(FirstName = 'Test1', LastName = 'Test1 LastName2', Email = 'Test1@email.com', Company ='Test Company'));
        insert leadList;
        Lead leadToUpdate = new Lead(Id = leadList[1].Id, LastName = 'Test1 LastName');
        update leadToUpdate;
        List<Marketing_Staging__c> msList = new List<Marketing_Staging__c>();
        msList.add(new Marketing_Staging__c());
        msList[0].First_Name__c = 'Test1';
        msList[0].Last_Name__c = 'Test1 LastName';
        msList[0].Email__c = 'Test1@email.com';
        msList[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList[0].Interaction_DateTime__c = Date.Today();
        msList[0].Lead_Source_Category__c = 'Enquiry';
        msList[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList[0].SPAD__c = 'TESTSPAD1';
        msList[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList;

        Lead newLead = [    SELECT Id, 
                            (SELECT Id FROM Marketing_Segmentations__r ),
                            (SELECT Id FROM Marketing_Interactions__r ) 
                            FROM Lead WHERE Lead_Type__c = 'Learner' 
                            LIMIT 1];

        system.assert(newLead != null,'No lead created');
        system.assert(!newLead.Marketing_Segmentations__r.isEmpty(),'No Marketing segmentation created');
        system.assert(!newLead.Marketing_Interactions__r.isEmpty(),'No Marketing interaction created');

        Test.stopTest();
    }

    @IsTest
    public static void testTwoLeadMatchWithSegmentationAndApplication() {
        
        Test.startTest();

        List<Lead> leadList = new List<Lead>();
        leadList.add(new Lead(FirstName = 'Test1', LastName = 'Test1 LastName', Email = 'Test1@email.com', Company ='Test Company'));
        leadList.add(new Lead(FirstName = 'Test1', LastName = 'Test1 LastName2', Email = 'Test1@email.com', Company ='Test Company'));
        insert leadList;
        Lead leadToUpdate = new Lead(Id = leadList[1].Id, LastName = 'Test1 LastName');
        update leadToUpdate;
        List<Marketing_Staging__c> msList = new List<Marketing_Staging__c>();
        msList.add(new Marketing_Staging__c());
        msList[0].First_Name__c = 'Test1';
        msList[0].Last_Name__c = 'Test1 LastName';
        msList[0].Email__c = 'Test1@email.com';
        msList[0].Applicant_Id__c = '12345';
        msList[0].Preference_Number__c = 1;
        msList[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList[0].Interaction_DateTime__c = Date.Today();
        msList[0].Lead_Source_Category__c = 'Enquiry';
        msList[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList[0].SPAD__c = 'TESTSPAD1';
        msList[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList;

        List<Marketing_Staging__c> msList2 = new List<Marketing_Staging__c>();
        msList2.add(new Marketing_Staging__c());
        msList2[0].First_Name__c = 'Test1';
        msList2[0].Last_Name__c = 'Test1 LastName';
        msList2[0].Email__c = 'Test1@email.com';
        msList2[0].Applicant_Id__c = '12345';
        msList2[0].Preference_Number__c = 1;
        msList2[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList2[0].Interaction_DateTime__c = Date.Today();
        msList2[0].Lead_Source_Category__c = 'Enquiry';
        msList2[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList2[0].SPAD__c = 'TESTSPAD1';
        msList2[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList2;

        Lead newLead = [    SELECT Id, 
                            (SELECT Id FROM Marketing_Segmentations__r ),
                            (SELECT Id FROM Marketing_Course_Applications__r ),
                            (SELECT Id FROM Marketing_Interactions__r ) 
                            FROM Lead WHERE Lead_Type__c = 'Learner' 
                            LIMIT 1];

        system.assert(newLead != null,'No lead created');
        system.assert(!newLead.Marketing_Segmentations__r.isEmpty(),'No Marketing segmentation created');
        //system.assert(!newLead.Marketing_Course_Applications__r.isEmpty(),'No Marketing course application created');
        system.assert(!newLead.Marketing_Interactions__r.isEmpty(),'No Marketing interaction created');

        Test.stopTest();
    }

    @IsTest
    public static void testNoMatch() {

        Test.startTest();

        List<Marketing_Staging__c> msList = new List<Marketing_Staging__c>();
        msList.add(new Marketing_Staging__c());
        msList[0].First_Name__c = 'Test1';
        msList[0].Last_Name__c = 'Test1 LastName';
        msList[0].Email__c = 'Test1@email.com';
        msList[0].Preference_Number__c = 1;
        msList[0].Interaction_Type__c = 'TESTINERACTIONTYPE1';
        msList[0].Interaction_DateTime__c = Date.Today();
        msList[0].Lead_Source_Category__c = 'Enquiry';
        msList[0].Lead_Source__c = 'TESTLEADSOURCE1';
        msList[0].SPAD__c = 'TESTSPAD1';
        msList[0].Event_Name__c = 'TESTEVENTNAME1';
        insert msList;

        Lead newLead = [    SELECT Id, 
                            (SELECT Id FROM Marketing_Segmentations__r ),
                            (SELECT Id FROM Marketing_Course_Applications__r ),
                            (SELECT Id FROM Marketing_Interactions__r ) 
                            FROM Lead WHERE Lead_Type__c = 'Learner' 
                            LIMIT 1];
                            
        system.assert(newLead != null,'No lead created');
        system.assert(!newLead.Marketing_Segmentations__r.isEmpty(),'No Marketing segmentation created');
        system.assert(!newLead.Marketing_Interactions__r.isEmpty(),'No Marketing Interaction created');

        Test.stopTest();
    }

    @IsTest
    public static void testBulkMatchContacts(){
        
        Test.startTest();
        List<Contact> contactList = new List<Contact>();
        for(Integer i = 0; i < 50; i++){
            contactList.add(new Contact(FirstName = 'Test' + i, LastName = 'Contact' + i, Email = 'TestEmail@email.com' + i, Company_Name__c = 'test company', QUT_Student_ID__c = '12345' + i));
        }
        for(Integer i = 0; i < 30; i++){
            contactList.add(new Contact(FirstName = 'Test' + i, LastName = 'Contact' + i, Email = 'TestEmail@email.com' + i, Company_Name__c = 'test company', QUT_Student_ID__c = '12345' + i));
        }
        insert contactList;
        List<Marketing_Staging__c> msList = new List<Marketing_Staging__c>();
        for(Integer i = 0; i < 50; i++){
            msList.add(new Marketing_Staging__c(First_Name__c = 'Test' + i, Last_Name__c = 'Contact' + i, Email__c = 'TestEmail@email.com' + i, Salutation__c = 'Mr', QUT_Student_ID__c = '12345' + i,
            Application_Source__c = 'SAMS', Admission_Period__c = '12', Course_Code__c = '12345', Admission_Year__c = 2220 ));
        }
        insert msList;

        List<Contact> conList = [  SELECT Id FROM Contact WHERE Salutation = 'Mr' 
                            LIMIT 50 ];

        List<Lead> lList = [  SELECT Id FROM Lead LIMIT 50];
        system.assert(!conList.isEmpty(),'No Contacts Updated');
        system.assert(!lList.isEmpty(),'No leads created');

        Test.stopTest();


    }

    @IsTest
    public static void testBulkMatchLeads(){
        
        Test.startTest();
        List<Lead> leadList = new List<Lead>();
        List<Lead> leadListtoUpdate = new List<Lead>();
        for(Integer i = 0; i < 50; i++){
            leadList.add(new Lead(FirstName = 'Test' + i, LastName = 'Lead' + i, Email = 'TestEmail@email.com' + i, Company = 'Learner'));
        }
        insert leadList;
        for(Integer i = 30; i < 50; i++){
            integer y = i - 30;
            leadListtoUpdate.add(new Lead(Id=leadList[i].Id, FirstName = 'Test' + y, LastName = 'Lead' + y, Email = 'TestEmail@email.com' + y));                                                                                                                                    
        }
        update leadListtoUpdate; //update lead to match and create duplicates

        List<Marketing_Staging__c> msList = new List<Marketing_Staging__c>();
        for(Integer i = 0; i < 50; i++){
            msList.add(new Marketing_Staging__c(First_Name__c = 'Test' + i, Last_Name__c = 'Lead' + i, Email__c = 'TestEmail@email.com' + i, Salutation__c = 'Mr',
            Application_Source__c ='QTAC', Applicant_Id__c ='12345', Preference_Number__c = 1));
        }
        insert msList;

        List<Lead> lList = [  SELECT Id FROM Lead WHERE Salutation = 'Mr'LIMIT 50];
        List<Lead> newLeadList =  [SELECT Id FROM Lead WHERE ID NOT IN:leadListtoUpdate AND ID NOT IN:leadList ];               
        system.assert(!lList.isEmpty(),'No Lead Updated');
        system.assert(!newLeadList.isEmpty(),'No Lead created');

        Test.stopTest();


    }

 }