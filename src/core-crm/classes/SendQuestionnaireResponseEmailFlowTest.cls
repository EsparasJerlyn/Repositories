/**
 * @description Test Class for SenQuestionnaireResponseEmailFlow
 *
 * @see ../flows/SenQuestionnaireResponseEmailFlowTest
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | roy.nino.s.regala         | June 4, 2022          | DEPP-2753    | Created file                                |
      |                           | June 10, 2022         | DEPP-3003    | Added StoreLink                             |
*/
@isTest
private class SendQuestionnaireResponseEmailFlowTest{

    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup
    static void makeData(){
        TestDataFactoryUser.generateUserSystemAdministrator();
        EmailTemplate template = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String,String>{
            'Send Application Response Email' => 'Test Email Subject'}).iterator().next();
        insert template;
    }

    @isTest
    private static void sendApprovedApplicationStatusEmailTest(){
        Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
        
        insert customEmail;

        Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Name='QUTeX', Study_Store_Link__c = 'https://studystorelinktest.com/');
        insert studyStore;

        System.runAs(currentUser){
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

            Test.startTest();
            List<Questionnaire_Response_Summary__c> qRs = TestDataFactory.createTestQuestionnaireResponseSummaryRecords(10,courseOff,conList[0]);
            for(Integer i = 0 ; i < qRs.size() ; i++){
                qRs[i].Application_Status__c = 'Pending';
                qRs[i].Course_Offering__c = courseOff[0].Id;
            }
            insert qRs;
            System.assertEquals(1, Limits.getEmailInvocations(),'Number of email invocations not as expected');

            Test.stopTest();


        }
    }


    @isTest
    private static void applyOnProgramTest(){
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        Test.startTest();
        System.runAs(PORTAL_SYS_ADMIN) {
            Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
            insert customEmail;

            Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Name='QUTeX', Study_Store_Link__c = 'https://studystorelinktest.com/');
            insert studyStore;
            
            List<Account> accounts;
            List<Contact> contacts;
            List<hed__Term__c> terms;
            List<Product_Request__c> prodRequest;
            List<hed__Course__c> courses;
            List<hed__Program_Plan__c> programPlans;

            accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account account : accounts){
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '2';
            }
            insert accounts;
            contacts = TestDataFactory.createTestContactRecords(1);
            contacts[0].Registered_Email__c ='testquttestqut@email.com';
            insert Contacts;
            terms = TestDataFactory.createTestTermRecords(25,accounts[0].Id);
            insert terms;
            prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
            courses = TestDataFactory.createTestCourseRecords(25,accounts[0].Id,prodRequest[0].Id);
            insert courses;
            programPlans = TestDataFactory.createTestProgramPlanRecords(25);
            insert programPlans;

            List<Program_Offering__c> programOffering = TestDataFactory.createTestProgramOfferingRecords(25,programPlans);
            insert programOffering;

            Questionnaire_Response_Summary__c qrs = new Questionnaire_Response_Summary__c(Application_Status__c ='Pending', Program_Offering__c =  programOffering[0].Id, Contact__c = contacts[0].Id);
            insert qRs;

            System.assertEquals(1, Limits.getEmailInvocations(),'Number of email invocations not as expected');
        Test.stopTest();
        }

    }



}
