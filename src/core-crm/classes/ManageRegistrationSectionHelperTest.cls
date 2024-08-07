/**
 * @description helper class for manageregistrationsectionhelper
 * @see ../manageregistrationsectionhelper
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | November 15, 2022     | DEPP-4721            | Created file                 | 
*/
@isTest
public class ManageRegistrationSectionHelperTest {
     private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;
     private static final Id RT_ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();
     private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
     private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
     private static final string STUDENT_RT = System.Label.RT_CourseConnection_Student;
     private static final Id STUDENT_RT_ID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(STUDENT_RT).getRecordTypeId();
     private static final Integer NUMBER_OF_RECORDS = 10;
     private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;
     private static final Id RT_CONTACT_PERSON_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
          .get(RT_CONTACT_PERSON)
          .getRecordTypeId();

     @testSetup
     static void setupData(){
          
          Test.startTest();
          TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
          TestDataFactoryUser.generateUserSystemAdministrator();
          Test.stopTest();
          createRecord(RT_ACTIVITY_ID);
     }

     @isTest
     static void addRegistrationNewContactTest(){
          final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
          System.runAs(PORTAL_SYS_ADMIN){
               Account portalAccount = new Account(Name='TestAccount', OwnerId = PORTAL_SYS_ADMIN.Id);
               Database.insert(portalAccount);

               Contact learnerContact = new Contact(FirstName = 'learner', LastName = 'test', AccountId = portalAccount.Id, Email = 'testqtest@emailemail.com', Registered_Email__c ='learner@email.com', Birthdate = Date.newInstance(1991, 2, 17), MobilePhone ='012345');
               Contact newContact = new Contact( FirstName = 'testqtest', LastName = 'testqtest', AccountId = portalAccount.Id, Email = 'testqtest2@emailemail.com', Registered_Email__c ='testqtest2@emailemail.com', Birthdate = Date.newInstance(1990, 2, 17), MobilePhone ='012345');
               insert newContact;

               User portalUser = TestDataFactory.createPortalUserRecords(1, 'Corporate Partner User', newContact.Id).iterator().next();
               Database.insert(portalUser);

               WebStore testWebStore = new WebStore(
                    Name = 'Study',
                    DefaultLanguage = 'en_US'
               );
               insert testWebStore;

               WebCart cart = new WebCart(
                    Name = 'Cart',
                    AccountId = portalAccount.Id,
                    Status = 'Closed',
                    Status__c = 'Active',
                    WebStoreId = testWebStore.Id,
                    OwnerId = portalUser.Id
               );
               insert cart;

               String cOfferingId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
               Id relatedQuestionnaireId = [SELECT Id FROM Questionnaire__c  LIMIT 1].Id;

               List<Question__c> questionList = TestDataFactory.createTestQuestionRecords(5);
               insert questionList;

               List<Related_Answer__c> relatedAnswers = TestDataFactory.createTestRelatedAnswerRecords(5,relatedQuestionnaireId,questionList);
               insert relatedAnswers;
               List<FileUpload> fileLoadList = new List<FileUpload>();
               List<Answer__c> answerList = new List<Answer__c>();
               Answer__c newAnswer;
               FileUpload fileLoad = new FileUpload();
               for(Related_Answer__c relatedA: relatedAnswers){
                    newAnswer = new Answer__c(
                         Response__c = relatedA.Id,
                         Related_Answer__c = relatedA.Id
                    );
                    answerList.add(newAnswer);

                    fileLoad.base64 = 'Test Content';
                    fileLoad.fileName = relatedA.Id;
                    fileLoad.relatedAnswerId = relatedA.Id;

                    fileLoadList.add(fileLoad);
               }

               Id pbeId;
               List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry LIMIT 1];
               for(PricebookEntry pbe : pbeList){ pbeId = pbe.Id; }

               Test.startTest();
               ManageRegistrationEnrolmentHelper.EnrolmentResultClass enrolmentResult = new ManageRegistrationEnrolmentHelper.EnrolmentResultClass();
               ManageRegistrationSectionHelper.RegistrationData registrationData = new ManageRegistrationSectionHelper.RegistrationData();

               registrationData.contactRecord = learnerContact;
               registrationData.offeringId = cOfferingId;
               registrationData.relatedAnswerList = relatedAnswers;
               registrationData.answerList = answerList;
               registrationData.prescribedProgram = false;
               registrationData.priceBookEntryId = pbeId;
               registrationData.isProceedNoInvoice = false;
               registrationData.discountAmount = 0;
               registrationData.promotionId = null;

               enrolmentResult = ManageRegistrationEnrolmentHelper.addRegistration(JSON.serialize(registrationData),JSON.serialize(fileLoadList));
               Test.stopTest();
               System.assert(enrolmentResult.contactName != null, 'No enrolment created');
          }
     }

     @isTest
     static void addRegistrationNewContactWithInvoiceTest(){
          final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
          System.runAs(PORTAL_SYS_ADMIN){
               Account portalAccount = new Account(Name='TestAccount', OwnerId = PORTAL_SYS_ADMIN.Id);
               Database.insert(portalAccount);

               Contact learnerContact = new Contact(FirstName = 'learner', LastName = 'test', AccountId = portalAccount.Id, Email = 'testqtest@emailemail.com', Registered_Email__c ='learner@email.com', Birthdate = Date.newInstance(1991, 2, 17), MobilePhone ='012345');
               Contact newContact = new Contact( FirstName = 'testqtest', LastName = 'testqtest', AccountId = portalAccount.Id, Email = 'testqtest2@emailemail.com', Registered_Email__c ='testqtest2@emailemail.com', Birthdate = Date.newInstance(1990, 2, 17), MobilePhone ='012345');
               insert newContact;

               User portalUser = TestDataFactory.createPortalUserRecords(1, 'Corporate Partner User', newContact.Id).iterator().next();
               Database.insert(portalUser);

               WebStore testWebStore = new WebStore(
                    Name = 'Study',
                    DefaultLanguage = 'en_US'
               );
               insert testWebStore;

               WebCart cart = new WebCart(
                    Name = 'Cart',
                    AccountId = portalAccount.Id,
                    Status = 'Closed',
                    Status__c = 'Active',
                    WebStoreId = testWebStore.Id,
                    OwnerId = portalUser.Id
               );
               insert cart;

               String cOfferingId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
               Id relatedQuestionnaireId = [SELECT Id FROM Questionnaire__c  LIMIT 1].Id;

               List<Question__c> questionList = TestDataFactory.createTestQuestionRecords(5);
               insert questionList;

               List<Related_Answer__c> relatedAnswers = TestDataFactory.createTestRelatedAnswerRecords(5,relatedQuestionnaireId,questionList);
               insert relatedAnswers;
               List<FileUpload> fileLoadList = new List<FileUpload>();
               List<Answer__c> answerList = new List<Answer__c>();
               Answer__c newAnswer;
               FileUpload fileLoad = new FileUpload();
               for(Related_Answer__c relatedA: relatedAnswers){
                    newAnswer = new Answer__c(
                         Response__c = relatedA.Id,
                         Related_Answer__c = relatedA.Id
                    );
                    answerList.add(newAnswer);

                    fileLoad.base64 = 'Test Content';
                    fileLoad.fileName = relatedA.Id;
                    fileLoad.relatedAnswerId = relatedA.Id;

                    fileLoadList.add(fileLoad);
               }

               Id pbeId;
               List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry LIMIT 1];
               for(PricebookEntry pbe : pbeList){ pbeId = pbe.Id; }

               Test.startTest();
               ManageRegistrationEnrolmentHelper.EnrolmentResultClass enrolmentResult = new ManageRegistrationEnrolmentHelper.EnrolmentResultClass();
               ManageRegistrationSectionHelper.RegistrationData registrationData = new ManageRegistrationSectionHelper.RegistrationData();

               registrationData.contactRecord = learnerContact;
               registrationData.offeringId = cOfferingId;
               registrationData.relatedAnswerList = relatedAnswers;
               registrationData.answerList = answerList;
               registrationData.prescribedProgram = false;
               registrationData.priceBookEntryId = pbeId;
               registrationData.isProceedNoInvoice = true;
               registrationData.discountAmount = 0;
               registrationData.promotionId = null;

               enrolmentResult = ManageRegistrationEnrolmentHelper.addRegistration(JSON.serialize(registrationData),JSON.serialize(fileLoadList));
               Test.stopTest();
               System.assert(enrolmentResult.contactName != null, 'No enrolment created');
          }
     }

     private static void createRecord(String productRequestRecordType){
          System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

               BuyerGroup bg = new BuyerGroup();
               bg.Name = 'OPE BuyerGroup';
               insert bg;

               List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
               for(Account account : accounts){
                    account.RecordTypeId = ACCT_UNIV_DEP_ID;
                    account.Organization_Unit_Level__c = '2';
                }
               insert accounts;

               Account act = new Account(Name = 'QUT Experience');
               insert act;

               List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
               for(Product_Request__c productRequest : productRequests){
                    productRequest.RecordTypeId = productRequestRecordType;
               }
               insert productRequests;

               List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
               insert courses;

               Pricebook2 priceBook;
               pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
               update pricebook;

               Product2 product = new Product2(Name = courses[0].Name, Course__c = courses[0].Id);
               insert product;

               PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, IsActive = true, Pricebook2Id = priceBook.Id, UnitPrice = 250.00);
               insert pbe;

               List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, accounts[0].Id);
               insert terms;

               List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
               insert courseOfferings;

               Questionnaire__c questionnaire = new Questionnaire__c();
               questionnaire.Questionnaire_Type__c = 'Registration Questions';
               questionnaire.Parent_Record_ID__c = productRequests[0].Id;
               insert questionnaire;
          }
     } 


     private class FileUpload{
          private String base64;
          private String fileName;
          private String relatedAnswerId;
      }
      
}