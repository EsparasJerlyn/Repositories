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

    private static string PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static string PR_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static Id opeProgProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static Id opeActProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_ACTIVITY).getRecordTypeId();

    @testSetup static void setupMethod() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        List<Account> accounts;
        accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account acc : accounts){
            acc.RecordTypeId = ACCT_UNIV_DEP_ID;
            acc.Organization_Unit_Level__c = '2';
        }
        insert accounts;

        List<Product_Request__c> prodRequestOPEProgramRequest;
        prodRequestOPEProgramRequest = TestDataFactory.createTestProductRequestRecords(1);
        prodRequestOPEProgramRequest[0].Product_Request_Name__c = PR_PROGRAM;
        prodRequestOPEProgramRequest[0].RecordTypeId = opeProgProdReqId;
        insert prodRequestOPEProgramRequest;

        List<hed__Program_Plan__c> programPlanList;
        programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
        programPlanList[0].Product_Request__c = prodRequestOPEProgramRequest[0].Id;
        insert programPlanList;

        List<Product_Request__c> prodRequest;

        prodRequest = TestDataFactory.createTestProductRequestRecords(1);
        prodRequest[0].RecordTypeId = opeActProdReqId;
        insert prodRequest;

        List<hed__Course__c> courses;
        courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequest[0].Id);
        insert courses;

        List<Related_Product_Request__c> relatedProductRequests;
        relatedProductRequests = TestDataFactory.createTestRelatedPRRecords(1,prodRequest,prodRequestOPEProgramRequest);
        insert relatedProductRequests;
    }


    @isTest
    private static void getRelatedRecordsTest()
    {

        Test.startTest();
         System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator)
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


    @isTest
    private static void upsertProgramPlanAndPlanRequirementTest()
    {
        List<hed__Course__c> course = [SELECT Id FROM hed__Course__c];
        List<hed__Program_Plan__c> program = [SELECT Id, Program_Delivery_Structure__c FROM hed__Program_Plan__c];
        List<hed__Plan_Requirement__c> newPlanReqToUpsert = new List<hed__Plan_Requirement__c>();

        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator)
        {
         hed__Plan_Requirement__c newPlanRequirement = new hed__Plan_Requirement__c(
            hed__Sequence__c = 1,
            hed__Category__c = 'Optional',
            hed__Course__c = course[0].Id,
            hed__Program_Plan__c = program[0].Id
         );
        newPlanReqToUpsert.add(newPlanRequirement);
        program[0].Program_Delivery_Structure__c = 'Flexible Program';
        OpeProgramStructureCtrl.upsertProgramPlanAndPlanRequirement(newPlanReqToUpsert);
        }

        System.assert(![SELECT ID FROM hed__Plan_Requirement__c].isEmpty(),'Error while createing plan requirement');
        Test.stopTest();
    }




}