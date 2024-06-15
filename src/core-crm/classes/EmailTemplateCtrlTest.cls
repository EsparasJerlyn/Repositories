@isTest
public with sharing class EmailTemplateCtrlTest {
    private static final String PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static final String PR_MODULE = System.Label.RT_ProductRequest_MODULE;
    private static User currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static Id opeProgProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static Id opeModuleReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_MODULE).getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup static void setupMethod() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        List<Account> accounts;
        accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account acc : accounts){
            acc.RecordTypeId = ACCT_UNIV_DEP_ID;
            acc.Organization_Unit_Level__c = '2';
        }
        insert accounts;

        List<Product_Request__c> prodRequestOPEProgramRequest;
        prodRequestOPEProgramRequest = TestDataFactory.createTestProductRequestRecords(1);
        prodRequestOPEProgramRequest[0].Product_Request_Name__c = 'Program Request';
        prodRequestOPEProgramRequest[0].RecordTypeId = opeProgProdReqId;
        insert prodRequestOPEProgramRequest;

        List<hed__Program_Plan__c> programPlanList;
        programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
        programPlanList[0].Product_Request__c = prodRequestOPEProgramRequest[0].Id;
        insert programPlanList;

        List<Product_Request__c> prodRequest;
        prodRequest = TestDataFactory.createTestProductRequestRecords(1);
        prodRequest[0].RecordTypeId = opeModuleReqId;
        insert prodRequest;

        List<hed__Course__c> courses;
        courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequest[0].Id);
        for(hed__Course__c c : courses){
            c.Delivery_Type__c = 'Face to Face';
        }
        insert courses;

        Communication_Schedule__c communicationSchedule = new Communication_Schedule__c(Course__c = courses[0].Id);
        insert communicationSchedule;


     }

    @isTest
    static void getEmailTemplateTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            EmailTemplate e = new EmailTemplate (developerName = 'testEmail', TemplateType= 'Text', Name = 'testEmail');
            e.FolderId = UserInfo.getUserId();
            insert e;
            Test.startTest();
                List<Map<String,String>> emailTemplate = EmailTemplateCtrl.getEmailTemplate('testEmail');
                System.assertEquals('testEmail', emailTemplate[0].get('label'),'Email Name did not match as expected');
            Test.stopTest();
        }
    }

    @isTest
    static void getCommunicationDataModuleTest(){
        Id programId;
		Id moduleId;
        EmailTemplate e = new EmailTemplate (developerName = 'testEmail', TemplateType= 'Text', Name = 'testEmail');
        e.FolderId = UserInfo.getUserId();
        insert e;

        List<EmailTemplate> email = new List<EmailTemplate>();
        email = [SELECT Id, Name FROM EmailTemplate LIMIT 10];
        List<String> emailNames = new List <String>();
        for (EmailTemplate em : email){
            emailNames.add(em.Name);
        }

        List<Product_Request__c> programPR  = new List<Product_Request__c>();
        programPR =[SELECT Id FROM Product_Request__c WHERE RecordTypeId =:opeProgProdReqId];
        for(Product_Request__c pr : programPR){
            programId = pr.Id;
        }

        List<Product_Request__c> opePR  = new List<Product_Request__c>();
        opePR =[SELECT Id FROM Product_Request__c WHERE RecordTypeId =:opeModuleReqId];
        for(Product_Request__c pr : opePR){
            moduleId = pr.Id;
        }

        Test.startTest();
        System.runAs(currentUser){
            EmailTemplateCtrl.CommunicationSchedData getComSchedData = new EmailTemplateCtrl.CommunicationSchedData();
            getComSchedData = EmailTemplateCtrl.getCommunicationData(emailNames, String.valueOf(moduleId), String.valueOf(programId));
            System.Assert(!getComSchedData.defaultEmail.isEmpty(),'Error while getting default email');
            System.AssertEquals(getComSchedData.deliveryType, 'Face to Face','Error while getting delivery type');

        }
        Test.stopTest();

    }

    @isTest
    static void getCommunicationDataProgramTest(){
        Id programId;
		Id moduleId;
        EmailTemplate e = new EmailTemplate (developerName = 'testEmail', TemplateType= 'Text', Name = 'testEmail');
        e.FolderId = UserInfo.getUserId();
        insert e;

        List<EmailTemplate> email = new List<EmailTemplate>();
        email = [SELECT Id, Name FROM EmailTemplate LIMIT 10];
        List<String> emailNames = new List <String>();
        for (EmailTemplate em : email){
            emailNames.add(em.Name);
        }

        List<Product_Request__c> programPR  = new List<Product_Request__c>();
        programPR =[SELECT Id FROM Product_Request__c WHERE RecordTypeId =:opeProgProdReqId];
        for(Product_Request__c pr : programPR){
            programId = pr.Id;
        }

        List<Product_Request__c> opePR  = new List<Product_Request__c>();
        opePR =[SELECT Id FROM Product_Request__c WHERE RecordTypeId =:opeModuleReqId];
        for(Product_Request__c pr : opePR){
            moduleId = pr.Id;
        }

        Test.startTest();
        System.runAs(currentUser){
            EmailTemplateCtrl.CommunicationSchedData getComSchedData = new EmailTemplateCtrl.CommunicationSchedData();
            getComSchedData = EmailTemplateCtrl.getCommunicationData(emailNames, String.valueOf(programId), 'Program');
            System.Assert(!getComSchedData.defaultEmail.isEmpty(),'Error while getting default email');
            //System.AssertEquals(getComSchedData.deliveryType, 'Face to Face','Error while getting delivery type');

        }
        Test.stopTest();

    }
}