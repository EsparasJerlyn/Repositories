/**
* @description Test Class for Lead Scoring
* @see ..
*
* @author Accenture
*
* @history
*
*    | Developer                | Date                  | JIRA                   | Change Summary               |
     |--------------------------------|-----------------------|------------------|------------------------------|
     | w.li                     | June 15, 2022         | DEPP-1058              | Created file                 |
     | alexander.cadalin        | February 20, 2023     | PMD                    | ApexUnitTestClassShouldHaveAsserts
*/

@isTest
public without sharing class LeadScoringManagerTest {
    @testSetup static void setup() {
        // Generate test users.
        TestDataFactory.generateTestUsers();
    }

    @isTest
    public static void testOneContactMatch() {
        Contact contact;
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            
            contact = new Contact(FirstName = 'Test1',
                                        QUT_Student_ID__c='123456',
                                        LastName = 'Test1 LastName',
                                        Email = 'Test1@email.com',
                                        Company_Name__c = 'test company'
                                        );
            insert contact;

            et4ae5__SendDefinition__c sendDefinition = new et4ae5__SendDefinition__c();
            insert sendDefinition;

            et4ae5__IndividualEmailResult__c individualEmailResult = new et4ae5__IndividualEmailResult__c();
            individualEmailResult.Name = 'Test';
            individualEmailResult.et4ae5__SendDefinition__c = sendDefinition.Id;
            individualEmailResult.Primary_Contact__c = contact.Id;
            insert individualEmailResult;

            Test.startTest();

            Marketing_Staging__c marketingStaging = new Marketing_Staging__c();
            marketingStaging.First_Name__c = 'Test1';
            marketingStaging.Last_Name__c = 'Test1 LastName';
            marketingStaging.Email__c = 'Test1@email.com';
            marketingStaging.Applicant_Id__c = '12345';
            marketingStaging.Preference_Number__c = 1;
            marketingStaging.Application_Source__c = 'Studylink';
            marketingStaging.Application_Id__c = '12345';
            marketingStaging.Admission_Period__c ='12345';
            marketingStaging.Course_Code__c = '12345';
            marketingStaging.Admission_Year__c = 2202;
            marketingStaging.QUT_Student_ID__c = '123456';
            marketingStaging.Salutation__c = 'Mr';
            marketingStaging.Interaction_Type__c = 'TESTINERACTIONTYPE1';
            marketingStaging.Interaction_DateTime__c = Date.Today();
            marketingStaging.Lead_Source_Category__c = 'Enquiry';
            marketingStaging.Lead_Source__c = 'TESTLEADSOURCE1';
            marketingStaging.SPAD__c = 'TESTSPAD1';
            marketingStaging.Event_Name__c = 'TESTEVENTNAME1';
            insert marketingStaging;

            Marketing_Staging__c newMarketingStaging = new Marketing_Staging__c();
            newMarketingStaging.First_Name__c = 'Test1';
            newMarketingStaging.Last_Name__c = 'Test1 LastName';
            newMarketingStaging.Email__c = 'Test1@email.com';
            newMarketingStaging.Applicant_Id__c = '12345';
            newMarketingStaging.Preference_Number__c = 1;
            newMarketingStaging.Application_Source__c = 'Studylink';
            newMarketingStaging.Application_Id__c = '12345';
            newMarketingStaging.Admission_Period__c ='12345';
            newMarketingStaging.Course_Code__c = '12345';
            newMarketingStaging.Admission_Year__c = 2202;
            newMarketingStaging.QUT_Student_ID__c = '123456';
            newMarketingStaging.Salutation__c = 'Mr';
            newMarketingStaging.Interaction_Type__c = 'TESTINERACTIONTYPE1';
            newMarketingStaging.Interaction_DateTime__c = Date.Today();
            newMarketingStaging.Lead_Source_Category__c = 'Enquiry';
            newMarketingStaging.Lead_Source__c = 'TESTLEADSOURCE1';
            newMarketingStaging.SPAD__c = 'TESTSPAD1';
            newMarketingStaging.Event_Name__c = 'TESTEVENTNAME1';
            insert newMarketingStaging;
            Test.stopTest();
        }
        Contact resultingContactRecord = [SELECT 
                                            Id, 
                                            Marketing_Segmentation_Score__c, 
                                            Marketing_Course_Application_Score__c, 
                                            Marketing_Interaction_Score__c, 
                                            IER_Score__c 
                                            FROM Contact 
                                            WHERE Id=:contact.Id
                                            LIMIT 1];
        
        
        System.assert(resultingContactRecord.Marketing_Segmentation_Score__c != null, 'Contact.Marketing_Segmentation_Score__c is empty.');
        System.assert(resultingContactRecord.Marketing_Course_Application_Score__c != null, 'Contact.Marketing_Course_Application_Score__c is empty.');
        System.assert(resultingContactRecord.Marketing_Interaction_Score__c != null, 'Contact.Marketing_Interaction_Score__c is empty.');
        System.assert(resultingContactRecord.IER_Score__c != null, 'Contact.IER_Score__c is empty.');
    }

    @isTest
    public static void testOneLeadMatch() {
        Lead lead;
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            lead = new Lead(FirstName = 'Test1', LastName = 'Test1 LastName', Email = 'Test1@email.com', Company ='Test Company');
            insert lead;

            et4ae5__SendDefinition__c sendDefinition = new et4ae5__SendDefinition__c();
            insert sendDefinition;

            et4ae5__IndividualEmailResult__c individualEmailResult = new et4ae5__IndividualEmailResult__c();
            individualEmailResult.Name = 'Test';
            individualEmailResult.et4ae5__SendDefinition__c = sendDefinition.Id;
            individualEmailResult.Primary_Lead__c = lead.Id;
            insert individualEmailResult;

            Marketing_Staging__c marketingStaging = new Marketing_Staging__c();
            marketingStaging.First_Name__c = 'Test1';
            marketingStaging.Last_Name__c = 'Test1 LastName';
            marketingStaging.Email__c = 'Test1@email.com';
            marketingStaging.Applicant_Id__c = '12345';
            marketingStaging.Preference_Number__c = 1;
            marketingStaging.Application_Source__c = 'Studylink';
            marketingStaging.Admission_Period__c ='12345';
            marketingStaging.Course_Code__c = '12345';
            marketingStaging.Admission_Year__c = 2202;
            marketingStaging.Interaction_Type__c = 'TESTINERACTIONTYPE1';
            marketingStaging.Interaction_DateTime__c = Date.Today();
            marketingStaging.Lead_Source_Category__c = 'Enquiry';
            marketingStaging.Lead_Source__c = 'TESTLEADSOURCE1';
            marketingStaging.SPAD__c = 'TESTSPAD1';
            marketingStaging.Event_Name__c = 'TESTEVENTNAME1';
            insert marketingStaging;

            Test.startTest();

            Marketing_Staging__c newMarketingStaging = new Marketing_Staging__c();
            newMarketingStaging.First_Name__c = 'Test1';
            newMarketingStaging.Last_Name__c = 'Test1 LastName';
            newMarketingStaging.Email__c = 'Test1@email.com';
            newMarketingStaging.Applicant_Id__c = '12345';
            newMarketingStaging.Preference_Number__c = 1;
            newMarketingStaging.Application_Source__c = 'Studylink';
            newMarketingStaging.Admission_Period__c ='12345';
            newMarketingStaging.Course_Code__c = '12345';
            newMarketingStaging.Admission_Year__c = 2202;
            newMarketingStaging.Interaction_Type__c = 'TESTINERACTIONTYPE1';
            newMarketingStaging.Interaction_DateTime__c = Date.Today();
            newMarketingStaging.Lead_Source_Category__c = 'Enquiry';
            newMarketingStaging.Lead_Source__c = 'TESTLEADSOURCE1';
            newMarketingStaging.SPAD__c = 'TESTSPAD1';
            newMarketingStaging.Event_Name__c = 'TESTEVENTNAME1';
            insert newMarketingStaging;

            Test.stopTest();
        }
        Lead resultingLeadRecord = [SELECT 
                Id, 
                Marketing_Segmentation_Score__c, 
                Marketing_Course_Application_Score__c, 
                Marketing_Interaction_Score__c, 
                IER_Score__c 
                FROM Lead 
                WHERE Id=:lead.Id
                LIMIT 1];

        System.assert(resultingLeadRecord.Marketing_Segmentation_Score__c != null, 'Lead.Marketing_Segmentation_Score__c is empty.');
        System.assert(resultingLeadRecord.Marketing_Course_Application_Score__c == null, 'Lead.Marketing_Course_Application_Score__c is not empty.');
        System.assert(resultingLeadRecord.Marketing_Interaction_Score__c != null, 'Lead.Marketing_Interaction_Score__c is empty.');
        System.assert(resultingLeadRecord.IER_Score__c != null, 'Lead.IER_Score__c is empty.');
    }

    @isTest
    public static void testNoMatch() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();

            Marketing_Staging__c newMarketingStaging = new Marketing_Staging__c();
            newMarketingStaging.First_Name__c = 'Test1';
            newMarketingStaging.Last_Name__c = 'Test1 LastName';
            newMarketingStaging.Email__c = 'Test1@email.com';
            newMarketingStaging.Applicant_Id__c = '12345';
            newMarketingStaging.Preference_Number__c = 1;
            newMarketingStaging.Application_Source__c = 'Studylink';
            newMarketingStaging.Admission_Period__c ='12345';
            newMarketingStaging.Course_Code__c = '12345';
            newMarketingStaging.Admission_Year__c = 2202;
            newMarketingStaging.Interaction_Type__c = 'TESTINERACTIONTYPE1';
            newMarketingStaging.Interaction_DateTime__c = Date.Today();
            newMarketingStaging.Lead_Source_Category__c = 'Enquiry';
            newMarketingStaging.Lead_Source__c = 'TESTLEADSOURCE1';
            newMarketingStaging.SPAD__c = 'TESTSPAD1';
            newMarketingStaging.Event_Name__c = 'TESTEVENTNAME1';
            Database.SaveResult saveResult = Database.insert(newMarketingStaging);

            Test.stopTest();
            
            System.assert(saveResult.isSuccess(), 'The marketing staging record was not successfully inserted.');
        }
    }
}