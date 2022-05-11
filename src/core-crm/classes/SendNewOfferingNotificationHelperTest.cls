/**
 * @description Test Class for SendNewOfferingNotificationHelper
 * @see SendNewOfferingNotificationHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 26, 2022        | DEPP-1687              | Created file                 |
      |                                |                       |                        |                              |
 */

@isTest(SeeAllData=false)

public with sharing class SendNewOfferingNotificationHelperTest {

    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup static void setupMethod() {
        Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
        insert customEmail;
         
        List<Account> accounts;
        List<Contact> contacts;
        List<hed__Term__c> terms;
        List<Product_Request__c> prodRequest;
        List<hed__Course__c> courses;
        List<hed__Program_Plan__c> programPlans;
        List<Product2> products;
        List<Expression_of_Interest__c> interests;
        Pricebook2 priceBook;
        PricebookEntry priceBookEntry;

        accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account account : accounts){
            account.RecordTypeId = ACCT_UNIV_DEP_ID;
            account.Organization_Unit_Level__c = '2';
        }
        insert accounts;
        contacts = TestDataFactory.createTestContactRecords(1);
        contacts[0].email ='testquttestqut@email.com';
        insert Contacts;
        terms = TestDataFactory.createTestTermRecords(25,accounts[0].Id);
        insert terms;
        prodRequest = TestDataFactory.createTestProductRequestRecords(1);
        insert prodRequest;
        courses = TestDataFactory.createTestCourseRecords(25,accounts[0].Id,prodRequest[0].Id);
        insert courses;
        programPlans = TestDataFactory.createTestProgramPlanRecords(25);
        insert programPlans;
        products = TestDataFactory.createTestProductRecords(25,courses);
        for (Integer i = 0; i < products.size(); i++) {
            products[i].IsActive = true;
            products[i].Program_Plan__c = programPlans[i].Id;
        }
        insert products;
        pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
        update pricebook;
        priceBookEntry = new PricebookEntry(pricebook2id = pricebook.Id, UnitPrice = 12, product2Id = products[0].Id, isActive = true);
        insert priceBookEntry;
        interests = TestDataFactory.createExpressionOfInterest(25,contacts[0],products);
        insert interests;
    }


    @IsTest
    static void sendCourseOfferingAvailabiltyNotificationTest(){
        Test.startTest();
        List<hed__Course__c> course = [SELECT Id FROM hed__Course__c LIMIT 1];
        List<hed__Term__c> term = [SELECT Id FROM hed__Term__c LIMIT 1];
        List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1,course,term);
        insert courseOfferings;
        Test.stopTest();
        
        system.assertEquals(1,
                            Limits.getEmailInvocations(),
                            'Number of email invocations not as expected'
                            );
    }

    @IsTest
    static void sendProgramOfferingAvailabiltyNotificationTest(){
        Test.startTest();
        List<hed__Program_Plan__c> programPlan = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
        List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(1,programPlan);
        insert programOfferings;
        Test.stopTest();
        
        system.assertEquals(1,
                            Limits.getEmailInvocations(),
                            'Number of email invocations not as expected'
                            );
    }
    
}
