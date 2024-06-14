/**
 * @description Tests Batch Class for B2BRegisterInterestBatch
 * @see B2BRegisterInterestBatch
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | February 03, 2022     | DEPP-213               | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public class B2BRegisterInterestBatchTest {
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup static void setupMethod() {
        Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
        insert customEmail;

        List<Account> accounts;
        List<Contact> contacts;
        List<hed__Term__c> terms;
        List<Product_Request__c> prodRequest;
        List<hed__Course_Offering__c> courseOfferings;
        List<hed__Course__c> courses;
        List<hed__Program_Plan__c> programPlans;
        List<Program_Offering__c> programOfferings;
        List<Product2> products;
        List<Expression_of_Interest__c> interests;
        Pricebook2 priceBook;
        PricebookEntry priceBookEntry;

        accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account acc : accounts){
            acc.RecordTypeId = ACCT_UNIV_DEP_ID;
            acc.Organization_Unit_Level__c = '2';
        }
        insert accounts;
        contacts = TestDataFactory.createTestContactRecords(1);
        contacts[0].email ='testquttestqut@email.com';
        contacts[0].Registered_Email__c = 'registeredemail@email.com';
        insert Contacts;
        terms = TestDataFactory.createTestTermRecords(25,accounts[0].Id);
        insert terms;
        prodRequest = TestDataFactory.createTestProductRequestRecords(1);
        insert prodRequest;
        courses = TestDataFactory.createTestCourseRecords(25,accounts[0].Id,prodRequest[0].Id);
        insert courses;
        programPlans = TestDataFactory.createTestProgramPlanRecords(25);
        insert programPlans;
        programOfferings = TestDataFactory.createTestProgramOfferingRecords(25, programPlans);
        insert programOfferings;
        products = TestDataFactory.createTestProductRecords(25,courses);
        for (Integer i = 0; i < products.size(); i++) {
            products[i].Program_Plan__c = programPlans[i].Id;
        }
        insert products;
        pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
        update pricebook;
        priceBookEntry = new PricebookEntry(pricebook2id = pricebook.Id, UnitPrice = 12, product2Id = products[0].Id, isActive = true);
        insert priceBookEntry;
        courseOfferings = TestDataFactory.createTestCourseOfferingRecord(25,courses,terms);
        insert courseOfferings;
        interests = TestDataFactory.createExpressionOfInterest(25,contacts[0],products);
        insert interests;

        TestDataFactoryUser.generateUserSystemAdministrator();
    }


    @isTest
    public static void testRegisterInterest() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            String htmlValue = 'Contact_FirstName Contact_LastName Product_Name Product_URL';
            Id userId = UserInfo.getUserId();
            EmailTemplate e = new EmailTemplate(developerName = 'Offering_Available_Email_Notification',
                                                HtmlValue = htmlValue,
                                                TemplateType= 'Text',
                                                Name = 'Offering_Available_Email_Notification',
                                                folderId = userId
                                                );
            insert e;
            Test.startTest();
            Database.executeBatch(new B2BRegisterInterestBatch(), 200);
            system.assertEquals(0,
                                Limits.getEmailInvocations(),
                                'Number of email invocations not as expected'
                                );
            Test.stopTest();
        }
    }


}