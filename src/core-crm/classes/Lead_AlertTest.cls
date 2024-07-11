/**
 * @description Test Class for Lead_Alert
 * @see ..
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                | Date                  | JIRA                   | Change Summary               |
      |--------------------------|-----------------------|------------------------|------------------------------|
      | w.li                     | June 15, 2022         | DEPP-1489              | Created file                 |
      | alexander.cadalin        | February 20, 2023     | PMD                    | ApexUnitTestClassShouldHaveAsserts|
 */

@isTest
public without sharing class Lead_AlertTest {

    @testSetup static void setup() {
        // Generate test users.
        TestDataFactoryUser.generateUserQUTMarketingCloud();
    }

    @isTest
    public static void testInternationalLeadAlert() {
        System.runAs(TestDataFactoryUser.selectUserQUTMarketingCloud) {
            Test.startTest();
            Marketing_Staging__c marketingStaging = new Marketing_Staging__c();
            marketingStaging.First_Name__c = 'Test1';
            marketingStaging.Last_Name__c = 'Test1 LastName';
            marketingStaging.Email__c = 'Test1@email.com';
            marketingStaging.Mobile__c = '0123456789';
            marketingStaging.Birthdate__c = System.Date.today();
            marketingStaging.Email_OptIn_DateTime__c = System.now();
            marketingStaging.My_Country_Of_Citizenship__c = 'China';
            marketingStaging.My_Country_Of_Residency__c = 'China';
            marketingStaging.My_Expected_Admission_Year__c = 2024;
            marketingStaging.My_Primary_Study_Level__c = 'Undergraduate';
            marketingStaging.My_Primary_BSA__c = 'Business';
            marketingStaging.My_Primary_NSA__c = 'Accounting and Financial Planning';
            marketingStaging.My_Funding_Source__c = 'I will fund my studies myself';
            marketingStaging.Lead_Source__c = 'Enquiry';
            marketingStaging.Lead_Source_Category__c = 'Other';
            marketingStaging.Enquiry_Description__c = 'This is an enquiry.';
            marketingStaging.Enquiry_Type__c = 'Application process';
            Database.SaveResult saveResult = Database.insert(marketingStaging);
            Test.stopTest();
            System.assert(saveResult.isSuccess(), 'The record was not successfully inserted.');
        }
    }

    @isTest
    public static void testDomesticLeadAlert() {
        System.runAs(TestDataFactoryUser.selectUserQUTMarketingCloud) {
            Test.startTest();
            Marketing_Staging__c marketingStaging = new Marketing_Staging__c();
            marketingStaging.First_Name__c = 'Test1';
            marketingStaging.Last_Name__c = 'Test1 LastName';
            marketingStaging.Email__c = 'Test1@email.com';
            marketingStaging.Mobile__c = '0123456789';
            marketingStaging.Birthdate__c = System.Date.today();
            marketingStaging.Email_OptIn_DateTime__c = System.now();
            marketingStaging.My_Country_Of_Citizenship__c = 'Australia';
            marketingStaging.My_Country_Of_Residency__c = 'Australia';
            marketingStaging.My_Expected_Admission_Year__c = 2024;
            marketingStaging.My_Primary_Study_Level__c = 'Undergraduate';
            marketingStaging.My_Primary_BSA__c = 'Business';
            marketingStaging.My_Primary_NSA__c = 'Accounting and Financial Planning';
            marketingStaging.My_Funding_Source__c = 'I will fund my studies myself';
            marketingStaging.Lead_Source__c = 'Enquiry';
            marketingStaging.Lead_Source_Category__c = 'Other';
            marketingStaging.Enquiry_Description__c = 'This is an enquiry.';
            marketingStaging.Enquiry_Type__c = 'Application process';
            Database.SaveResult saveResult = Database.insert(marketingStaging);
            Test.stopTest();
            System.assert(saveResult.isSuccess(), 'The record was not successfully inserted.');
        }
    }

    @isTest
    public static void testResearchLeadAlert() {
        System.runAs(TestDataFactoryUser.selectUserQUTMarketingCloud) {
            Test.startTest();
            Marketing_Staging__c marketingStaging = new Marketing_Staging__c();
            marketingStaging.First_Name__c = 'Test1';
            marketingStaging.Last_Name__c = 'Test1 LastName';
            marketingStaging.Email__c = 'Test1@email.com';
            marketingStaging.Mobile__c = '0123456789';
            marketingStaging.Birthdate__c = System.Date.today();
            marketingStaging.Email_OptIn_DateTime__c = System.now();
            marketingStaging.My_Country_Of_Citizenship__c = 'Australia';
            marketingStaging.My_Country_Of_Residency__c = 'Australia';
            marketingStaging.My_Expected_Admission_Year__c = 2024;
            marketingStaging.My_Primary_Study_Level__c = 'Higher Degree Research';
            marketingStaging.My_Primary_BSA__c = 'Business';
            marketingStaging.My_Primary_NSA__c = 'Accounting and Financial Planning';
            marketingStaging.My_Funding_Source__c = 'I will fund my studies myself';
            marketingStaging.Lead_Source__c = 'Enquiry';
            marketingStaging.Lead_Source_Category__c = 'Other';
            marketingStaging.Enquiry_Description__c = 'This is an enquiry.';
            marketingStaging.Enquiry_Type__c = 'Application process';
            Database.SaveResult saveResult = Database.insert(marketingStaging);
            Test.stopTest();
            System.assert(saveResult.isSuccess(), 'The record was not successfully inserted.');
        }
    }

    @isTest
    public static void testQTACLeadAlert() {
        System.runAs(TestDataFactoryUser.selectUserQUTMarketingCloud) {
            Test.startTest();
            Marketing_Staging__c marketingStaging = new Marketing_Staging__c();
            marketingStaging.First_Name__c = 'Test1';
            marketingStaging.Last_Name__c = 'Test1 LastName';
            marketingStaging.Email__c = 'Test1@email.com';
            marketingStaging.Mobile__c = '0123456789';
            marketingStaging.Birthdate__c = System.Date.today();
            marketingStaging.Email_OptIn_DateTime__c = System.now();
            marketingStaging.My_Studying_Australian_Curriculum__c = true;
            marketingStaging.My_Country_Of_Citizenship__c = 'Australia';
            marketingStaging.My_Country_Of_Residency__c = 'Australia';
            marketingStaging.My_Expected_Admission_Year__c = 2024;
            marketingStaging.My_Primary_Study_Level__c = 'Undergraduate';
            marketingStaging.My_Primary_BSA__c = 'Business';
            marketingStaging.My_Primary_NSA__c = 'Accounting and Financial Planning';
            marketingStaging.My_Funding_Source__c = 'I will fund my studies myself';
            marketingStaging.Lead_Source__c = 'Enquiry';
            marketingStaging.Lead_Source_Category__c = 'Other';
            marketingStaging.Enquiry_Description__c = 'This is an enquiry.';
            marketingStaging.Enquiry_Type__c = 'Application process';
            Database.SaveResult saveResult = Database.insert(marketingStaging);
            Test.stopTest();
            System.assert(saveResult.isSuccess(), 'The record was not successfully inserted.');
        }
    }

    @isTest
    public static void testExchangeLeadAlert() {
        System.runAs(TestDataFactoryUser.selectUserQUTMarketingCloud) {
            Test.startTest();
            Marketing_Staging__c marketingStaging = new Marketing_Staging__c();
            marketingStaging.First_Name__c = 'Test1';
            marketingStaging.Last_Name__c = 'Test1 LastName';
            marketingStaging.Email__c = 'Test1@email.com';
            marketingStaging.Mobile__c = '0123456789';
            marketingStaging.Birthdate__c = System.Date.today();
            marketingStaging.Email_OptIn_DateTime__c = System.now();
            marketingStaging.My_Country_Of_Citizenship__c = 'Australia';
            marketingStaging.My_Country_Of_Residency__c = 'Australia';
            marketingStaging.My_Expected_Admission_Year__c = 2024;
            marketingStaging.My_Primary_Study_Level__c = 'Exchange and Study Abroad (1 or 2 Semesters Only)';
            marketingStaging.My_Primary_BSA__c = 'Business';
            marketingStaging.My_Primary_NSA__c = 'Accounting and Financial Planning';
            marketingStaging.My_Funding_Source__c = 'I will fund my studies myself';
            marketingStaging.Lead_Source__c = 'Enquiry';
            marketingStaging.Lead_Source_Category__c = 'Other';
            marketingStaging.Enquiry_Description__c = 'This is an enquiry.';
            marketingStaging.Enquiry_Type__c = 'Application process';
            Database.SaveResult saveResult = Database.insert(marketingStaging);
            Test.stopTest();
            System.assert(saveResult.isSuccess(), 'The record was not successfully inserted.');
        }
    }
}
