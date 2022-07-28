/**
 * @description CartTriggerHandler Test Class
 * @see CartTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 22, 2022        | DEPP-1991              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest(SeeAllData=false)
public with sharing class CartTriggerHandlerTest {


    @TestSetup
    static void setupMethod() {

        TestDataFactory.generateTestUsers();
    }

    @IsTest
    static void insertCartTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            insert accounts;

            WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
            insert testWebStore;

            WebCart cart = new WebCart(Name='Cart', AccountId = accounts[0].Id , Status = 'Active', WebStoreId = testWebStore.Id);
            insert cart;

            Test.stopTest();

            System.assert(![SELECT External_Id__c FROM WebCart].IsEmpty(), 'External Id is not populated');
        }

    }

    @IsTest
    static void insertCartWithCartPaymentTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            insert accounts;

            WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
            insert testWebStore;

            WebCart cart = new WebCart(Name='Cart', AccountId = accounts[0].Id , Status = 'Active', WebStoreId = testWebStore.Id);
            insert cart;

            Test.stopTest();

            System.assert(![SELECT External_Id__c FROM WebCart WHERE Cart_Payment__c != null].IsEmpty(), 'No CartPayment Created');
        }

    }
}