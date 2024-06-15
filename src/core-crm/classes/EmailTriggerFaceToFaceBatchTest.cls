/**
 * @description Test class for EmailTriggerFaceToFaceBatch
 * @EmailTriggerFaceToFaceBatch
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                 |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------------|
      | rhea.b.torres                  | June 22,2022          | DEPP-3188              | Created file                                                   |
      | rhea.b.torres                  | July 23,2022          | DEPP-3557              | Setup email template for Comms Schedule                        |
 */
@isTest
public with sharing class EmailTriggerFaceToFaceBatchTest {
    private static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Student')
    .getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @TestSetup
    static void makeData(){
      TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

	  @isTest
    public static void testEmailTriggerFaceToFaceBatch() {
        final String STR_EMAIL_TEMPLATE = 'Test Email Template';
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
              acc.RecordTypeId = ACCT_UNIV_DEP_ID;
              acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<Contact> contacts = TestDataFactory.createTestContactRecords(3);
            contacts[0].Registered_Email__c = 'studentAA@testmail.com';
            contacts[1].Registered_Email__c = 'facilitator@testmail.com';
            contacts[2].Registered_Email__c = 'studentBB@testmail.com';
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
            for(hed__Course_Offering__c offering : courseOfferings){
                offering.hed__Start_Date__c = Date.today()+5;
                offering.hed__End_Date__c = Date.today()+10;
                offering.Delivery_Type__c = 'Brisbane Classroom';
            }
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

            EmailTemplate template = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String,String>{
                STR_EMAIL_TEMPLATE => 'Test Email Subject'
            }).iterator().next();
            insert template;

            for (Communication_Schedule__c commSchedule : commSchedules) {
              commSchedule.Email_on_Registration__c = true;
              commSchedule.Email_on_final_confirmation__c = true;
              commSchedule.Days_before_Start_Date__c = 5;
              commSchedule.On_Final_Confirmation_Template__c =  String.valueOf(template.Id);
            }
            insert commSchedules;

           hed__Facility__c facility = new hed__Facility__c();
           facility.Name = 'Facility 1';
           insert facility;

               List<Session__c> session = TestDataFactory.createTestSessionRecords(2);
               session[0].Course_Offering__c = courseOfferings[0].Id;
               session[0].End_Time_v2__c = Time.newInstance(11, 0, 0, 0);
               session[0].Start_Time_v2__c = Time.newInstance(10, 0, 0, 0);
               session[0].Facilitator__c = contacts[1].Id;
               session[0].Location__c = facility.Id;
               session[0].Date__c = Date.today() + 1;
               session[1].Course_Offering__c = courseOfferings[1].Id;
               session[1].End_Time_v2__c = Time.newInstance(11, 0, 0, 0);
               session[1].Start_Time_v2__c = Time.newInstance(10, 0, 0, 0);
               session[1].Facilitator__c = contacts[1].Id;
               session[1].Location__c = facility.Id;
               session[1].Date__c = Date.today();
			   insert session;

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
              courseConnection.hed__Status__c = 'Active';
            }
            courseConnections[0].hed__Contact__c = contacts[2].Id;
            insert courseConnections;

            EmailTriggerFaceToFaceBatch emailBatch = new EmailTriggerFaceToFaceBatch ();
            Database.executebatch(emailBatch);
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'EmailTriggerFaceToFaceBatch'].isEmpty() ,
                                                                                      'EmailTriggerFaceToFaceBatch Job was not executed');
            // Assertion for checking email deliverability tracking
            System.assert(TestDataFactory.queryEmailMessageRecords()!=null, 'EmailMessage was not tracked in course connection.');
            Test.stopTest();
        }
    }
}