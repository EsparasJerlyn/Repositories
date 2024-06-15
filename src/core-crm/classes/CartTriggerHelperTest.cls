/**
 * @description CartTriggerHelper Test Class
 * @see CartTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | July 15, 2022         | DEPP-3485              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class CartTriggerHelperTest {

    @testSetup
    static void setupMethod() {

        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
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