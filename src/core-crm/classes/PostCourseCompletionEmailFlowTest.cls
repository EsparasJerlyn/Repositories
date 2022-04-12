/**
 * @description Test Class for  Post Course Completion Email flow
 *
 * @see ../flows/ Post Course Completion Email
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | marlon.vasquez            | April 8, 2022         | DEPP-1543    | Created file                                |
      |                           |                       |              |                                             |
*/
@IsTest(SeeAllData=false)
private class PostCourseCompletionEmailFlowTest {
  private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Student')
    .getRecordTypeId();

  private static User currentUser = TestDataFactory.createUserRecords(
      1,
      'QUTeX'
    )
    .iterator()
    .next();

  @IsTest
  private static void PostCompletionEmailTest() {
    System.runAs(currentUser) {
      List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
      insert accounts;

      List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
      contacts[0].email = 'testContact@testmail.com';
      insert contacts;

      List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(
        10,
        accounts[0].Id
      );
      insert terms;

      List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(
        1
      );
      insert prodRequest;

      List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
        10,
        accounts[0].Id,
        prodRequest[0].Id
      );
      insert courses;

      List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
        10,
        courses,
        terms
      );
      insert courseOfferings;

      List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
        10
      );
      insert programPlans;

      List<Communication_Schedule__c> commSchedules = TestDataFactory.createTestCommunicationScheduleRecords(
        10,
        courses,
        programPlans
      );

      for (Communication_Schedule__c commSchedule : commSchedules) {
        commSchedule.Email_on_Registration__c = true;
      }
      insert commSchedules;

      Test.startTest();
      List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(
        10,
        contacts[0].Id,
        courseOfferings
      );

      for (hed__Course_Enrollment__c courseConnection : courseConnections) {
        courseConnection.RecordTypeId = STUDENT_RECTYPEID;
        courseConnection.Amount__c = 100;
        courseConnection.Paid_in_Full__c = '';
      }
      insert courseConnections;

        
        
      System.assertEquals(
        1,
        Limits.getEmailInvocations(),
        'Emails should be sent'
      );
      Test.stopTest();
    }
  }
}