/**
 * @description Test Class for GenerateCodeCtrl
 * @see ../class/GenerateCodeCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | May 12, 2022          | DEPP-2336            | Created file                 |
      |                           |                       |                      |                              |
 */
@isTest(SeeAllData=false)
public with sharing class GenerateCodeCtrlTest{

     private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
     private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;
     private static final Id RT_ACTIVITY_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();
     private static final string RT_PROGRAM = System.Label.RT_ProductRequest_Program;
     private static final Id RT_PROGRAM_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_PROGRAM).getRecordTypeId();
     private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
     private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

     @IsTest
     static void getCourseDetailsTest(){
          System.runAs(currentUser){
               createRecord(RT_ACTIVITY_ID);               
               Test.startTest();
               Id recordId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
               GenerateCodeCtrl.CourseProgramDetails details = GenerateCodeCtrl.getCourseAndProgDetails(recordId);
               Test.stopTest();
               System.assert(!String.isBlank(details.recordId), 'Id must not be blank');
          }
     }

     @IsTest
     static void getProgramDetailsTest(){
          System.runAs(currentUser){
               createRecord(RT_PROGRAM_ID);               
               Test.startTest();
               Id recordId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
               GenerateCodeCtrl.CourseProgramDetails details = GenerateCodeCtrl.getCourseAndProgDetails(recordId);
               Test.stopTest();
               System.assert(!String.isBlank(details.recordId), 'Id must not be blank');
          }
     }

     @IsTest
     static void generateCourseCodeTest(){
          System.runAs(currentUser){
               createRecord(RT_ACTIVITY_ID);               
               Test.startTest();
               String code = GenerateCodeCtrl.generateCode(RT_ACTIVITY);
               Test.stopTest();
               System.assert(!String.isBlank(code), 'Code must not be blank');
          }
     }

     @IsTest
     static void generateProgramCodeTest(){
          System.runAs(currentUser){
               createRecord(RT_PROGRAM_ID);               
               Test.startTest();
               String code = GenerateCodeCtrl.generateCode(RT_PROGRAM);
               Test.stopTest();
               System.assert(!String.isBlank(code), 'Code must not be blank');
          }
     }

     private static void createRecord(String productRequestRecordType){
          System.runAs(currentUser){
               Id offeringId = null;

               List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
               for(Account acc : accounts){
                    acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                    acc.Organization_Unit_Level__c = '2';
               }
               insert accounts;

               List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
               for(Product_Request__c productRequest : productRequests){
                    productRequest.RecordTypeId = productRequestRecordType;
               }
               insert productRequests;

               if(productRequestRecordType == RT_PROGRAM_ID){
                    List<hed__Program_Plan__c> programs = TestDataFactory.createTestProgramPlanRecords(1);
                    for(hed__Program_Plan__c program : programs){
                         program.Product_Request__c = productRequests[0].Id;
                    }
                    insert programs;
               }else{
                    List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
                    insert courses;
               }
          }
     }

}