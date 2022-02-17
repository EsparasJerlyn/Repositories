/**
 * @description Tests the Ope Program Structure Test Class
 *
 * @see OpeProgramStructureCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | adrian.c.habasa           | Febuary 04, 2022      | DEPP-1427 | Created file                    | 
      |                           |                       |           |                                 |
*/
@isTest
public with sharing class OpeProgramStructureCtrlTest {
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static Id opeProgProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Program').getRecordTypeId();
    private static Id opeActProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();

    @isTest
    private static void getRelatedRecordsTest()
    {
        List<Account> accounts;
        accounts = TestDataFactory.createTestAccountRecords(1);
        insert accounts;

        List<Product_Request__c> prodRequestOPEProgramRequest;
        prodRequestOPEProgramRequest = TestDataFactory.createTestProductRequestRecords(1);
        prodRequestOPEProgramRequest[0].Product_Request_Name__c = 'Program';
        prodRequestOPEProgramRequest[0].RecordTypeId = opeProgProdReqId;
        insert prodRequestOPEProgramRequest;

        List<hed__Program_Plan__c> programPlanList;
        programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
        programPlanList[0].Product_Request__c = prodRequestOPEProgramRequest[0].Id;
        insert programPlanList;

        List<Product_Request__c> prodRequest;

        prodRequest = TestDataFactory.createTestProductRequestRecords(1);
        prodRequest[0].RecordTypeId = opeActProdReqId;
        prodRequest[0].Parent_Product_Request__c = prodRequestOPEProgramRequest[0].Id;
        insert prodRequest;

        List<hed__Course__c> courses;
        courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequest[0].Id);
        insert courses;

        Test.startTest();
         System.runAs(currentUser)
        {   
         OpeProgramStructureCtrl.OpeProductRequestAndCourse getRecords = new OpeProgramStructureCtrl.OpeProductRequestAndCourse();
         getRecords = OpeProgramStructureCtrl.getProdReqAndCourse(string.valueOf([SELECT Id FROM Product_Request__c WHERE RecordTypeId =:opeProgProdReqId LIMIT 1].Id)); 

         OpeProgramStructureCtrl.OpeProductRequestAndCourse getProdReq = new OpeProgramStructureCtrl.OpeProductRequestAndCourse();
         getProdReq = OpeProgramStructureCtrl.getProdReqAndCourse(string.valueOf([SELECT Id FROM Product_Request__c WHERE RecordTypeId =:opeActProdReqId LIMIT 1 ].Id)); 

         System.assert(!getRecords.courseList.isEmpty(),'Error while getting course data');
         System.assert(!getRecords.programPlanList.isEmpty(),'Error while getting Program Plan data');
        }
        Test.stopTest();
        
    }


}
