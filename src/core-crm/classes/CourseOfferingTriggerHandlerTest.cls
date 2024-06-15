/**
 * @description CourseOfferingTriggerHandler Test Class
 * @see CourseOfferingTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 22, 2022        | DEPP-1991              | Created file                 |
      | roy.nino.s.regala              | June 04, 2022         | DEPP-2876              | Created file                 |
      | eugene.andrew.abuan            | July 31 , 2022        | DEPP-3534              | Added Before Update          |

 */
@isTest
public with sharing class CourseOfferingTriggerHandlerTest {
    private static User currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup
    static void setupMethod() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void insertCourseConnectionTest() {
        System.runAs(currentUser) {
            Test.startTest();

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account account : accounts){
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '2';
            }            
            insert accounts;
    
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            insert contacts;
    
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10,accounts[0].Id);
            insert terms;
    
            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
    
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(10,accounts[0].Id,prodRequest[0].Id);
            insert courses;
    
            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(10,courses,terms);
            for(hed__Course_Offering__c cc : courseOfferings){
                cc.Registration_Start_Date__c = Date.today();
                cc.Registration_End_Date__c = Date.today()+2;
            }
            insert courseOfferings;

            Test.stopTest();
            List<hed__Course_Offering__c> courseOfferingsList = new List<hed__Course_Offering__c>();
            courseOfferingsList = [SELECT ID, External_Id__c FROM hed__Course_Offering__c];

            System.assert(courseOfferingsList[0].External_Id__c != null, 'External Id is not populated');
        }
    }

    @isTest
    private static void validateRelatedProductBeforeUpdateTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();

            List<Account> accounts = TestDataFactory.createTestAccountRecords(100);
            for (Account account : accounts) {
              account.RecordTypeId = ACCT_UNIV_DEP_ID;
              account.Organization_Unit_Level__c = '2';
            }
            insert accounts;
      
            List<Contact> contacts = TestDataFactory.createTestContactRecords(100);
            contacts[0].Contact_Image__c = 'test';
            insert contacts;
      
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(100,accounts[0].Id);
            insert terms;
      
            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(100);
            insert prodRequest;
      
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(100,accounts[0].Id,prodRequest[0].Id);
            insert courses;
            
            List<Product2> products = TestDataFactory.createTestProductRecords(100,courses);
            insert products;

            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(100,courses,terms);
            for(hed__Course_Offering__c courseOffering : courseOfferings){
                courseOffering.hed__Start_Date__c = Date.today()+1;
                courseOffering.hed__End_Date__c = Date.today()+2;
                
            }
            insert courseOfferings;
            
            Integer cCount = 0;
            List<hed__Course_Offering__c> cOffToUpdate = new List<hed__Course_Offering__c>();
            cOffToUpdate = [SELECT Id, IsActive__c FROM hed__Course_Offering__c];
            for(hed__Course_Offering__c cOff1 : cOffToUpdate){
                cOff1.Delivery_Type__c = 'Online Self-paced';
                cOff1.IsActive__c = true;
                cCount++;
                if(cCount > 90){
                    cOff1.Registration_Start_Date__c = system.today() + 1;
                    cOff1.Registration_End_Date__c = null;
                    cOff1.IsActive__c = false;
                }
                cOff1.hed__Capacity__c = 100;
                cOff1.Total_Number_of_Registered_Learners__c = 50;
            }
            update cOffToUpdate;

            Test.stopTest();
            System.assert(cOffToUpdate.size() > 0,'Course Offering records wer');
        }
    }

}