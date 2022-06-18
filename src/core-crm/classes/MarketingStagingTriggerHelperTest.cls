/**
 * @description Test Class for MarketingStagingTriggerHelper
 * @see ..MarketingStagingTriggerHelper
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
public with sharing class MarketingStagingTriggerHelperTest {

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
        system.assert(contact != null,'No Marketing contact created');
        system.assert(!contact.Marketing_Segmentations__r.isEmpty(),'No Marketing segmentation created');
        system.assert(!contact.Marketing_Interactions__r.isEmpty(),'No Marketing segmentation created');
        Test.stopTest();
    }


    @IsTest
    public static void testOneContactMatchWithSegmentationAndApplication() {
        
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
        system.assert(contact != null,'No Marketing contact created');
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

        system.assert(newLead != null,'No Marketing Lead created');
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

        system.assert(newLead != null,'No Marketing Lead created');
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
        msList2[0].Application_Source__c = 'Studylink';
        msList2[0].QUT_Student_ID__c = '12345';
        msList2[0].Application_Id__c = '12345';
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

        system.assert(newLead != null,'No Marketing lead created');
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
                            
        system.assert(newLead != null,'No Marketing lead created');
        system.assert(!newLead.Marketing_Segmentations__r.isEmpty(),'No Marketing segmentation created');
        system.assert(!newLead.Marketing_Interactions__r.isEmpty(),'No Marketing Interaction created');

        Test.stopTest();
    }

 }