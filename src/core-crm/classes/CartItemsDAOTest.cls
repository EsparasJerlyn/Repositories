/**
 * @description test class for CartItemsDAO.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                                 |
 *    | julie.jane.alegre              | January 03, 2024      | ApexCRUDViolationFix   | Add countCartItemsGroupByCourseOffering      |
 *    |                                |                       |                        | Add countCartItemsGroupByProgramOffering     |
 *    | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCartItemsByWebCartIdTest |
 *    |                                |                       |                        | getCartItemsByWebCartIdNotEmptyTest          |
 */
@isTest
private class CartItemsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
    static void countCartItemsGroupByCourseOfferingEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<AggregateResult> aggrCourseOfferList = CartItemsDAO.newInstance()
                .countCartItemsGroupByCourseOffering(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(aggrCourseOfferList.isEmpty(), 'aggrCourseOfferList is not empty');
        }
        Test.stopTest();
    }
    
    @isTest
    static void countCartItemsGroupByCourseOfferingNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            MockIdGenerator builderForCourseOffering = new MockIdGenerator(hed__Course_Offering__c.sObjectType);
            List<AggregateResult> aggrCourseOfferList = CartItemsDAO.newInstance()
                .countCartItemsGroupByCourseOffering(
                    new Set<Id>{builderForCourseOffering.getMockId()},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(aggrCourseOfferList.isEmpty(), 'aggrCourseOfferList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getCartItemsByWebCartIdNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
	
    @isTest
    static void countCartItemsGroupByProgramOfferingEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<AggregateResult> aggrProgramOfferList = CartItemsDAO.newInstance()
                .countCartItemsGroupByProgramOffering(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(aggrProgramOfferList.isEmpty(), 'aggrProgramOfferList is not empty');
        }
        Test.stopTest();
    }
    
    @isTest
    static void countCartItemsGroupByProgramOfferingNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            MockIdGenerator builderForProgramOffering = new MockIdGenerator(Program_Offering__c.sObjectType);
            List<AggregateResult> aggrProgramOfferList = CartItemsDAO.newInstance()
                .countCartItemsGroupByProgramOffering(
                    new Set<Id>{builderForProgramOffering.getMockId()},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(aggrProgramOfferList.isEmpty(), 'aggrProgramOfferList is not empty');
        }
        Test.stopTest();
    }

}