/**
 * @description Test Class for QuestionnaireResponseSummaryCtrl
 * @see ../class/QuestionnaireResponseSummaryCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                            |
      |---------------------------|-----------------------|----------------------|-----------------------------------------------------------|
      | john.bo.a.pineda          | March 15, 2022        | DEPP-1643            | Created file                                              |
      | roy.nino.s.regala         | June 23,2022          | DEPP-3252            | added logic to create cartitems and construct pay now url |
 */
@isTest
public with sharing class QuestionnaireResponseSummaryCtrlTest {
  private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Student')
    .getRecordTypeId();
  private static Id ACTIVITY_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
    .get('Activity')
    .getRecordTypeId();
  private static Integer numberOfRecords = 30;
  private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
  private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
  private static final String EMAIL_TEMPLATE1 = 'Application Email Approved';
  private static final String EMAIL_TEMPLATE2 = 'Send Application Response Email';

  @testSetup
  static void setupMethod(){
    BypassTriggers__c bypass = new BypassTriggers__c(Bypass__c = true, SetupOwnerId = UserInfo.getOrganizationId());
    insert bypass;
    Test.startTest();
    TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    TestDataFactoryUser.generateUserSystemAdministrator();
    Test.stopTest();
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
      List<EmailTemplate> templateList = TestDataFactory.createTestEmailTemplateRecords(2,new Map<String,String>{
        EMAIL_TEMPLATE1 => 'Test Email Subject',
        EMAIL_TEMPLATE2 => 'Test Email Subject'});
      insert templateList;
    }

    Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
    insert customEmail;

    Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Name='QUTeX', Study_Store_Link__c = 'https://studystorelinktest.com/');
    insert studyStore;
    createRecord(ACTIVITY_RECTYPEID);
  }

  @isTest
  static void getAppQuestionsQRSDetailsTest() {
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
      String qrsId = [
        SELECT Id
        FROM Questionnaire_Response_Summary__c
        WHERE Questionnaire__r.Questionnaire_Type__c = 'Application Questions'
        LIMIT 1
      ]
      .Id;

      Test.startTest();
      QuestionnaireResponseSummaryCtrl.QuestionnaireResponseSummaryWrapper qrsAppQuestionDetails = QuestionnaireResponseSummaryCtrl.getQuestionnaireResponseSummaryDetails(
        qrsId
      );
      Test.stopTest();

      System.assertNotEquals(null, qrsAppQuestionDetails, 'No data retrieved');
    }
  }

  @isTest
  static void getRegQuestionsQRSDetailsTest() {
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
      String qrsId = [
        SELECT Id
        FROM Questionnaire_Response_Summary__c
        WHERE Questionnaire__r.Questionnaire_Type__c = 'Registration Questions'
        LIMIT 1
      ]
      .Id;

      Test.startTest();
      QuestionnaireResponseSummaryCtrl.QuestionnaireResponseSummaryWrapper qrsRegQuestionDetails = QuestionnaireResponseSummaryCtrl.getQuestionnaireResponseSummaryDetails(
        qrsId
      );
      Test.stopTest();

      System.assertNotEquals(null, qrsRegQuestionDetails, 'No data retrieved');
    }
  }

  @isTest
  static void getRegCriteriaQRSDetailsTest() {
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
      String qrsId = [
        SELECT Id
        FROM Questionnaire_Response_Summary__c
        WHERE Questionnaire__r.Questionnaire_Type__c = 'Registration Criteria'
        LIMIT 1
      ]
      .Id;

      Test.startTest();
      QuestionnaireResponseSummaryCtrl.QuestionnaireResponseSummaryWrapper qrsRegCriteriaDetails = QuestionnaireResponseSummaryCtrl.getQuestionnaireResponseSummaryDetails(
        qrsId
      );
      Test.stopTest();

      System.assertNotEquals(null, qrsRegCriteriaDetails, 'No data retrieved');
    }
  }

  @isTest
  static void updateApplicationStatusTest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    System.runAs(PORTAL_SYS_ADMIN){
      Test.startTest();
      //Create account
      Account portalAccount1 = new Account(
          Name = 'QUT Experience',
          OwnerId = PORTAL_SYS_ADMIN.Id
      );

      Database.insert(portalAccount1);

      //Create contact
      Contact contact1 = new Contact(
        FirstName = 'Test',
        Lastname = 'McTesty',
        AccountId = portalAccount1.Id,
        Email = System.now().millisecond() + 'test@test.com',
        Registered_Email__c = System.now().millisecond() + 'test@test.com'
      );
      Database.insert(contact1);

      //Create user
      User portalUser = TestDataFactory.createPortalUserRecords(
          1,
          'Corporate Partner User',
          contact1.Id
        )
        .iterator()
        .next();
      Database.insert(portalUser);

      WebStore testWebStore = new WebStore(
      Name = 'Study',
      DefaultLanguage = 'en_US'
      );
      insert testWebStore;
    
      WebCart cart = new WebCart( Name = 'Cart', AccountId = portalAccount1.Id, Status = 'Active', Status__c = 'Active',
      WebStoreId = testWebStore.Id, OwnerId = portalUser.Id
      );
      insert cart;

    CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
      CartId = cart.Id,
      Name = 'Default Delivery'
    );
    insert cartDeliveryGroup;

      Questionnaire_Response_Summary__c qrsId = [
        SELECT Id, 
        Contact__c,
        Questionnaire__r.Parent_Record_ID__c
        FROM Questionnaire_Response_Summary__c
        WHERE Questionnaire__r.Questionnaire_Type__c = 'Application Questions'
        LIMIT 1
      ];

      Product2 product = [SELECT Id FROM Product2 WHERE Course__r.ProductRequestID__c =: qrsId.Questionnaire__r.Parent_Record_ID__c];

      Pricebook2 priceBook;
      pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
      update pricebook;

      PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, IsActive = true, Pricebook2Id = priceBook.Id, UnitPrice = 250.00);
      insert pbe;

      qrsId.Contact__c = [SELECT Id FROM Contact WHERE Lastname = 'McTesty']?.Id;
      qrsId.Pricebook_Entry_ID__c = pbe.Id;
      update qrsId;

      QuestionnaireResponseSummaryCtrl.updateApplicationStatus(
        qrsId.Id,
        'Approved',
        null
      );
      Test.stopTest();

      Questionnaire_Response_Summary__c qrsUpdateResult = [
        SELECT Id, Application_Status__c
        FROM Questionnaire_Response_Summary__c
        WHERE Id = :qrsId.Id
      ];

      System.assertNotEquals(
        'Pending',
        qrsUpdateResult.Application_Status__c,
        'Data was not updated'
      );
    }
  }

  private static void createRecord(String productRequestRecordType) {
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
      Id offeringId = null;

      List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
      for(Account acc : accounts){
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
      }
      insert accounts;

      List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(
        1
      );
      for (Product_Request__c productRequest : productRequests) {
        productRequest.RecordTypeId = productRequestRecordType;
      }
      insert productRequests;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
        1,
        accounts[0].Id,
        productRequests[0].Id
      );
      insert courses;

      Product2 product = new Product2(name ='test product', course__c = courses[0].Id);
      insert product;

      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(
        1,
        accounts[0].Id
      );
      insert terms;

      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
        1,
        courses,
        terms
      );
      insert courseOfferings;

      offeringId = courseOfferings[0].Id;

      List<Contact> contacts = TestDataFactory.createTestContactRecords(
        numberOfRecords
      );
      for (Integer i = 0; i < contacts.size(); i++) {
        contacts[i].Registered_Email__c = 'testIdeaFormUser' + i + '@mailinator.com';

      }
      insert contacts;

      List<hed__Course_Enrollment__c> students = new List<hed__Course_Enrollment__c>();
      for (Contact contact : contacts) {
        hed__Course_Enrollment__c student = new hed__Course_Enrollment__c();
        student.hed__Contact__c = contact.Id;
        student.RecordTypeId = STUDENT_RECTYPEID;
        student.Paid_in_Full__c = 'Yes';
        student.hed__Course_Offering__c = offeringId;
        students.add(student);
      }
      insert students;

      List<Questionnaire__c> questionnaireList = new List<Questionnaire__c>();
      Questionnaire__c qnAppQuestions = new Questionnaire__c();
      qnAppQuestions.Questionnaire_Type__c = 'Application Questions';
      qnAppQuestions.Parent_Record_ID__c = productRequests[0].Id;
      questionnaireList.add(qnAppQuestions);

      Questionnaire__c qnRegQuestions = new Questionnaire__c();
      qnRegQuestions.Questionnaire_Type__c = 'Registration Questions';
      qnRegQuestions.Parent_Record_ID__c = productRequests[0].Id;
      questionnaireList.add(qnRegQuestions);

      Questionnaire__c qnRegCriteria = new Questionnaire__c();
      qnRegCriteria.Questionnaire_Type__c = 'Registration Criteria';
      qnRegCriteria.Parent_Record_ID__c = productRequests[0].Id;
      questionnaireList.add(qnRegCriteria);

      insert questionnaireList;

      Integer qrsCounter = 0;
      Integer qnIndex = 0;
      List<Questionnaire_Response_Summary__c> questionnaireResponseList = new List<Questionnaire_Response_Summary__c>();
      for (Integer j = 0; j < numberOfRecords; j++) {
        Questionnaire_Response_Summary__c questionResp = new Questionnaire_Response_Summary__c();
        questionResp.Contact__c = contacts[j].Id;
        questionResp.Registration_Status__c = 'Confirmed';
        questionResp.Application_Status__c = 'Pending';
        questionResp.Course_Offering__c = offeringId;
        questionResp.Questionnaire__c = questionnaireList[qnIndex].Id;
        if (qrsCounter == 10) {
          qrsCounter = 0;
          qnIndex++;
        }
        qrsCounter++;
        questionnaireResponseList.add(questionResp);
      }
      insert questionnaireResponseList;

      List<Question__c> questionList = new List<Question__c>();
      for (Integer j = 0; j < numberOfRecords; j++) {
        Question__c question = new Question__c();
        question.Type__c = 'Text';
        question.Label__c = 'Q' + j;
        questionList.add(question);
      }
      insert questionList;

      Integer qCounter = 0;
      Integer qnIndex2 = 0;
      List<Related_Answer__c> relAnsList = new List<Related_Answer__c>();
      for (Integer k = 0; k < numberOfRecords; k++) {
        Related_Answer__c relAns = new Related_Answer__c();
        relAns.Question__c = questionList[k].Id;
        relAns.Questionnaire__c = questionnaireList[qnIndex2].Id;
        relAns.Sequence__c = k;
        if (qCounter == 10) {
          qCounter = 0;
          qnIndex2++;
        }
        qCounter++;
        relAnsList.add(relAns);
      }
      insert relAnsList;

      List<Answer__c> ansList = new List<Answer__c>();
      for (Integer l = 0; l < numberOfRecords; l++) {
        Answer__c ans = new Answer__c();
        ans.Response__c = 'A' + l;
        ans.Sequence__c = l;
        ans.Questionnaire_Response_Summary__c = questionnaireResponseList[l].Id;
        ans.Related_Answer__c = relAnsList[l].Id;
        ansList.add(ans);
      }
      insert ansList;
    }
  }
}
