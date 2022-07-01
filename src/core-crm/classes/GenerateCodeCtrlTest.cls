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

     private static final String RT_SHORT_COURSE = System.Label.RT_Course_ShortCourse;
     private static final Id RT_SHORT_COURSE_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_SHORT_COURSE).getRecordTypeId();

     private static final String RT_MODULE = System.Label.RT_Course_Module;
     private static final Id RT_MODULE_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_MODULE).getRecordTypeId();

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
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_ACTIVITY);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     
     @IsTest
     static void generateProgramCodeTest(){
          System.runAs(currentUser){
               createRecord(RT_PROGRAM_ID);               
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_PROGRAM);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     @IsTest
     static void generateModuleCodeTest(){
          System.runAs(currentUser){
               createRecord(RT_MODULE_ID);               
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_MODULE);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     @IsTest
     static void generateShortCodeTest(){
          System.runAs(currentUser){
               createRecord(RT_SHORT_COURSE_ID);  
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_SHORT_COURSE);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     @IsTest
     static void updateCodeGeneratorTest(){
          System.runAs(currentUser){
               createRecord(RT_SHORT_COURSE_ID);               
               Test.startTest();
               String actId;
               List<Activity_Code_Generator__c> actList = [SELECT Id FROM Activity_Code_Generator__c LIMIT 1];
               for(Activity_Code_Generator__c a : actList){ actId = a.Id; }

               String prgId;
               List<Program_Code_Generator__c> prgList = [SELECT Id FROM Program_Code_Generator__c LIMIT 1];
               for(Program_Code_Generator__c p : prgList){ prgId = p.Id; }
               
               String modId;
               List<Module_Code_Generator__c> modList = [SELECT Id FROM Module_Code_Generator__c LIMIT 1];
               for(Module_Code_Generator__c m : modList){ modId = m.Id; }

               String scId;
               List<Short_Course_Code_Generator__c> scList = [SELECT Id FROM Short_Course_Code_Generator__c LIMIT 1];
               for(Short_Course_Code_Generator__c s : scList){ scId = s.Id; }

               String actCode = GenerateCodeCtrl.updateCodeGenerator(RT_ACTIVITY, actId, 1, 'test');
               String progCode = GenerateCodeCtrl.updateCodeGenerator(RT_PROGRAM, prgId, 1, 'test');
               String modCode = GenerateCodeCtrl.updateCodeGenerator(RT_MODULE, modId, 1, 'test');
               String scCode = GenerateCodeCtrl.updateCodeGenerator(RT_SHORT_COURSE, scId, 1, 'test');

               Test.stopTest();

               System.assert(!String.isBlank(actCode), 'Update of activity custom settings failed.');
               System.assert(!String.isBlank(progCode), 'Update of program custom settings failed.');
               System.assert(!String.isBlank(modCode), 'Update of module custom settings failed.');
               System.assert(!String.isBlank(scCode), 'Update of short course custom settings failed.');
          }
     }

     private static void createRecord(String productRequestRecordType){
          System.runAs(currentUser){
               Id offeringId = null;

               Activity_Code_Generator__c actCodeGen = new Activity_Code_Generator__c();
               actCodeGen.Type__c = 'Activity';
               actCodeGen.Number__c = 0;
               insert actCodeGen;

               Program_Code_Generator__c prgCodeGen = new Program_Code_Generator__c();
               prgCodeGen.Type__c = 'Program';
               prgCodeGen.Number__c = 0;
               insert prgCodeGen;

               Module_Code_Generator__c modCodeGen = new Module_Code_Generator__c();
               modCodeGen.Type__c = 'Module';
               modCodeGen.Number__c = 0;
               insert modCodeGen;

               Short_Course_Code_Generator__c scCodeGen = new Short_Course_Code_Generator__c();
               scCodeGen.Type__c = 'Short_Course';
               scCodeGen.Number__c = 0;
               insert scCodeGen;

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