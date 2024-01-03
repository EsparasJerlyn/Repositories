/**
 * @description test class for cartitemsdao.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------------|
 *    | roy.nino.s.regala              | Sept 19, 2023         | DEPP-6714              | Created file                                 |
 *    | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCartItemsByWebCartIdTest |
 *    |                                |                       |                        | getCartItemsByWebCartIdNotEmptyTest          |
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

    @isTest
    static void getCartItemsByWebCartIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<CartItem> cartItemList = CartItemsDAO.newInstance()
                .getCartItemsByWebCartId(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(cartItemList.isEmpty(), 'cartItemList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getCartItemsByWebCartIdNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            MockIdGenerator builderForWebCart = new MockIdGenerator(WebCart.sObjectType);
            List<CartItem> cartItemList = CartItemsDAO.newInstance()
                .getCartItemsByWebCartId(
                    new Set<Id>{builderForWebCart.getMockId()},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(cartItemList.isEmpty(), 'cartItemList is not empty');
        }
        Test.stopTest();
    }
}
