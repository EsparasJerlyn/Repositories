/**
 * @description Tests the SetupRegistrationCtrl Class
 *
 * @see SetupRegistrationCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | angelika.j.s.galang       | Januar 25, 2022       | DEPP-1396 | Created file                    |
      | john.bo.a.pineda          | February 03, 2022     | DEPP-1532 | Update Answer to Related Answer |
      |                           |                       |           |                                 |
*/
@isTest
private class SetupRegistrationCtrlTest {
  private static final String PRODUCT_API_NAME = Product2.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
  private static final String QUESTION_API_NAME = Question__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();

  @testSetup
  static void setupMethod() {
    TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    Product_Request__c prodReq = TestDataFactory.createTestProductRequestRecords(
        1
      )
      .iterator()
      .next();
    insert prodReq;
    Questionnaire__c questionnaire = TestDataFactory.createTestQuestionnaireRecords(
        1,
        prodReq?.Id,
        PRODUCT_API_NAME
      )
      .iterator()
      .next();
    insert questionnaire;

    List<Question__c> questions = TestDataFactory.createTestQuestionRecords(
      100
    );
    insert questions;
    List<Related_Answer__c> answers = TestDataFactory.createTestRelatedAnswerRecords(
      100,
      questionnaire?.Id,
      questions
    );
    insert answers;
  }

  @isTest
  private static void getRegistrationDataTest() {
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
      Product_Request__c prodReq = [SELECT Id FROM Product_Request__c LIMIT 1];
      Test.startTest();
      SetupRegistrationCtrl.RegistrationData regData = SetupRegistrationCtrl.getRegistrationData(
        prodReq?.Id
      );
      Test.stopTest();
      System.assertEquals(
        1,
        regData.questionnaireList.size(),
        'Number of expected questionnaires did not match'
      );
      System.assertEquals(
        100,
        regData.questionList.size(),
        'Number of expected questions did not match'
      );
    }
  }

  @isTest
  private static void getQuestionLayoutTest() {
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
      Test.startTest();
      List<Field_Layout_Setting__mdt> fls = SetupRegistrationCtrl.getQuestionLayout(
        QUESTION_API_NAME,
        true
      );
      Test.stopTest();
      System.assertEquals(
        1,
        fls.size(),
        'Number of expected layout setting did not match'
      );
    }
  }

  @isTest
  private static void updateAnswerSequencesTest() {
    System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
      List<Related_Answer__c> answers = [
        SELECT Sequence__c
        FROM Related_Answer__c
        LIMIT 100
      ];
      for (Integer i = 0; i < answers.size(); i++) {
        answers[i].Sequence__c = i;
      }
      Test.startTest();
      SetupRegistrationCtrl.updateAnswerSequences(answers);
      Test.stopTest();
      List<Related_Answer__c> updatedAnswers = [
        SELECT Sequence__c
        FROM Related_Answer__c
        LIMIT 100
      ];
      for (Integer i = 0; i < 100; i++) {
        System.assertEquals(
          i,
          updatedAnswers[i].Sequence__c,
          'Expected sequence did not match'
        );
      }
    }
  }
}
