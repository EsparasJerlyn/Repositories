/**
 * @description CartItemTriggerHandler Test Class
 * @see CartItemTriggerHandler
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
public with sharing class CartItemTriggerHandlerTest {
    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    @IsTest
    static void insertCartItemTest() {
        System.runAs(currentUser) {
            Test.startTest();

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            insert accounts;
            
            WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
            insert testWebStore;

            WebCart cart = new WebCart(Name='Cart', AccountId = accounts[0].Id , Status = 'Active', WebStoreId = testWebStore.Id);
            insert cart;

            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
            insert cartDeliveryGroup;

            CartItem cartItem = new CartItem(CartId=cart.Id, Sku='SKU_Test1', Quantity=3.0, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
            insert cartItem;

            Test.stopTest();

            System.assert(![SELECT External_Id__c FROM CartItem].IsEmpty(), 'External Id is not populated');
        }
    }
}
