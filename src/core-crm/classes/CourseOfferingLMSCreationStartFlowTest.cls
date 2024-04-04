/**
 * @description Tests the Course_Offering_LMS_Creation_Start_Date Flow
 *
 * @see Course_Offering_LMS_Creation_Start_Date
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                                  |
      |---------------------------|-----------------------|-----------|-------------------------------------------------|
      | eugene.andrew.abuan       | September 18, 2023    | DEPP-6592 | Created file                                    |
*/
@isTest
public with sharing class CourseOfferingLMSCreationStartFlowTest {
    @testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{'QUTeX_Program_Administrator', 'QUT_ESB'});
        System.runAs(TestDataFactory.getESBIntegrationUser()){
            List<Account> newAccounts = new List<Account>();
            newAccounts.add(TestDataFactory.createTestAccount(false));
            newAccounts[0].RecordTypeId = AccountsDAO.ACCT_UNIV_DEP_ID;
            newAccounts[0].Organization_Unit_Level__c = '2';

            AccountsDAO.newInstance().insertRecords(newAccounts, false, AccessLevel.USER_MODE);
            
            List<AccountShare> accShare = TestDataFactory.createAccountShareRecords(newAccounts, TestDataFactory.getProgramAdminUser().Id, 'Edit');
            insert accShare;
    
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10,newAccounts[0].Id);
            for(hed__Term__c term : terms){
                term.hed__Start_Date__c = Date.today().addMonths(4);
            }
            TermsDAO.newInstance().insertRecords(terms, false, AccessLevel.USER_MODE);    
        }  
    }

    @isTest
    public static void populateLMSCreationDate(){
        System.runAs(TestDataFactory.getProgramAdminUser()){           
            Test.startTest();
            List<Account> accList = [SELECT Id FROM Account];
            
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            ContactsDAO.newInstance().insertRecords(contacts, false, AccessLevel.USER_MODE);
    
            List<Product_Request__c> productRequestsList = TestDataFactory.createTestProductRequestRecords(1);
            ProductRequestsDAO.newInstance().insertRecords(productRequestsList, false, AccessLevel.USER_MODE);
            

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(10,accList[0].Id,productRequestsList[0].Id);
            CoursesDAO.newInstance().insertRecords(courses, false, AccessLevel.USER_MODE);

    
            List<hed__Term__c> terms = [SELECT Id FROM hed__Term__c];
            
            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(10,courses,terms);
            for(hed__Course_Offering__c cc : courseOfferings){
                cc.Registration_Start_Date__c = Date.today();
                cc.Registration_End_Date__c = Date.today()+2;
            }
            CourseOfferingsDAO.newInstance().insertRecords(courseOfferings, false, AccessLevel.USER_MODE);
    
            List<hed__Course_Offering__c> courseOfferingActualLMSCreationDate = [SELECT Id,LMS_Creation_Date__c, hed__Start_Date__c FROM hed__Course_Offering__c];

            Date expectedLMSCreationDate = courseOfferingActualLMSCreationDate[0].hed__Start_Date__c.addDays(-14);
            
            System.assertEquals(expectedLMSCreationDate,courseOfferingActualLMSCreationDate[0].LMS_Creation_Date__c, 'LMS Creation Date is not added with 14 days');
            Test.stopTest();
        }
    }
} 