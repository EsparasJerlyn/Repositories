/**
 * @description test class for CartItemsDAO.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                     |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                       |
 */
@isTest
private class CartItemsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new CartItemsDAO().getSObjectType() == CartItem.SObjectType,
                'SObject is not CartItem'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getCartItemsWithPricebookEntryByRecordIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<CartItem> cartItemList = CartItemsDAO.newInstance()
                .getCartItemsWithPricebookEntryByRecordIds(
                    new Set<String>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(cartItemList.isEmpty(), 'cartItemList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getCartItemsByCartItemNameTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<CartItem> cartItemList = CartItemsDAO.newInstance()
                .getCartItemsByCartItemName(
                    new Set<String>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(cartItemList.isEmpty(), 'cartItemList is not empty');
        }
        Test.stopTest();
    }
}
