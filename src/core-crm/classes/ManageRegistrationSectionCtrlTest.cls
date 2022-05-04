/**
 * @description Test Class for ManageRegistrationSectionCtrl
 * @see ../class/ManageRegistrationSectionCtrl
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | February 08, 2022     | DEPP-1482            | Created file                 | 
      | eccarius.karl.munoz       | February 28, 2022     | DEPP-1819            | Removed handling for Program | 
      |                           |                       |                      | Plan due to program offering | 
      |                           |                       |                      | id removal.                  | 
      |                           |                       |                      |                              |
 */
@isTest(SeeAllData=false)
public with sharing class ManageRegistrationSectionCtrlTest{

     private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
     private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
     private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
     private static final string STUDENT_RT = System.Label.RT_CourseConnection_Student;
     private static final Id STUDENT_RT_ID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(STUDENT_RT).getRecordTypeId();
     private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;     
     private static final Id RT_ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();
     private static final Integer numberOfRecords = 100;

     @IsTest
     static void getPaidInFullValuesTest(){        
          System.runAs(currentUser){               
               Test.startTest();
               List<String> paidInFullValues = ManageRegistrationSectionCtrl.getPaidInFullValues();                 
               Test.stopTest();
               System.assert(!paidInFullValues.isEmpty(), 'Paid in Full Values must not be empty.');
          }      
     } 
     
     @IsTest
     static void getRegistrationStatusValuesTest(){        
          System.runAs(currentUser){               
               Test.startTest();
               List<String> registrationStatusValues = ManageRegistrationSectionCtrl.getRegistrationStatusValues();      
               Test.stopTest();
               System.assert(!registrationStatusValues.isEmpty(), 'Registration Status Values must not be empty.');
          }      
     }

     @IsTest
     static void getPricingValidationValuesTest(){        
          System.runAs(currentUser){               
               Test.startTest();
               List<String> registrationStatusValues = ManageRegistrationSectionCtrl.getPricingValidationValues();      
               Test.stopTest();
               System.assert(!registrationStatusValues.isEmpty(), 'Pricing Validation Values must not be empty.');
          }      
     }

     @IsTest
     static void getRegDetailsForNonProgPlanTest(){        
          System.runAs(currentUser){               
               createRecord(RT_ACTIVITY_ID);  
               String childRecordId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;             
               Test.startTest();
               List<ManageRegistrationSectionCtrl.ManageRegistrationDetails> registrationDetails = ManageRegistrationSectionCtrl.getRegistrations(childRecordId);      
               Test.stopTest();
              System.assertEquals(numberOfRecords, registrationDetails.size(), 'Incorrect number of records retrieved.');
          }      
     }    

     @IsTest
     static void updateRegistrationTest(){        
          System.runAs(currentUser){     
               createRecord(RT_ACTIVITY_ID);    
               String studentId = [SELECT Id FROM hed__Course_Enrollment__c LIMIT 1].Id;
               String questionId = [SELECT Id FROM Questionnaire_Response_Summary__c LIMIT 1].Id;
               String regStatus= 'Confirmed';
               String paidInFull= 'No';    
               String pricingValidation= 'Successful';           
               Test.startTest();
               String updateReponse = ManageRegistrationSectionCtrl.updateRegistration(studentId, questionId, regStatus, paidInFull, pricingValidation, '', ''); 
               Test.stopTest();
               System.assertEquals('Success', updateReponse, 'Update of record failed.');
          }      
     }  
     
     @IsTest
     static void getQuestionsTest(){        
          System.runAs(currentUser){     
               createRecord(RT_ACTIVITY_ID); 
               String prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;           
               Test.startTest();
               List<Related_Answer__c> relatedAnswerList = ManageRegistrationSectionCtrl.getQuestions(prodReqId); 
               Test.stopTest();
               system.assert(!relatedAnswerList.isEmpty(),'Empty related answer');
          }      
     }  

     @IsTest
     static void getSearchedContactsTest(){        
          System.runAs(currentUser){     
               createRecord(RT_ACTIVITY_ID); 
               String prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;           
               Test.startTest();
               List<Map<String,String>> contactMap = ManageRegistrationSectionCtrl.getSearchedContacts('Test',new List<Id>()); 
               Test.stopTest();
               system.assert(!contactMap.isEmpty(),'Empty contact map');
          }      
     }  

     @IsTest
     static void addRegistrationTest(){        
          System.runAs(currentUser){     
               createRecord(RT_ACTIVITY_ID); 
               String cOfferingId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
               Contact newContact = new Contact(FirstName = 'testqtest', LastName = 'testqtest', Email = 'testqtest@emailemail.com');  

               Id relatedQuestionnaireId = [SELECT Id FROM Questionnaire__c  LIMIT 1].Id;
               
               List<Question__c> questionList = TestDataFactory.createTestQuestionRecords(5);
               insert questionList;

               List<Related_Answer__c> relatedAnswers = TestDataFactory.createTestRelatedAnswerRecords(5,relatedQuestionnaireId,questionList);
               insert relatedAnswers;
               List<ManageRegistrationSectionCtrl.FileUpload> fileLoadList = new List<ManageRegistrationSectionCtrl.FileUpload>();
               List<Answer__c> answerList = new List<Answer__c>();
               Answer__c newAnswer;
               ManageRegistrationSectionCtrl.FileUpload fileLoad = new ManageRegistrationSectionCtrl.FileUpload();
               for(Related_Answer__c relatedA: relatedAnswers){
                    newAnswer = new Answer__c(
                         Response__c = relatedA.Id,
                         Related_Answer__c = relatedA.Id
                    );
                    answerList.add(newAnswer);

                    fileLoad.Base64 = 'Test Content';
                    fileLoad.FileName = relatedA.Id;
                    fileLoad.RelatedAnswerId = relatedA.Id;

                    fileLoadList.add(fileLoad);
               }
               
               Test.startTest();
               ManageRegistrationSectionCtrl.addRegistration(newContact,cOfferingId,relatedAnswers,answerList,JSON.serialize(fileLoadList),false); 
               Test.stopTest();
               system.assert(![SELECT Id FROM ContentVersion].isEmpty(), 'Document not created');
               system.assert(![SELECT Id FROM Answer__c].isEmpty(), 'Answer not created');
          }      
     } 


     private static void createRecord(String productRequestRecordType){
          System.runAs(currentUser){
               Id offeringId = null;

               List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
               for(Account account : accounts){
                    account.RecordTypeId = ACCT_UNIV_DEP_ID;
                    account.Organization_Unit_Level__c = '2';
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
                }
               insert contacts;

               List<hed__Course_Enrollment__c> students = new List<hed__Course_Enrollment__c>();
               for(Contact contact : contacts){
                    hed__Course_Enrollment__c student = new hed__Course_Enrollment__c();
                    student.hed__Contact__c = contact.Id;
                    student.RecordTypeId = STUDENT_RT_ID;
                    student.Paid_in_Full__c = 'Yes';
                    student.hed__Course_Offering__c = offeringId;
                    students.add(student);
               }
               insert students;

               Questionnaire__c questionnaire = new Questionnaire__c();
               questionnaire.Questionnaire_Type__c = 'Registration Questions';
               questionnaire.Parent_Record_ID__c = productRequests[0].Id;
               insert questionnaire;
                    
               List<Questionnaire_Response_Summary__c> questionnaireResponseList = new List<Questionnaire_Response_Summary__c>();
               for(Contact contact : contacts){
                    Questionnaire_Response_Summary__c questionResp = new Questionnaire_Response_Summary__c();
                    questionResp.Contact__c = contact.Id;
                    questionResp.Registration_Status__c = 'Confirmed';       
                    questionResp.Questionnaire__c =  questionnaire.Id;          
                    questionResp.Course_Offering__c = offeringId;
                    questionnaireResponseList.add(questionResp);
               }
               insert questionnaireResponseList;

               Related_Answer__c mewRelatedAnswer = new Related_Answer__c(Questionnaire__c = questionnaire.Id);
               insert mewRelatedAnswer;
          }
     } 
}