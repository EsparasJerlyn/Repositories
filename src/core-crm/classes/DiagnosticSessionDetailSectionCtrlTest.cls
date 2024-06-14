/**
 * @description Test Class for DiagnosticSessionDetailSectionCtrl
 * @see ../class/DiagnosticSessionDetailSectionCtrl
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | rhea.b.torres             | July 19, 2022         | DEPP-2002            | Created file                 |
*/
@isTest
public without sharing class DiagnosticSessionDetailSectionCtrlTest {

     private static final String PR_DIAGNOSTIC = System.Label.RT_ProductRequest_Diagnostic_Tool;
     private static final Id DIAGNOSTIC_REC_TYPE_ID =  Schema.SObjectType.Product_Request__c
          .getRecordTypeInfosByDeveloperName()
          .get(PR_DIAGNOSTIC).getRecordTypeId();
     private static final String RT_STUDENT = System.Label.RT_CourseConnection_Student;
     private static final Id STUDENT_REC_TYPE_ID = Schema.SObjectType.hed__Course_Enrollment__c
          .getRecordTypeInfosByDeveloperName()
          .get(RT_STUDENT).getRecordTypeId();
     private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
     private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account
          .getRecordTypeInfosByDeveloperName()
          .get(ACCT_UNIV_DEP).getRecordTypeId();
     private static final Integer NUM_RECORDS = 5;

     @testSetup
     static void makeData(){
          Test.startTest();
          TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
          Test.stopTest();
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(PR_DIAGNOSTIC);
          }
     }

     @isTest
     public static void getRegisteredLearnersTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               Test.startTest();
               hed__Course_Offering__c courseOffering = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
               List<DiagnosticSessionDetailSectionCtrl.DiagnosticSessionSectionDetails> response = 
               DiagnosticSessionDetailSectionCtrl.getRegisteredLearners(courseOffering.Id);
               System.assert(response != null, 'response is null');
               System.assertEquals(NUM_RECORDS, response.size(), 'response is empty');
               Test.stopTest();
          }
     }

     @isTest
     public static void getRegisteredLearnersTestNull(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               Test.startTest();
               List<DiagnosticSessionDetailSectionCtrl.DiagnosticSessionSectionDetails> response = 
               DiagnosticSessionDetailSectionCtrl.getRegisteredLearners(null);
               System.assertEquals(0, response.size(), 'response is null');
               Test.stopTest();
          }
     }

     @isTest
     public static void getSessionStatusValuesTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               List<String> picklist = DiagnosticSessionDetailSectionCtrl.getSessionStatusValues();
               System.assert(picklist != null, 'No values returned');
               System.assertEquals(2, picklist.size(), 'Number of picklist count is more than 2');
               for(String val : picklist){
                    System.assert((val.equals('Completed') || val.equals('Cancelled')),'Incorrect picklist values');
               }
          }
     }

     private static void createRecord(String productRequestRecordType){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               /** Create Account */
               List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
               for(Account account : accounts){
                    account.RecordTypeId = ACCT_UNIV_DEP_ID;
                    account.Organization_Unit_Level__c = '2';
               }
               insert accounts;

               /**Create Contact */
               List<Contact> conList;
               conList = TestDataFactory.createTestContactRecords(1);
               insert conList;

               /**Create Opportunity */
               List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(1,accounts[0].Id,conList[0].Id);
               insert oppList;
               Opportunity oppty = [SELECT Id, StageName, Status__c, Program_Name__c FROM Opportunity LIMIT 1];
               oppList[0].StageName = 'Closed Won';
               oppList[0].Status__c = 'Contract Signed';
               oppList[0].CloseDate = Date.today();
               oppList[0].Program_Name__c = 'CCE Product Specs';
               update oppty;

               List<Product_Specification__c> productSpecs = TestDataFactory.createTestProductSpecsRecords(1,conList,oppList);
               insert productSpecs;

               /**Create  Product Request*/  
               List<Product_Request__c> diagnosticProdRequest = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
               diagnosticProdRequest[0].Product_Request_Name__c = PR_DIAGNOSTIC;
               diagnosticProdRequest[0].RecordTypeId = DIAGNOSTIC_REC_TYPE_ID;
               insert diagnosticProdRequest;

               /** Create Course */
               List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, diagnosticProdRequest[0].Id);
               insert courses;

               /**Create Term */
               List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, accounts[0].Id);
               insert terms;

               /**Create Course Offering */
               List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
               insert courseOfferings;

               /**Create Contact */
               List<Contact> contacts = TestDataFactory.createTestContactRecords(NUM_RECORDS);
               for(Integer i =0; i<contacts.size(); i++){
                    contacts[i].Registered_Email__c = 'testIdeaFormUser'+i+'@mailinator.com';
                }
               insert contacts;

               /**Create Course Connection */
               List<hed__Course_Enrollment__c> students = new List<hed__Course_Enrollment__c>();
               for(Contact contact : contacts){
                    hed__Course_Enrollment__c student = new hed__Course_Enrollment__c();
                    student.hed__Contact__c = contact.Id;
                    student.RecordTypeId = STUDENT_REC_TYPE_ID;
                    student.hed__Course_Offering__c = courseOfferings[0].Id;
                    student.hed__Status__c = 'Active';
                    students.add(student);
               }
               insert students;
          }
     }
}