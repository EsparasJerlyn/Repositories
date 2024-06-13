/**
 * @description Test Class for MarketingStagingMatchingHelper
 * @see ..MarketingStagingMatchingHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | June 28, 2022         | DEPP-3070              | Created file                                   |
      | roy.nino.s.regala              | July 20, 2022         | DEPP-3535              | Updated logic to update mobile and birthdate   |
      | roy.nino.s.regala              | July 24, 2022         | DEPP-3512              | Updated logic to update mobile locale          |
      | mark.j.mahilum                 | July 03, 2023         | DEPP-5961              | Remove assertion for Marketing Course App Obj  |

 */

@isTest
public with sharing class MarketingStagingMatchingHelperTest{

    @testSetup
    static void setupMethod() {
        List<Contact> contactList = TestDataFactory.createTestContactRecords(100);
        TestDataFactory.generateTestUsers();
        for(integer i = 0; i < contactList.size(); i++){
            contactList[i].QUT_Student_ID__c = 'Test' + i;
            contactList[i].Email = 'testContact@email.com' + i;
            contactList[i].Mobile_No_Locale__c = '12345' + i;
            contactList[i].ContactMobile_Locale__c = null; //set to null since this has a default value
            contactList[i].Company_Name__c = 'Test Company' + i;
        }

        List<Lead> leadList =  TestDataFactory.createTestLeadRecords(100);
        for(integer i = 0; i < leadList.size(); i++){
            leadList[i].Email = 'testLead@email.com' + i;
            leadList[i].Mobile_No_Locale__c = '1234' + i;
            leadList[i].LeadMobile_Locale__c = null; //set to null since this has a default value
        }

            insert contactList;
            insert leadList;
        }


    @isTest
    public static void bulkContactMatchTest(){
        System.runAs(TestDataFactory.getMarketingCloudUser()) {
            List<Marketing_Staging__c> stagingList = new List<Marketing_Staging__c>();
            Marketing_Staging__c staging;
            //matching student id
            for(integer i = 0; i< 25; i++){
                staging = new Marketing_Staging__c();
                staging.First_Name__c ='Test FirstName' + i;
                staging.Last_Name__c ='Test LastName' + i;
                staging.Email__c ='testContact@email.com' + i;
                staging.Event_Name__c ='TestEvent' + i;
                staging.Application_Source__c = 'SAMS';
                staging.QUT_Student_ID__c ='Test' + i;
                staging.Admission_Period__c = '12345' + i;
                staging.Course_Code__c = '1231' + i;
                staging.Admission_Year__c = 2023;
                staging.Salutation__c = 'Mr';
                stagingList.add(staging);
            }

            //matching email
            for(integer i = 25; i<50 ; i++){
                staging = new Marketing_Staging__c();
                staging.First_Name__c ='Test FirstName' + i;
                staging.Last_Name__c ='Test LastName' + i;
                staging.Email__c ='testContact@email.com' + i;
                staging.Event_Name__c ='TestEvent' + i;
                staging.Applicant_Id__c = '12345' + i;
                staging.Preference_Number__c = 1;
                staging.Application_Source__c = 'QTAC';
                staging.Salutation__c = 'Mr';
                stagingList.add(staging);
            }

            //no match
            for(integer i = 50; i<75 ; i++){
                staging = new Marketing_Staging__c();
                staging.First_Name__c ='Test FirstName' + i;
                staging.Last_Name__c ='Test LastName' + i;
                staging.Email__c ='test@email.com' + i;
                staging.Mobile__c = '123456' + i;
                staging.Event_Name__c ='TestEvent' + i;
                staging.Application_Source__c = 'Studylink';
                staging.Application_Id__c = '12345' + i;
                staging.Applicant_Id__c = '12345' + i;
                staging.Salutation__c = 'Mr';
                stagingList.add(staging);
            }
            Test.startTest();
            insert stagingList;
            Test.stopTest();

            System.assertEquals([SELECT Id FROM Marketing_Staging__c WHERE Contact__c != null LIMIT 50].size(),50, 'Contact is not linked');
            System.assertEquals([SELECT Id FROM Marketing_Staging__c WHERE Lead__c != null LIMIT 25].size(),25, 'Lead is not linked');
            System.assertEquals([SELECT Id FROM Marketing_Course_Application__c LIMIT 75].size(),75, 'Number of application created did not match');
            System.assertEquals([SELECT Id FROM Marketing_Interaction__c LIMIT 75].size(),75, 'Number of interaction created did not match');
            System.assertEquals([SELECT Id FROM Marketing_Segmentation__c LIMIT 75].size(),75, 'Number of segmentation created did not match');
        }
    }

    @isTest
    public static void bulkContactExistingMarketingRecordsTest(){
        System.runAs(TestDataFactory.getMarketingCloudUser()) {
            List<Marketing_Staging__c> stagingList = new List<Marketing_Staging__c>();
            List<Marketing_Staging__c> stagingList2 = new List<Marketing_Staging__c>();
            Marketing_Staging__c staging;
            //matching student id
            for(integer i = 0; i< 20; i++){
                staging = new Marketing_Staging__c();
                staging.First_Name__c ='Test FirstName' + i;
                staging.Last_Name__c ='Test LastName' + i;
                staging.Email__c ='testContact@email.com' + i;
                staging.Event_Name__c ='TestEvent' + i;
                staging.Application_Source__c = 'SAMS';
                staging.QUT_Student_ID__c ='Test' + i;
                staging.Admission_Period__c = '12345' + i;
                staging.Course_Code__c = '1231' + i;
                staging.Admission_Year__c = 2023;
                staging.Email_OptIn_DateTime__c = system.today();
                staging.Salutation__c = 'Mr';
                stagingList.add(staging);
            }

            //matching email
            for(integer i = 20; i<40 ; i++){
                staging = new Marketing_Staging__c();
                staging.First_Name__c ='Test FirstName' + i;
                staging.Last_Name__c ='Test LastName' + i;
                staging.Email__c ='testContact@email.com' + i;
                staging.Event_Name__c ='TestEvent' + i;
                staging.Applicant_Id__c = '12345' + i;
                staging.Preference_Number__c = 1;
                staging.Application_Source__c = 'QTAC';
                staging.Salutation__c = 'Mr';
                staging.Email_OptOut_DateTime__c = system.today();
                staging.HasOptedOutOfEmail__c = true;
                stagingList.add(staging);
            }

            //matching student id
            for(integer i = 0; i< 20; i++){
                staging = new Marketing_Staging__c();
                staging.First_Name__c ='Test FirstName' + i;
                staging.Last_Name__c ='Test LastName' + i;
                staging.Email__c ='testContact@email.com' + i;
                staging.Event_Name__c ='TestEvent' + i;
                staging.Application_Source__c = 'SAMS';
                staging.QUT_Student_ID__c ='Test' + i;
                staging.Admission_Period__c = '12345' + i;
                staging.Course_Code__c = '1231' + i;
                staging.Admission_Year__c = 2023;
                staging.Salutation__c = 'Mr';
                stagingList2.add(staging);
            }

            //matching email
            for(integer i = 20; i<40 ; i++){
                staging = new Marketing_Staging__c();
                staging.First_Name__c ='Test FirstName' + i;
                staging.Last_Name__c ='Test LastName' + i;
                staging.Email__c ='testContact@email.com' + i;
                staging.Event_Name__c ='TestEvent' + i;
                staging.Applicant_Id__c = '12345' + i;
                staging.Preference_Number__c = 1;
                staging.Application_Source__c = 'QTAC';
                staging.Salutation__c = 'Mr';
                stagingList2.add(staging);
            }

            Test.startTest();
            insert stagingList;
            insert stagingList2;
            Test.stopTest();

            System.assertEquals([SELECT Id FROM Marketing_Staging__c WHERE Contact__c != null LIMIT 40].size(),40, 'Contact is not linked');
            System.assertEquals([SELECT Id FROM Marketing_Course_Application__c LIMIT 40].size(),40, 'Number of application created did not match');
            System.assertEquals([SELECT Id FROM Marketing_Interaction__c LIMIT 40].size(),40, 'Number of interaction created did not match');
            System.assertEquals([SELECT Id FROM Marketing_Segmentation__c LIMIT 40].size(),40, 'Number of segmentation created did not match');
        }
    }


    @isTest
    public static void bulkLeadExistingMarketingRecordsTest(){
        System.runAs(TestDataFactory.getMarketingCloudUser()) {
            List<Marketing_Staging__c> stagingList = new List<Marketing_Staging__c>();
            List<Marketing_Staging__c> stagingList2 = new List<Marketing_Staging__c>();
            Marketing_Staging__c staging;
            //matching email
            for(integer i = 0; i< 25; i++){
                staging = new Marketing_Staging__c();
                staging.First_Name__c ='Test FirstName' + i;
                staging.Last_Name__c ='Test LastName' + i;
                staging.Email__c ='testLead@email.com' + i;
                staging.Event_Name__c ='TestEvent' + i;
                staging.Application_Source__c = 'SAMS';
                staging.QUT_Student_ID__c ='TestLead' + i;
                staging.Admission_Period__c = '12345' + i;
                staging.Course_Code__c = '1231' + i;
                staging.Admission_Year__c = 2023;
                staging.Email_OptIn_DateTime__c = system.today();
                staging.Salutation__c = 'Mr';
                stagingList.add(staging);
            }

            //matching email
            for(integer i = 0; i < 25; i++){
                staging = new Marketing_Staging__c();
                staging.First_Name__c ='Test FirstName' + i;
                staging.Last_Name__c ='Test LastName' + i;
                staging.Email__c ='testLead@email.com' + i;
                staging.Event_Name__c ='TestEvent' + i;
                staging.Application_Source__c = 'SAMS';
                staging.QUT_Student_ID__c ='TestLead' + i;
                staging.Admission_Period__c = '12345' + i;
                staging.Course_Code__c = '1231' + i;
                staging.Admission_Year__c = 2023;
                staging.Salutation__c = 'Mr';
                staging.Email_OptOut_DateTime__c = system.today();
                staging.HasOptedOutOfEmail__c = true;
                stagingList2.add(staging);
            }

            Test.startTest();
            insert stagingList;
            insert stagingList2;
            Test.stopTest();

            System.assertEquals([SELECT Id FROM Marketing_Staging__c WHERE Lead__c != null LIMIT 25].size(),25, 'Lead is not linked');
            System.assertEquals([SELECT Id FROM Marketing_Course_Application__c LIMIT 25].size(),25, 'Number of application created did not match');
            System.assertEquals([SELECT Id FROM Marketing_Interaction__c LIMIT 25].size(),25, 'Number of Interaction created did not match');
            System.assertEquals([SELECT Id FROM Marketing_Segmentation__c LIMIT 25].size(),25, 'Number of segmentation created did not match');
        }
    }

    @isTest
    public static void bulkLeadMatchTest(){
        System.runAs(TestDataFactory.getMarketingCloudUser()) {
            List<Marketing_Staging__c> stagingList = new List<Marketing_Staging__c>();
            Marketing_Staging__c staging;
            //matching email
            for(integer i = 0; i< 25; i++){
                staging = new Marketing_Staging__c();
                staging.First_Name__c ='Test FirstName' + i;
                staging.Last_Name__c ='Test LastName' + i;
                staging.Email__c ='testLead@email.com' + i;
                staging.Event_Name__c ='TestEvent' + i;
                staging.Application_Source__c = 'SAMS';
                staging.QUT_Student_ID__c ='TestLead' + i;
                staging.Admission_Period__c = '12345' + i;
                staging.Course_Code__c = '1231' + i;
                staging.Admission_Year__c = 2023;
                staging.Salutation__c = 'Mr';
                stagingList.add(staging);
            }
            //no match
            for(integer i = 25; i<50 ; i++){
                staging = new Marketing_Staging__c();
                staging.First_Name__c ='Test FirstName' + i;
                staging.Last_Name__c ='Test LastName' + i;
                staging.Email__c ='test@email.com' + i;
                staging.Mobile__c = '123456' + i;
                staging.Event_Name__c ='TestEvent' + i;
                staging.Application_Source__c = 'Studylink';
                staging.Application_Id__c = '12345' + i;
                staging.Applicant_Id__c = '12345' + i;
                staging.Salutation__c = 'Mr';
                stagingList.add(staging);
            }
            Test.startTest();
            insert stagingList;
            Test.stopTest();

            System.assertEquals([SELECT Id FROM Marketing_Staging__c WHERE Lead__c != null LIMIT 50].size(),50, 'Lead is not linked');
            System.assertEquals([SELECT Id FROM Marketing_Course_Application__c LIMIT 50].size(),50, 'Number of application created did not match');
            System.assertEquals([SELECT Id FROM Marketing_Interaction__c LIMIT 50].size(),50, 'Number of Interaction created did not match');
            System.assertEquals([SELECT Id FROM Marketing_Segmentation__c LIMIT 50].size(),50, 'Number of segmentation created did not match');
            System.assertEquals([SELECT Id FROM Marketing_Staging__c WHERE Lead__c != null 
                AND Lead__r.LeadSource = 'Studylink Unsubmitted' AND Lead__r.Lead_Source_Category__c = 'Study Application' LIMIT 50].size(),25, 'Lead Source and Lead Source Category must be for StudyLink.');
            System.assertEquals([SELECT Id FROM Marketing_Staging__c WHERE Lead__c != null 
                AND Lead__r.LeadSource != 'Studylink Unsubmitted' AND Lead__r.Lead_Source_Category__c != 'Study Application' LIMIT 50].size(),25, 'Lead Source and Lead Source Category are incorrect.');
        }
    }
 }