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
      | roy.nino.s.regala              | June 04, 2022         | DEPP-2876              | updated to cater update      |
      | roy.nino.s.regala              | June 05, 2022         | DEPP-2876              | updated to cater update      |
*/
@isTest

public with sharing class SendNewOfferingNotificationHelperTest {

    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
        insert customEmail;

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            EmailTemplate template = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String,String>{
                'Send Register Interest Email' => 'Test Email Subject'}).iterator().next();
            insert template;

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
    }

    @isTest
    static void sendCourseOfferingAvailabiltyNotificationTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            List<hed__Course__c> course = [SELECT Id FROM hed__Course__c LIMIT 1];
            List<hed__Term__c> term = [SELECT Id FROM hed__Term__c LIMIT 1];
            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1,course,term);
            for(hed__Course_Offering__c offering: courseOfferings){
                offering.Registration_Start_Date__c = Date.today();
                offering.IsActive__c = true;
                offering.hed__Capacity__c = 10;
            }
            insert courseOfferings;
            Test.stopTest();
        }

        system.assertEquals(1,
                            Limits.getEmailInvocations(),
                            'Number of email invocations not as expected'
                            );
    }

    @isTest
    static void sendProgramOfferingAvailabiltyNotificationTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            List<hed__Program_Plan__c> programPlan = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
            List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(1,programPlan);
            for(Program_Offering__c offering: programOfferings){
                offering.Registration_Start_Date__c = Date.today();
                offering.IsActive__c = true;
                offering.hed_Capacity__c = 10;
            }
            insert programOfferings;
            Test.stopTest();
        }
        system.assertEquals(1,
                            Limits.getEmailInvocations(),
                            'Number of email invocations not as expected'
                            );
    }
    

    @isTest
    static void updateSendCourseOfferingAvailabiltyNotificationTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            List<hed__Course__c> course = [SELECT Id FROM hed__Course__c LIMIT 1];
            List<hed__Term__c> term = [SELECT Id FROM hed__Term__c LIMIT 1];
            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1,course,term);
            for(hed__Course_Offering__c offering: courseOfferings){
                offering.Registration_Start_Date__c = Date.today();
                offering.IsActive__c = false;
                offering.hed__Capacity__c = 10;
            }
            insert courseOfferings;
            update new hed__Course_Offering__c(Id = courseOfferings[0].Id, IsActive__c = true);
            Test.stopTest();
        }

        system.assertEquals(1,
                            Limits.getEmailInvocations(),
                            'Number of email invocations not as expected'
                            );
    }

    @isTest
    static void updateSendProgramOfferingAvailabiltyNotificationTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            List<hed__Program_Plan__c> programPlan = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
            List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(1,programPlan);
            for(Program_Offering__c offering: programOfferings){
                offering.Registration_Start_Date__c = Date.today();
                offering.IsActive__c = false;
                offering.hed_Capacity__c = 10;
            }
            insert programOfferings;

            programOfferings[0].IsActive__c = true;

            update new Program_Offering__c(Id = programOfferings[0].Id, IsActive__c = true);
            Test.stopTest();
        }

        system.assertEquals(1,
                            Limits.getEmailInvocations(),
                            'Number of email invocations not as expected'
                            );
    }
}
