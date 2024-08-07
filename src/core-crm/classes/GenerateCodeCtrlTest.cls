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
      | arsenio.jr.dayrit         | July 13, 2022         | DEPP-2337            | Modified test method for CCE |
      | alexander.cadalin         | September 05, 2022    | DEPP-4049            | + OPE & CCE, PWP Code Gen    |
 */
@isTest
public with sharing class GenerateCodeCtrlTest{

     private static final String RT_OPE_PRODSPECS = System.Label.RT_ProductSpecification_OPEProgramSpecification;
     private static final Id RT_OPE_ID =  Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get(RT_OPE_PRODSPECS).getRecordTypeId();

     private static final String RT_CCE_PRODSPECS = System.Label.RT_ProductSpecification_CCEProgramSpecification;
     private static final Id RT_CCE_ID =  Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get(RT_CCE_PRODSPECS).getRecordTypeId();

     private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;
     private static final Id RT_ACTIVITY_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();

     private static final String RT_SHORT_COURSE = System.Label.RT_Course_ShortCourse;
     private static final Id RT_SHORT_COURSE_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_SHORT_COURSE).getRecordTypeId();

     private static final String RT_MODULE = System.Label.RT_Course_Module;
     private static final Id RT_MODULE_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_MODULE).getRecordTypeId();

     private static final String RT_UNIT = System.Label.RT_ProductRequest_Unit;
     private static final Id RT_UNIT_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_UNIT).getRecordTypeId();

     private static final String RT_DIAGNOSTIC_TOOL = System.Label.RT_ProductRequest_Diagnostic_Tool;
     private static final Id RT_DT_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_DIAGNOSTIC_TOOL).getRecordTypeId();
     
     private static final String RT_GROUP_COACHING = System.Label.RT_ProductRequest_Group_Coaching;
     private static final Id RT_GC_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_GROUP_COACHING).getRecordTypeId();

     private static final String RT_INDIVIDUAL_COACHING = System.Label.RT_ProductRequest_Individual_Coaching;
     private static final Id RT_IC_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_INDIVIDUAL_COACHING).getRecordTypeId();

     private static final string RT_PROGRAM = System.Label.RT_ProductRequest_Program;
     private static final Id RT_PROGRAM_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_PROGRAM).getRecordTypeId();

     private static final string RT_PWP = System.Label.RT_ProductRequest_Program_Without_Pathway;
     private static final Id RT_PWP_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_PWP).getRecordTypeId();

     private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
     private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

     @TestSetup
     static void makeData(){
          TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
     }
     
     @isTest
     static void getCCECourseDetailsTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_ACTIVITY_ID, RT_CCE_ID);               
               Test.startTest();
               Id recordId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
               GenerateCodeCtrl.CourseProgramDetails details = GenerateCodeCtrl.getCourseAndProgDetails(recordId);
               Test.stopTest();
               System.assert(!String.isBlank(details.recordId), 'Id must not be blank');
          }
     }
     

     @isTest
     static void geOPECourseDetailsTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_ACTIVITY_ID, RT_OPE_ID);               
               Test.startTest();
               Id recordId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
               GenerateCodeCtrl.CourseProgramDetails details = GenerateCodeCtrl.getCourseAndProgDetails(recordId);
               Test.stopTest();
               System.assert(!String.isBlank(details.recordId), 'Id must not be blank');
          }
     }

     @isTest
     static void getCceProgramDetailsTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_PROGRAM_ID, RT_OPE_ID);               
               Test.startTest();
               Id recordId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
               GenerateCodeCtrl.CourseProgramDetails details = GenerateCodeCtrl.getCourseAndProgDetails(recordId);
               Test.stopTest();
               System.assert(!String.isBlank(details.recordId), 'Id must not be blank');
          }
     }

     @isTest
     static void getOpeProgramDetailsTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_PROGRAM_ID, RT_OPE_ID);               
               Test.startTest();
               Id recordId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
               GenerateCodeCtrl.CourseProgramDetails details = GenerateCodeCtrl.getCourseAndProgDetails(recordId);
               Test.stopTest();
               System.assert(!String.isBlank(details.recordId), 'Id must not be blank');
          }
     }

     @isTest
     static void generateOPEActivityCodeTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_ACTIVITY_ID, RT_OPE_ID);               
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_ACTIVITY, RT_OPE_PRODSPECS);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     @isTest
     static void generateCCEActivityCodeTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_ACTIVITY_ID, RT_CCE_ID);               
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_ACTIVITY, RT_CCE_PRODSPECS);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }


     @isTest
     static void generateOPEProgramCodeTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_PROGRAM_ID, RT_OPE_ID);               
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_PROGRAM, RT_OPE_PRODSPECS);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     
     @isTest
     static void generateCCEProgramCodeTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_PROGRAM_ID, RT_CCE_ID);               
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_PROGRAM, RT_CCE_PRODSPECS);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     @isTest
     static void generateOPEModuleCodeTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_MODULE_ID, RT_OPE_ID);               
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_MODULE, RT_OPE_PRODSPECS);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     @isTest
     static void generateCCEModuleCodeTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_MODULE_ID, RT_CCE_ID);               
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_MODULE, RT_CCE_PRODSPECS);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     @isTest
     static void generateOPEShortCodeTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_SHORT_COURSE_ID, RT_OPE_ID);  
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_SHORT_COURSE, RT_OPE_PRODSPECS);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     @isTest
     static void generateCCEShortCodeTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_SHORT_COURSE_ID, RT_CCE_ID);  
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_SHORT_COURSE, RT_CCE_PRODSPECS);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     @isTest
     static void generateUnitCodeTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_UNIT_ID, RT_CCE_ID);  
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_UNIT, RT_CCE_PRODSPECS);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     @isTest
     static void generateDiagnosticToolCodeTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_DT_ID, RT_CCE_ID);  
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_DIAGNOSTIC_TOOL, RT_CCE_PRODSPECS);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     @isTest
     static void generateGroupCoachingCodeTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_GC_ID, RT_CCE_ID);  
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_GROUP_COACHING, RT_CCE_PRODSPECS);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     @isTest
     static void generateIndividualCoachingCodeTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_IC_ID, RT_CCE_ID);  
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_INDIVIDUAL_COACHING, RT_CCE_PRODSPECS);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     @isTest
     static void generateOPEPWPCodeTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_PWP_ID, RT_OPE_ID);               
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_PWP, RT_OPE_PRODSPECS);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     
     @isTest
     static void generateCCEPWPCodeTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_PWP_ID, RT_CCE_ID);               
               Test.startTest();
               GenerateCodeCtrl.CourseProgramDetails code = GenerateCodeCtrl.generateCode(RT_PWP, RT_CCE_PRODSPECS);
               Test.stopTest();
               System.assert(!String.isBlank(code.recordCode), 'Code must not be blank');
          }
     }

     @isTest
     static void updateCodeGeneratorTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(RT_SHORT_COURSE_ID, RT_CCE_ID);               
               Test.startTest();
               String actId;
               List<Activity_Code_Generator__c> actList = [SELECT Id FROM Activity_Code_Generator__c LIMIT 1];
               for(Activity_Code_Generator__c a : actList){ actId = a.Id; }

               String cceActId;
               List<CCE_Activity_Code_Generator__c> cceActList = [SELECT Id FROM CCE_Activity_Code_Generator__c LIMIT 1];
               for(CCE_Activity_Code_Generator__c a : cceActList){ cceActId = a.Id; }

               String prgId;
               List<Program_Code_Generator__c> prgList = [SELECT Id FROM Program_Code_Generator__c LIMIT 1];
               for(Program_Code_Generator__c p : prgList){ prgId = p.Id; }

               String ccePrgId;
               List<CCE_Program_Code_Generator__c> ccePrgList = [SELECT Id FROM CCE_Program_Code_Generator__c LIMIT 1];
               for(CCE_Program_Code_Generator__c p : ccePrgList){ ccePrgId = p.Id; }
               
               String cceModId;
               List<CCE_Module_Code_Generator__c> cceModList = [SELECT Id FROM CCE_Module_Code_Generator__c LIMIT 1];
               for(CCE_Module_Code_Generator__c m : cceModList){ cceModId = m.Id; }

               String modId;
               List<Module_Code_Generator__c> modList = [SELECT Id FROM Module_Code_Generator__c LIMIT 1];
               for(Module_Code_Generator__c m : modList){ modId = m.Id; }

               String scId;
               List<Short_Course_Code_Generator__c> scList = [SELECT Id FROM Short_Course_Code_Generator__c LIMIT 1];
               for(Short_Course_Code_Generator__c s : scList){ scId = s.Id; }

               String cceScId;
               List<CCE_Short_Course_Code_Generator__c> cceScList = [SELECT Id FROM CCE_Short_Course_Code_Generator__c LIMIT 1];
               for(CCE_Short_Course_Code_Generator__c s : cceScList){ cceScId = s.Id; }

               String cceUnitId;
               List<CCE_Unit_Code_Generator__c> cceUnitList = [SELECT Id FROM CCE_Unit_Code_Generator__c LIMIT 1];
               for(CCE_Unit_Code_Generator__c u : cceUnitList){ cceUnitId = u.Id; }

               String cceCoachingId;
               List<CCE_Coaching_Code_Generator__c> cceCoachingList = [SELECT Id FROM CCE_Coaching_Code_Generator__c LIMIT 1];
               for(CCE_Coaching_Code_Generator__c cg : cceCoachingList){ cceCoachingId = cg.Id; }

               String cceDiagToolId;
               List<CCE_Diagnostic_Tool_Code_Generator__c> cceDiagToolList = [SELECT Id FROM CCE_Diagnostic_Tool_Code_Generator__c LIMIT 1];
               for(CCE_Diagnostic_Tool_Code_Generator__c dt : cceDiagToolList){ cceDiagToolId = dt.Id; }

               String cceIndiCoachingId;
               List<CCE_Individual_Coaching_Code_Generator__c> cceIndiCoachingList = [SELECT Id FROM CCE_Individual_Coaching_Code_Generator__c LIMIT 1];
               for(CCE_Individual_Coaching_Code_Generator__c ic : cceIndiCoachingList){ cceIndiCoachingId = ic.Id; }

               String pwpId;
               List<PWP_Code_Generator__c> pwpList = [SELECT Id FROM PWP_Code_Generator__c LIMIT 1];
               for(PWP_Code_Generator__c p : pwpList){ pwpId = p.Id; }

               String ccePWPId;
               List<CCE_PWP_Code_Generator__c> ccePWPList = [SELECT Id FROM CCE_PWP_Code_Generator__c LIMIT 1];
               for(CCE_PWP_Code_Generator__c p : ccePWPList){ ccePWPId = p.Id; }

               GenerateCodeCtrl.CodeGenDetails details = new GenerateCodeCtrl.CodeGenDetails();
               details.recordType = RT_ACTIVITY;
               details.recordId = actId;
               details.recordNumber = 1;
               details.recordCode = 'test';
               details.prodSpecsRecordType = RT_OPE_PRODSPECS;
               String actCode = GenerateCodeCtrl.updateCodeGenerator(details);
               details.recordType = RT_PROGRAM;
               details.recordId = prgId;
               String progCode = GenerateCodeCtrl.updateCodeGenerator(details);
               details.recordType = RT_MODULE;
               details.recordId = modId;
               String modCode = GenerateCodeCtrl.updateCodeGenerator(details);
               details.recordType = RT_SHORT_COURSE;
               details.recordId = scId;
               String scCode = GenerateCodeCtrl.updateCodeGenerator(details);
               details.recordType = RT_PWP;
               details.recordId = pwpId;
               details.recordNumber = 601;
               String pwpCode = GenerateCodeCtrl.updateCodeGenerator(details);
               details.recordType = RT_ACTIVITY;
               details.recordId = cceActId;
               details.prodSpecsRecordType = RT_CCE_PRODSPECS;
               String cceActCode = GenerateCodeCtrl.updateCodeGenerator(details);
               details.recordType = RT_PROGRAM;
               details.recordId = ccePrgId;
               String cceProgCode = GenerateCodeCtrl.updateCodeGenerator(details);
               details.recordType = RT_MODULE;
               details.recordId = cceModId;
               String cceModCode = GenerateCodeCtrl.updateCodeGenerator(details);
               details.recordType = RT_SHORT_COURSE;
               details.recordId = cceScId;
               String cceScCode = GenerateCodeCtrl.updateCodeGenerator(details);
               details.recordType = RT_UNIT;
               details.recordId = cceUnitId;
               String cceUnitCode = GenerateCodeCtrl.updateCodeGenerator(details);
               details.recordType = RT_GROUP_COACHING;
               details.recordId = cceCoachingId;
               String cceGroupCoachingCode = GenerateCodeCtrl.updateCodeGenerator(details);
               details.recordType = RT_INDIVIDUAL_COACHING;
               details.recordId = cceIndiCoachingId;
               String cceIndiCoachingCode = GenerateCodeCtrl.updateCodeGenerator(details);
               details.recordType = RT_DIAGNOSTIC_TOOL;
               details.recordId = cceDiagToolId;
               details.recordNumber = 600;
               String cceDiagToolCode = GenerateCodeCtrl.updateCodeGenerator(details);
               details.recordType = RT_PWP;
               details.recordId = ccePWPId;
               details.recordNumber = 601;
               String ccePWPCode = GenerateCodeCtrl.updateCodeGenerator(details);

               Test.stopTest();

               System.assert(!String.isBlank(actCode), 'Update of activity custom settings failed.');
               System.assert(!String.isBlank(progCode), 'Update of program custom settings failed.');
               System.assert(!String.isBlank(modCode), 'Update of module custom settings failed.');
               System.assert(!String.isBlank(scCode), 'Update of short course custom settings failed.');
               System.assert(!String.isBlank(pwpCode), 'Update of OPE program without pathway custom settings failed.');
               System.assert(!String.isBlank(cceActCode), 'Update of activity custom settings failed.');
               System.assert(!String.isBlank(cceProgCode), 'Update of program custom settings failed.');
               System.assert(!String.isBlank(cceModCode), 'Update of module custom settings failed.');
               System.assert(!String.isBlank(cceScCode), 'Update of short course custom settings failed.');
               System.assert(!String.isBlank(cceUnitCode), 'Update of short course custom settings failed.');
               System.assert(!String.isBlank(cceGroupCoachingCode), 'Update of program custom settings failed.');
               System.assert(!String.isBlank(cceIndiCoachingCode), 'Update of module custom settings failed.');
               System.assert(!String.isBlank(cceDiagToolCode), 'Update of short course custom settings failed.');
               System.assert(!String.isBlank(ccePWPCode), 'Update of CCE program without pathway custom settings failed.');
          }
     }

     private static void createRecord(String productRequestRecordType, String productSpecsRecordType){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

               Activity_Code_Generator__c actCodeGen = new Activity_Code_Generator__c();
               actCodeGen.Type__c = 'Activity';
               actCodeGen.Number__c = 0;
               insert actCodeGen;

               CCE_Activity_Code_Generator__c cceActCodeGen = new CCE_Activity_Code_Generator__c();
               cceActCodeGen.Type__c = 'Activity';
               cceActCodeGen.Number__c = 0;
               insert cceActCodeGen;

               Program_Code_Generator__c prgCodeGen = new Program_Code_Generator__c();
               prgCodeGen.Type__c = 'Program';
               prgCodeGen.Number__c = 0;
               insert prgCodeGen;

               CCE_Program_Code_Generator__c ccePrgCodeGen = new CCE_Program_Code_Generator__c();
               ccePrgCodeGen.Type__c = 'Program';
               ccePrgCodeGen.Number__c = 0;
               insert ccePrgCodeGen;

               Module_Code_Generator__c modCodeGen = new Module_Code_Generator__c();
               modCodeGen.Type__c = 'Module';
               modCodeGen.Number__c = 0;
               insert modCodeGen;

               CCE_Module_Code_Generator__c cceModCodeGen = new CCE_Module_Code_Generator__c();
               cceModCodeGen.Type__c = 'Module';
               cceModCodeGen.Number__c = 0;
               insert cceModCodeGen;

               Short_Course_Code_Generator__c scCodeGen = new Short_Course_Code_Generator__c();
               scCodeGen.Type__c = 'Short_Course';
               scCodeGen.Number__c = 0;
               insert scCodeGen;

               CCE_Short_Course_Code_Generator__c cceScCodeGen = new CCE_Short_Course_Code_Generator__c();
               cceScCodeGen.Type__c = 'Short_Course';
               cceScCodeGen.Number__c = 0;
               insert cceScCodeGen;

               CCE_Unit_Code_Generator__c cceUnitCodeGen = new CCE_Unit_Code_Generator__c();
               cceUnitCodeGen.Type__c = 'Unit';
               cceUnitCodeGen.Number__c = 0;
               insert cceUnitCodeGen;

               CCE_Coaching_Code_Generator__c cceCoachingCodeGen = new CCE_Coaching_Code_Generator__c();
               cceCoachingCodeGen.Type__c = 'Group_Coaching';
               cceCoachingCodeGen.Number__c = 0;
               insert cceCoachingCodeGen;

               CCE_Individual_Coaching_Code_Generator__c cceIndiCoachingCodeGen = new CCE_Individual_Coaching_Code_Generator__c();
               cceIndiCoachingCodeGen.Type__c = 'Individual_Coaching';
               cceIndiCoachingCodeGen.Number__c = 0;
               insert cceIndiCoachingCodeGen;

               CCE_Diagnostic_Tool_Code_Generator__c cceDiagToolCodeGen = new CCE_Diagnostic_Tool_Code_Generator__c();
               cceDiagToolCodeGen.Type__c = 'Diagnostic_Tool';
               cceDiagToolCodeGen.Number__c = 0;
               insert cceDiagToolCodeGen;

               PWP_Code_Generator__c pwpCodeGen = new PWP_Code_Generator__c();
               pwpCodeGen.Type__c = 'Program_Without_Pathway';
               pwpCodeGen.Number__c = 0;
               insert pwpCodeGen;

               CCE_PWP_Code_Generator__c ccePWPCodeGen = new CCE_PWP_Code_Generator__c();
               ccePWPCodeGen.Type__c = 'Program_Without_Pathway';
               ccePWPCodeGen.Number__c = 0;
               insert ccePWPCodeGen;

               List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
               for(Account acc : accounts){
                    acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                    acc.Organization_Unit_Level__c = '2';
               }
               insert accounts;

               List<Contact> conList = TestDataFactory.createTestContactRecords(1);
               insert conList;
       
               List<Opportunity> oppList;
               List<Product_Specification__c> prodSpecs;
               if(productSpecsRecordType == RT_CCE_ID){
                    oppList = TestDataFactory.createClosedWonOpportunities(1, accounts[0].Id, conList.iterator().next()?.Id);
                    insert oppList;
                    prodSpecs = TestDataFactory.retrieveCCEProductSpecifications();
               } else if(productSpecsRecordType == RT_OPE_ID){
                    oppList = TestDataFactory.createTestOpportunityRecords(1, accounts[0].Id, conList.iterator().next()?.Id);
                    insert oppList;
                    prodSpecs = TestDataFactory.createTestProductSpecsRecords(1, conList, oppList);
                    prodSpecs[0].RecordTypeId = RT_OPE_ID;
                    prodSpecs[0].Stage__c = 'Idea';
                    insert prodSpecs;
               }

               List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
               for(Product_Request__c productRequest : productRequests){
                    productRequest.RecordTypeId = productRequestRecordType;
                    productRequest.Product_Specification__c = prodSpecs[0].Id;
               }
               insert productRequests;

               if(productRequestRecordType == RT_PROGRAM_ID || productRequestRecordType == RT_PWP_ID){
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