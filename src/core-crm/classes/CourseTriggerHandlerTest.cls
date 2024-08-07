/**
 * @description CourseTriggerHandler Test Class
 * @see CourseTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 22, 2022        | DEPP-1991              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest

public with sharing class CourseTriggerHandlerTest {
    private static Id opeShortProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Short_Course').getRecordTypeId();
    private static Id opeShortCourseId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get('Short_Course').getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void insertCourseTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(10);
            for(Product_Request__c productRequest : productRequests){
                productRequest.RecordTypeId = opeShortProdReqId;
            }
            insert productRequests;

            hed__Facility__c facility = new hed__Facility__c();
            facility.Name = 'Externals';
            insert facility;

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(10, accounts[0].Id, productRequests[0].Id);
            for(Integer i = 0 ; i < courses.size() ; i++){
                courses[i].ProductRequestID__c = productRequests[i].Id;
                courses[i].RecordTypeId = opeShortCourseId;
                courses[i].Location__c = facility.Id;
            }
            insert courses;
            Test.stopTest();
            Set<Id> courseID = new Set<Id>();
            for(hed__Course__c c : courses){
                courseID.add(c.Id);
            }

            List<hed__Course__c> courseList = new List<hed__Course__c>();
            courseList = [SELECT ID, External_Id__c FROM hed__Course__c WHERE ID IN : courseID];

            System.assert(courseList[0].External_Id__c != null, 'External Id is not populated');
        }
    }
}
