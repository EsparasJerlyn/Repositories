/**
 * @description Test Class for Lead_Alert
 * @see ..
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------|------------------------------|
      | w.li                     | June 15, 2022         | DEPP-1489              | Created file                 |
 */

@IsTest(SeeAllData=false)
public without sharing class Lead_AlertTest {

    @IsTest
    public static void testInternationalLeadAlert() {
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
        marketingStaging.Lead_Source_Category__c = 'Enquiry';
        marketingStaging.Enquiry_Description__c = 'This is an enquiry.';
        marketingStaging.Enquiry_Type__c = 'Application process';
        insert marketingStaging;
        Test.stopTest();
    }

    @IsTest
    public static void testDomesticLeadAlert() {
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
        marketingStaging.Lead_Source_Category__c = 'Enquiry';
        marketingStaging.Enquiry_Description__c = 'This is an enquiry.';
        marketingStaging.Enquiry_Type__c = 'Application process';
        insert marketingStaging;
        Test.stopTest();
    }

    @IsTest
    public static void testResearchLeadAlert() {
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
        marketingStaging.Lead_Source_Category__c = 'Enquiry';
        marketingStaging.Enquiry_Description__c = 'This is an enquiry.';
        marketingStaging.Enquiry_Type__c = 'Application process';
        insert marketingStaging;
        Test.stopTest();
    }

    @IsTest
    public static void testQTACLeadAlert() {
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
        marketingStaging.Lead_Source_Category__c = 'Enquiry';
        marketingStaging.Enquiry_Description__c = 'This is an enquiry.';
        marketingStaging.Enquiry_Type__c = 'Application process';
        insert marketingStaging;
        Test.stopTest();
    }

    @IsTest
    public static void testExchangeLeadAlert() {
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
        marketingStaging.Lead_Source_Category__c = 'Enquiry';
        marketingStaging.Enquiry_Description__c = 'This is an enquiry.';
        marketingStaging.Enquiry_Type__c = 'Application process';
        insert marketingStaging;
        Test.stopTest();
    }


 }