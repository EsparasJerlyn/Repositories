/**
 * @description Test class for EmailTriggerOnlineSelfPacedBatch
 * @EmailTriggerOnlineSelfPacedBatch
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                 |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------------|
      | rhea.b.torres                  | June 22,2022          | DEPP-3188              | Created file                                                   |
      | rhea.b.torres                  | July 23,2022          | DEPP-3557              | Setup email template for Comms Schedule                        |
 */
@isTest
public with sharing class EmailTriggerOnlineSelfPacedBatchTest {
    private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
        .get('Student')
        .getRecordTypeId();
    private static final Id STUDENT_PROGRAM_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
        .get('Student_Program')
        .getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @TestSetup
    static void makeData(){
      TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

	  @isTest
    public static void testEmailOnlineSeldPacedBatch() {
        final String STR_EMAIL_TEMPLATE = 'Test Email Template';
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            /** ACCOUNT CREATION */
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
              acc.RecordTypeId = ACCT_UNIV_DEP_ID;
              acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            /** CONTACT CREATION */
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            contacts[0].Registered_Email__c = 'testContact@testmail.com';
            insert contacts;

            /** TERM CREATION */
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(
              10,
              accounts[0].Id
            );
            insert terms;

            /** PRODUCT REQUEST CREATION */
            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(
              1
            );
            insert prodRequest;

            /** COURSE CREATION */
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
              10,
              accounts[0].Id,
              prodRequest[0].Id
            );
            insert courses;

            /** PROGRAM PLAN CREATION */
            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(10);
            insert programPlans;

            /** COURSE OFFERING CREATION */
            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
              10,
              courses,
              terms
            );
            for(hed__Course_Offering__c course: courseOfferings){
                course.hed__Start_Date__c = Date.today()+6;
                course.hed__End_Date__c = Date.today()+10;
                course.Delivery_Type__c = 'Online Self-paced';
            }
            insert courseOfferings;

            /** PROGRAM OFFERING CREATION */
            List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(
              10,
              programPlans
            );
            for(Program_Offering__c offering : programOfferings){
                offering.Start_Date__c = Date.today()+6;
                offering.Delivery_Type__c = 'Online Self-paced';
            }
            insert programOfferings;

            List<Communication_Schedule__c> commSchedules = TestDataFactory.createTestCommunicationScheduleRecords(
              10,
              courses,
              programPlans
            );

            EmailTemplate template = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String,String>{
              STR_EMAIL_TEMPLATE => 'Test Email Subject'
            }).iterator().next();
            insert template;

            for (Communication_Schedule__c commSchedule : commSchedules) {
              commSchedule.Email_on_Registration__c = true;
              commSchedule.Email_on_final_confirmation__c = true;
              commSchedule.Days_before_Start_Date__c = 6;
              commSchedule.On_Final_Confirmation_Template__c =  String.valueOf(template.Id);
            }
            insert commSchedules;

            List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(
              5,
              contacts[0].Id,
              courseOfferings
            );

            for (hed__Course_Enrollment__c courseConnection : courseConnections) {
              courseConnection.RecordTypeId = STUDENT_RECTYPEID;
              courseConnection.Amount__c = 100;
              courseConnection.Paid_in_Full__c = '';
              courseConnection.hed__Status__c = 'Active';
            }
            insert courseConnections;

            List<hed__Course_Enrollment__c> ccForProgramOffering = TestDataFactory.createTestCourseConnectionRecordProgram(
                5,
                contacts[0].Id,
                programOfferings
            );
            for (hed__Course_Enrollment__c courseConnection : ccForProgramOffering) {
              courseConnection.RecordTypeId = STUDENT_PROGRAM_RECTYPEID;
              courseConnection.hed__Status__c = 'Active';
            }
            insert ccForProgramOffering;

            EmailTriggerOnlineSelfPacedBatch emailBatch = new EmailTriggerOnlineSelfPacedBatch();
            Database.executebatch(emailBatch);
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'EmailTriggerOnlineSelfPacedBatch'].isEmpty() , 'EmailTriggerOnlineSelfPacedBatch Job was not executed');
            // Assertion for checking email deliverability tracking
            System.assert(TestDataFactory.queryEmailMessageRecords()!=null, 'EmailMessage was not tracked in course connection.');
            Test.stopTest();
        }
    }
}