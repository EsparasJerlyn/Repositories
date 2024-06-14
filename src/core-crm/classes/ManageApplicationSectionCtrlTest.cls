/**
 * @description Test Class for ManageApplicationSectionCtrl
 * @see ../class/ManageApplicationSectionCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | February 08, 2022     | DEPP-1483            | Created file                 |
      | eccarius.karl.munoz       | February 28, 2022     | DEPP-1819            | Removed handling for Program |
      |                           |                       |                      | Plan due to program offering |
      |                           |                       |                      | id removal.                  |
      |                           |                       |                      |                              |
 */
@isTest
public with sharing class ManageApplicationSectionCtrlTest {

     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static String rtProdRequestActivity = System.Label.RT_ProductRequest_Activity;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     private static Id opeActProdReqRecType = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(rtProdRequestActivity).getRecordTypeId();
     private static Integer numberOfRecords = 2;
     private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
     private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
     private static final String SEND_APPLICATION_RESPONSE_TEMPLATE = 'Send Application Response Email';
     private static final String APPLICATION_APPROVED_TEMPLATE = 'Application Email Approved';
     private static final String APPLICATION_REJECTED_TEMPLATE = 'Application Email Rejected';

    @testSetup
     static void setupMethod(){
          Test.startTest();
          TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
          Test.stopTest();
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               List<EmailTemplate> emailTemplateList = TestDataFactory.createTestEmailTemplateRecords(3,new Map<String,String>{
                    SEND_APPLICATION_RESPONSE_TEMPLATE => 'Test Email Subject1',
                    APPLICATION_APPROVED_TEMPLATE => 'Test Email Subject2',
                    APPLICATION_REJECTED_TEMPLATE => 'Test Email Subject3'
               });
               insert emailTemplateList;
          }

          Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
          insert customEmail;

          Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Name='QUTeX',Study_Store_Link__c = 'https://studystorelinktest.com/');
          insert studyStore;
     }
    
     @isTest
     static void getApplicationStatusValuesTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               Test.startTest();
               List<String> appStatusValues = ManageApplicationSectionCtrl.getApplicationStatusValues();
               Test.stopTest();
               System.assert(!appStatusValues.isEmpty(), 'Application Status Values must not be empty.');
          }
     }

     @isTest
     static void getStudentApplicationsTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(opeActProdReqRecType);
               String offeringId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
               Test.startTest();
               List<ManageApplicationSectionCtrl.ManageApplicationDetails> applicationDetails = ManageApplicationSectionCtrl.getStudentApplications(offeringId);
               Test.stopTest();
               System.assertEquals(numberOfRecords, applicationDetails.size(), 'Incorrect number of records retrieved.');
          }
     }

     @isTest
     static void updateStudentApplicationTest(){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
               createRecord(opeActProdReqRecType);
               String questionId = [SELECT Id FROM Questionnaire_Response_Summary__c LIMIT 1].Id;
               String applicationStatus= 'Rejected';
               String reasonForRejection= 'Test Update';
               Test.startTest();
               String updateReponse = ManageApplicationSectionCtrl.updateStudentApplication(questionId, applicationStatus, reasonForRejection);
               Test.stopTest();
               System.assertEquals('Success', updateReponse, 'Update of record failed.');
          }
     }

     private static void createRecord(String productRequestRecordType){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
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

                List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
                insert courses;

                List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, accounts[0].Id);
                insert terms;

                List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
                insert courseOfferings;

                offeringId = courseOfferings[0].Id;

                List<Contact> contacts = TestDataFactory.createTestContactRecords(numberOfRecords);
                for(Integer i =0;i<contacts.size();i++){
                    contacts[i].Email = 'testIdeaFormUser'+i+'@mailinator.com';
                    contacts[i].Registered_Email__c = 'registeredEmail'+i+'@mailinator.com';
                }
                insert contacts;
                
                Questionnaire__c questionnaire = new Questionnaire__c();
                questionnaire.Questionnaire_Type__c = 'Application Questions';
                insert questionnaire;

                List<Questionnaire_Response_Summary__c> questionnaireResponseList = new List<Questionnaire_Response_Summary__c>();
                for(Contact contact : contacts){
                    Questionnaire_Response_Summary__c questionResp = new Questionnaire_Response_Summary__c();
                    questionResp.Contact__c = contact.Id;
                    questionResp.Application_Status__c = 'Pending';
                    questionResp.Questionnaire__c =  questionnaire.Id;
                    questionResp.Course_Offering__c = offeringId;
                    questionnaireResponseList.add(questionResp);
                }
                insert questionnaireResponseList;
          }
     }

}
