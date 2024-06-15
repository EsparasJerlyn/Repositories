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
@isTest
public with sharing class CartTriggerHandlerTest {


    @testSetup
    static void setupMethod() {

        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void insertCartTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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

    @isTest
    static void insertCartWithCartPaymentTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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