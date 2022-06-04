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
 */
@isTest(SeeAllData=false)
public with sharing class CourseOfferingTriggerHandlerTest {
    private static User currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @IsTest
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
            insert courseOfferings;

            Test.stopTest();
            Set<Id> ccId = new Set<Id>();
            for(hed__Course_Offering__c cc : courseOfferings){
                ccId.add(cc.Id);
            }
            List<hed__Course_Offering__c> courseOfferingsList = new List<hed__Course_Offering__c>();
            courseOfferingsList = [SELECT ID, External_Id__c FROM hed__Course_Offering__c WHERE ID IN : ccId];

            System.assert(courseOfferingsList[0].External_Id__c != null, 'External Id is not populated');
        }
    }
}
