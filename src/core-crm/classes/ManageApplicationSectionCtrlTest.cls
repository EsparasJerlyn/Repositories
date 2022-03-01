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
@isTest(SeeAllData=false)
public with sharing class ManageApplicationSectionCtrlTest {

     private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static String rtProdRequestActivity = System.Label.RT_ProductRequest_Activity;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     private static Id opeActProdReqRecType = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(rtProdRequestActivity).getRecordTypeId();
     private static Integer numberOfRecords = 100;

     @IsTest
     static void getApplicationStatusValuesTest(){        
          System.runAs(currentUser){               
               Test.startTest();
               List<String> appStatusValues = ManageApplicationSectionCtrl.getApplicationStatusValues();                 
               Test.stopTest();
               System.assert(!appStatusValues.isEmpty(), 'Application Status Values must not be empty.');
          }      
     } 

     @IsTest
     static void getStudentApplicationsTest(){        
          System.runAs(currentUser){               
               createRecord(opeActProdReqRecType);  
               String prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;             
               Test.startTest();
               List<ManageApplicationSectionCtrl.ManageApplicationDetails> applicationDetails = ManageApplicationSectionCtrl.getStudentApplications(prodReqId);      
               Test.stopTest();
               System.assertEquals(numberOfRecords, applicationDetails.size(), 'Incorrect number of records retrieved.');
          }      
     }

     @IsTest
     static void updateStudentApplicationTest(){        
          System.runAs(currentUser){     
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

     @IsTest
     static void getStudAppNoOfferingTest(){        
          System.runAs(currentUser){               
               List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
               for(Product_Request__c productRequest : productRequests){
                    productRequest.RecordTypeId = opeActProdReqRecType;
               }
               insert productRequests;
               String prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;             
               Test.startTest();
               List<ManageApplicationSectionCtrl.ManageApplicationDetails> applicationDetails = ManageApplicationSectionCtrl.getStudentApplications(prodReqId);      
               Test.stopTest();
               System.assertNotEquals(numberOfRecords, applicationDetails.size(), 'Records to be retrieved must be link with an offering.');
          }      
     }            

     private static void createRecord(String productRequestRecordType){
          System.runAs(currentUser){
               Id offeringId = null;

               List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
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
               insert contacts;

               List<hed__Course_Enrollment__c> students = new List<hed__Course_Enrollment__c>();
               for(Contact contact : contacts){
                    hed__Course_Enrollment__c student = new hed__Course_Enrollment__c();
                    student.hed__Contact__c = contact.Id;
                    student.RecordTypeId = studentRecTypeId;
                    student.Paid_in_Full__c = 'Yes';
                    student.hed__Course_Offering__c = offeringId;
                    students.add(student);
               }
               insert students;

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