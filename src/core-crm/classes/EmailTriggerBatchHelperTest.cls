/**
 * @description Helper class all Email Trigger Batch classes
 *
 * @author Accenture
 *
* @history
*     | Developer                 | Date                  | JIRA                | Change Summary                                                   |
      |---------------------------|-----------------------|---------------------|------------------------------------------------------------------|
      | rhea.b.torres             | November 29, 2022     | DEPP-4199           | Created file                                                     |
      | roy.nino.s.regala         | Feb 23, 2024          | DEPP-7738           | optimized setup data                                             |
*/
@isTest
public with sharing class EmailTriggerBatchHelperTest {

    @TestSetup
    static void makeData(){

      Test.startTest();
      TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
      Test.stopTest();

      final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
          .get('Student')
          .getRecordTypeId();
      final Id STUDENT_PROGRAM_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
          .get('Student_Program')
          .getRecordTypeId();
      final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
      final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
      
      System.runAs(TestDataFactory.getprogramadminUser()){
        final String STR_EMAIL_TEMPLATE = 'Test Email Template';

        List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account acc : accounts){
          acc.RecordTypeId = ACCT_UNIV_DEP_ID;
          acc.Organization_Unit_Level__c = '2';
        }
        insert accounts;

        List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
        contacts[0].Registered_Email__c = 'testContact@testmail.com';
        insert contacts;

        List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10, accounts[0].Id);
        insert terms;

        List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
        insert prodRequest;

        List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(10, accounts[0].Id, prodRequest[0].Id);
        insert courses;

        List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(10);
        insert programPlans;

        List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(10,courses,terms);
        for(hed__Course_Offering__c offering : courseOfferings){
            offering.hed__Start_Date__c = Date.today()-10;
            offering.hed__End_Date__c = Date.today()-1;
            offering.Delivery_Type__c = 'Online Self-paced';
        }
        insert courseOfferings;

        List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(10, programPlans);
        for(Program_Offering__c offering : programOfferings){
            offering.Start_Date__c = Date.today()-10;
            offering.End_Date__c = Date.today()-1;
        }
        insert programOfferings;

        EmailTemplate template = TestDataFactory.createTestEmailTemplateRecords(1,
                                                                                new Map<String,String>{
                                                                                STR_EMAIL_TEMPLATE => 'Test Email Subject'}).iterator().next();
        template.HtmlValue = '<html>test</html>';
        template.Body = 'Email content details:';
        insert template;

        List<Communication_Schedule__c> commSchedules = TestDataFactory.createTestCommunicationScheduleRecords(10, courses, programPlans);

        for (Communication_Schedule__c commSchedule : commSchedules) {
          commSchedule.Email_on_Registration__c = true;
          commSchedule.Email_on_final_confirmation__c = true;
          commSchedule.Email_on_completion__c = true;
          commSchedule.On_Completion_Template__c = String.valueOf(template.Id);
        }
        insert commSchedules;

        List<hed__Course_Enrollment__c> ccForCourseOffering = TestDataFactory.createTestCourseConnectionRecord(5, contacts[0].Id, courseOfferings);
        for (hed__Course_Enrollment__c courseConnection : ccForCourseOffering) {
          courseConnection.RecordTypeId = STUDENT_RECTYPEID;
          courseConnection.Amount__c = 100;
          courseConnection.Paid_in_Full__c = '';
          courseConnection.hed__Status__c = 'Active';
        }
        insert ccForCourseOffering;

        List<hed__Course_Enrollment__c> ccForProgramOffering = TestDataFactory.createTestCourseConnectionRecordProgram(5, contacts[0].Id, programOfferings);
        for (hed__Course_Enrollment__c courseConnection : ccForProgramOffering) {
          courseConnection.RecordTypeId = STUDENT_PROGRAM_RECTYPEID;
          courseConnection.hed__Status__c = 'Active';
        }
        insert ccForProgramOffering;
      }
    }

    @isTest
    public static void testSendingOfEmailWithoutAttachment(){
      Test.startTest();
      System.runAs(TestDataFactory.getprogramadminUser()){
        hed__Course_Enrollment__c enrollment = [SELECT Id FROM hed__Course_Enrollment__c LIMIT 1];
        Contact con = [SELECT Id, Name, FirstName, LastName, Registered_Email__c FROM Contact LIMIT 1];
        hed__Course_Offering__c courseOffering = [SELECT Id, Name FROM hed__Course_Offering__c LIMIT 1];
        EmailTemplate template =[SELECT Id, Name, Subject FROM EmailTemplate WHERE Name Like '%Test Email Template%' LIMIT 1];
        
        EmailTriggerBatchHelper.EmailWrapper wrapper = new  EmailTriggerBatchHelper.EmailWrapper();
        wrapper.recordId = String.valueOf(enrollment.Id);
        wrapper.contactId = String.valueOf(con.Id);
        wrapper.name = con.Name;
        wrapper.courseOfferingName = courseOffering.Name;
        wrapper.productOfferingName = null;
        wrapper.firstName = con.FirstName;
        wrapper.lastName = con.LastName;
        wrapper.toAddress = con.Registered_Email__c;
        wrapper.emailTemplateIdStr = String.valueOf(template.Id);
        wrapper.startDate = System.today();
        wrapper.endDate = System.today() + 10;
        wrapper.paidInFull = 'Yes';
        wrapper.amount = '500';
        wrapper.storeLink = 'sampleLink.com';
        wrapper.userName = 'user@test.com';
        wrapper.attachmentType = null;
        List<Object> objectList = new List<EmailTriggerBatchHelper.EmailWrapper>();
        objectList.add(wrapper);
        EmailTriggerBatchHelper.sendEmailWithoutAttachment(objectList);
      }
      List<EmailMessage> emailMsg = [SELECT Id FROM EmailMessage];
      System.assert(emailMsg!=null, 'An email should be sent.');
      Test.stopTest();
    }

    @isTest
    public static void testSendingOfEmailWithAttachmentForVirtual(){
      Test.startTest();
      System.runAs(TestDataFactory.getprogramadminUser()){
        hed__Course_Enrollment__c enrollment = [SELECT Id FROM hed__Course_Enrollment__c LIMIT 1];
        Contact con = [SELECT Id, Name, FirstName, LastName, Registered_Email__c FROM Contact LIMIT 1];
        hed__Course_Offering__c courseOffering = [SELECT Id, Name FROM hed__Course_Offering__c LIMIT 1];
        courseOffering.Delivery_Type__c = 'Online Classroom';
        update courseOffering;
        EmailTemplate template =[SELECT Id, Name, Subject FROM EmailTemplate WHERE Name Like '%Test Email Template%' LIMIT 1];
        
        EmailTriggerBatchHelper.EmailWrapper wrapper = new EmailTriggerBatchHelper.EmailWrapper();
        wrapper.recordId = String.valueOf(enrollment.Id);
        wrapper.contactId = String.valueOf(con.Id);
        wrapper.name = con.Name;
        wrapper.courseOfferingName = courseOffering.Name;
        wrapper.productOfferingName = null;
        wrapper.firstName = con.FirstName;
        wrapper.lastName = con.LastName;
        wrapper.toAddress = con.Registered_Email__c;
        wrapper.emailTemplateIdStr = String.valueOf(template.Id);
        wrapper.startDate = System.today();
        wrapper.endDate = System.today() + 10;
        wrapper.paidInFull = 'Yes';
        wrapper.amount = '500';
        wrapper.storeLink = 'samplelink.com';
        wrapper.userName = 'user@test.com';
        wrapper.attachmentType = 'Virtual';
        List<Object> objectList = new List<EmailTriggerBatchHelper.EmailWrapper>();
        objectList.add(wrapper);
        EmailTriggerBatchHelper.sendEmailWithAttachment(objectList);
      }
      List<EmailMessage> emailMsg = [SELECT Id FROM EmailMessage];
      System.assert(emailMsg!=null, 'An email should be sent.');
      Test.stopTest();
    }
    
    @isTest
    public static void testSendingOfEmailWithAttachmentForPreSession(){
      Test.startTest();
      System.runAs(TestDataFactory.getprogramadminUser()){
        hed__Course_Enrollment__c enrollment = [SELECT Id FROM hed__Course_Enrollment__c LIMIT 1];
        Contact con = [SELECT Id, Name, FirstName, LastName, Registered_Email__c FROM Contact LIMIT 1];
        hed__Course_Offering__c courseOffering = [SELECT Id, Name FROM hed__Course_Offering__c LIMIT 1];
        courseOffering.Delivery_Type__c = 'Online Classroom';
        update courseOffering;
        EmailTemplate template =[SELECT Id, Name, Subject FROM EmailTemplate WHERE Name Like '%Test Email Template%' LIMIT 1];
        
        EmailTriggerBatchHelper.EmailWrapper wrapper = new EmailTriggerBatchHelper.EmailWrapper();
        wrapper.recordId = String.valueOf(enrollment.Id);
        wrapper.contactId = String.valueOf(con.Id);
        wrapper.name = con.Name;
        wrapper.courseOfferingName = courseOffering.Name;
        wrapper.productOfferingName = null;
        wrapper.firstName = con.FirstName;
        wrapper.lastName = con.LastName;
        wrapper.toAddress = con.Registered_Email__c;
        wrapper.emailTemplateIdStr = String.valueOf(template.Id);
        wrapper.startDate = System.today();
        wrapper.endDate = System.today() + 10;
        wrapper.paidInFull = 'Yes';
        wrapper.amount = '500';
        wrapper.storeLink = 'samplelink.com';
        wrapper.userName = 'user@test.com';
        wrapper.attachmentType = 'PreSession';
        List<Object> objectList = new List<EmailTriggerBatchHelper.EmailWrapper>();
        objectList.add(wrapper);
        EmailTriggerBatchHelper.sendEmailWithAttachment(objectList);
      }
      List<EmailMessage> emailMsg = [SELECT Id FROM EmailMessage];
      System.assert(emailMsg!=null, 'An email should be sent.');
      Test.stopTest();
    }
    
    @isTest
    public static void testSendingOfEmailWithAttachmentForFaceToFace(){
      Test.startTest();
      System.runAs(TestDataFactory.getprogramadminUser()){
        hed__Course_Enrollment__c enrollment = [SELECT Id FROM hed__Course_Enrollment__c LIMIT 1];
        Contact con = [SELECT Id, Name, FirstName, LastName, Registered_Email__c FROM Contact LIMIT 1];
        hed__Course_Offering__c courseOffering = [SELECT Id, Name FROM hed__Course_Offering__c LIMIT 1];
        courseOffering.Delivery_Type__c = 'Online Classroom';
        update courseOffering;
        EmailTemplate template =[SELECT Id, Name, Subject FROM EmailTemplate WHERE Name Like '%Test Email Template%' LIMIT 1];
        
        EmailTriggerBatchHelper.EmailWrapper wrapper = new EmailTriggerBatchHelper.EmailWrapper();
        wrapper.recordId = String.valueOf(enrollment.Id);
        wrapper.contactId = String.valueOf(con.Id);
        wrapper.name = con.Name;
        wrapper.courseOfferingName = courseOffering.Name;
        wrapper.productOfferingName = null;
        wrapper.firstName = con.FirstName;
        wrapper.lastName = con.LastName;
        wrapper.toAddress = con.Registered_Email__c;
        wrapper.emailTemplateIdStr = String.valueOf(template.Id);
        wrapper.startDate = System.today();
        wrapper.endDate = System.today() + 10;
        wrapper.paidInFull = 'Yes';
        wrapper.amount = '500';
        wrapper.storeLink = 'samplelink.com';
        wrapper.userName = 'user@test.com';
        wrapper.attachmentType = 'FaceToFace';
        List<Object> objectList = new List<EmailTriggerBatchHelper.EmailWrapper>();
        objectList.add(wrapper);
        EmailTriggerBatchHelper.sendEmailWithAttachment(objectList);
      }
      List<EmailMessage> emailMsg = [SELECT Id FROM EmailMessage];
      System.assert(emailMsg!=null, 'An email should be sent.');
      Test.stopTest();
    }
}