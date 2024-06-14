/**
 * @description Test Class for Expression of Interest Inactive
 *
 * @see ../flows/Expression_of_Interest_Inactive
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | roy.nino.s.regala         | February 04, 2022     | DEPP-213     | Created file                                |
      | justine.javier@qut.edu.au | February 25, 2022     | DEPP-1819    | Removed Program_Offering__c logic           |                                             |
      |                           |                       |              |                                             |
*/
@isTest
private class Expression_of_Interest_Inactive_FlowTest{
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup
    static void makeData(){
        TestDataFactoryUser.generateUserSystemAdministrator();
        EmailTemplate template = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String,String>{
            'Send Register Interest Email' => 'Test Email Subject'}).iterator().next();
        insert template;
    }

    @isTest
    private static void setToInactiveTest()
    {
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs ( PORTAL_SYS_ADMIN ) {

            Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
            insert customEmail;

            //Create account
            Account portalAccount1 = new Account(
            Name = 'TestAccount',
            OwnerId = PORTAL_SYS_ADMIN.Id
            );
            Database.insert(portalAccount1);

            //Create contact
            Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            AccountId = portalAccount1.Id,
            Registered_Email__c = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1);

            //Create user
            User portalUser = TestDataFactory.createPortalUserRecords(1,'Corporate Partner User',contact1.Id).iterator().next();
            Database.insert(portalUser);

            List<Account> accounts;
            List<hed__Term__c> terms;
            List<Product_Request__c> prodRequest;
            List<hed__Course_Offering__c> courseOfferings;
            List<hed__Course__c> courses;
            List<Expression_of_Interest__c> interests;
            List<hed__Course_Enrollment__c> courseConnections;


            accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;
            terms = TestDataFactory.createTestTermRecords(25,accounts[0].Id);
            insert terms;
            prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
            courses = TestDataFactory.createTestCourseRecords(25,accounts[0].Id,prodRequest[0].Id);
            insert courses;
            courseOfferings = TestDataFactory.createTestCourseOfferingRecord(25,courses,terms);
            insert courseOfferings;
            interests = TestDataFactory.createExpressionOfInterest(25,contact1,[SELECT Id FROM Product2 LIMIT 25]);
            insert interests;

            Test.startTest();
            courseConnections = TestDataFactory.createTestCourseConnectionRecord(25,portalUser.contactId,courseofferings);
            for(hed__Course_Enrollment__c cc: courseConnections){
                cc.hed__Status__c = 'Active';
            }
            insert courseConnections;
            System.assertEquals(true,![SELECT Id from Expression_of_interest__c WHERE Status__c = 'Inactive'].isEmpty(),'Expression of interest status was not set to inactive');
            Test.stopTest();
        }
    }

    @isTest
    private static void updateToInactiveTest()
    {
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs ( PORTAL_SYS_ADMIN ) {

            Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
            insert customEmail;

            //Create account
            Account portalAccount1 = new Account(
            Name = 'TestAccount',
            OwnerId = PORTAL_SYS_ADMIN.Id
            );
            Database.insert(portalAccount1);

            //Create contact
            Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            AccountId = portalAccount1.Id,
            Registered_Email__c = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1);

            //Create user
            User portalUser = TestDataFactory.createPortalUserRecords(1,'Corporate Partner User',contact1.Id).iterator().next();
            Database.insert(portalUser);

            List<Account> accounts;
            List<hed__Term__c> terms;
            List<Product_Request__c> prodRequest;
            List<hed__Program_Plan__c> programPlans;
            List<Program_Offering__c> programOfferings;
            List<Expression_of_Interest__c> interests;
            List<hed__Course_Enrollment__c> courseConnections;


            accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;
            terms = TestDataFactory.createTestTermRecords(25,accounts[0].Id);
            insert terms;
            prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
            programPlans = TestDataFactory.createTestProgramPlanRecords(25);
            insert programPlans;
            programOfferings = TestDataFactory.createTestProgramOfferingRecords(25, programPlans);
            insert programOfferings;
            interests = TestDataFactory.createExpressionOfInterest(25,contact1,[SELECT Id FROM Product2 LIMIT 25]);
            insert interests;

            Test.startTest();
            courseConnections = TestDataFactory.createTestCourseConnectionRecordProgram(25,portalUser.contactId,programOfferings);
            for(hed__Course_Enrollment__c cc: courseConnections){
                cc.hed__Status__c = 'Active';
            }
            insert courseConnections;
            System.assertEquals(true,![SELECT Id from Expression_of_interest__c WHERE Status__c = 'Inactive'].isEmpty(),'Expression of interest status was not set to inactive');
            Test.stopTest();
        }
    }
}