/**
 * @description Test Class for Send Application Status Email flow
 *
 * @see ../flows/Send_Application_Status_Email
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | arsenio.jr.dayrit         | February 14, 2022     | DEPP-1538    | Created file                                |
      |                           |                       |              |                                             |
*/
@isTest
private class Send_Application_Status_EmailTest {

    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static final String EMAIL_TEMPLATE_RESPONSE = 'Send Application Response Email';
    private static final String EMAIL_TEMPLATE_REJECTED = 'Application Email Rejected';
    private static final String EMAIL_TEMPLATE_APPROVED = 'Application Email Approved';

    @testSetup
    static void makeData(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<EmailTemplate> templateList = TestDataFactory.createTestEmailTemplateRecords(3,new Map<String,String>{
                EMAIL_TEMPLATE_RESPONSE => 'Test Email Subject1',
                EMAIL_TEMPLATE_REJECTED => 'Test Email Subject2',
                EMAIL_TEMPLATE_APPROVED => 'Test Email Subject3'});
            insert templateList;
        }
    }

    @isTest
    private static void sendApprovedApplicationStatusEmailTest(){
        Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
        insert customEmail;

        Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Name='QUTeX', Study_Store_Link__c = 'https://studystorelinktest.com/');
        insert studyStore;

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            for(Integer i =0;i<conList.size();i++){
                conList[i].Registered_Email__c = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert conList;
            List<Account> acc = TestDataFactory.createTestAccountRecords(1);
            for(Account account : acc){
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '2';
            }
            insert acc;
            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
            List<hed__Course__c> course = TestDataFactory.createTestCourseRecords(10,acc[0].Id,prodRequest[0].Id);
            insert course;
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10, acc[0].Id);
            insert terms;
            List<hed__Course_Offering__c> courseOff = TestDataFactory.createTestCourseOfferingRecord(10, course, terms);
            insert courseOff;


            List<Questionnaire_Response_Summary__c> qRs = TestDataFactory.createTestQuestionnaireResponseSummaryRecords(10,courseOff,conList[0]);
            for(Integer i = 0 ; i < qRs.size() ; i++){
                qRs[i].Application_Status__c = 'Pending';
                qRs[i].Course_Offering__c = courseOff[0].Id;
                qRs[i].Payment_URL__c = 'payment.test';
                qRs[i].Reason_for_Rejection__c = 'whatever reason';
            }
            insert qRs;

            Test.startTest();
            List<Questionnaire_Response_Summary__c> qRsUpdateRec = new List<Questionnaire_Response_Summary__c>();
            List<Questionnaire_Response_Summary__c> getQrS = [SELECT Id, Name, Application_Status__c FROM Questionnaire_Response_Summary__c LIMIT 100];
            for(Questionnaire_Response_Summary__c updateQrs : getQrS){
                updateQrs.Application_Status__c = 'Approved';
                qRsUpdateRec.add(updateQrs);
            }

            update qRsUpdateRec;
            Test.stopTest();

            System.assertEquals(1, Limits.getEmailInvocations(),'Number of email invocations not as expected');
        }
    }

    @isTest
    private static void sendRejectedApplicationStatusEmailTest(){

        Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
        insert customEmail;

        Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Name='QUTeX', Study_Store_Link__c = 'https://studystorelinktest.com/');
        insert studyStore;
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            for(Integer i =0;i<conList.size();i++){
                conList[i].Registered_Email__c = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert conList;
            List<Account> acc = TestDataFactory.createTestAccountRecords(1);
            for(Account account : acc){
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '2';
            }
            insert acc;
            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
            List<hed__Course__c> course = TestDataFactory.createTestCourseRecords(10,acc[0].Id,prodRequest[0].Id);
            insert course;
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10, acc[0].Id);
            insert terms;
            List<hed__Course_Offering__c> courseOff = TestDataFactory.createTestCourseOfferingRecord(10, course, terms);
            insert courseOff;


            List<Questionnaire_Response_Summary__c> qRs = TestDataFactory.createTestQuestionnaireResponseSummaryRecords(10,courseOff,conList[0]);
            for(Integer i = 0 ; i < qRs.size() ; i++){
                qRs[i].Application_Status__c = 'Pending';
                qRs[i].Course_Offering__c = courseOff[0].Id;
            }
            insert qRs;

            Test.startTest();
            List<Questionnaire_Response_Summary__c> qRsUpdateRec = new List<Questionnaire_Response_Summary__c>();
            List<Questionnaire_Response_Summary__c> getQrS = [SELECT Id, Name, Application_Status__c FROM Questionnaire_Response_Summary__c LIMIT 100];
            for(Questionnaire_Response_Summary__c updateQrs : getQrS){
                updateQrs.Application_Status__c = 'Rejected';
                updateQrs.Reason_for_Rejection__c = 'test';
                qRsUpdateRec.add(updateQrs);
            }

            update qRsUpdateRec;
            Test.stopTest();

            System.assertEquals(1, Limits.getEmailInvocations(),'Number of email invocations not as expected');
        }
    }
}
