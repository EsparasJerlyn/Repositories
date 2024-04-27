/**
 * @description test class for WebCartsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file
 *    | alexander.cadalin              | Jan 05 ,2024          | n/a                    | Added methods
 */
@isTest
public with sharing class WebCartsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(WebCartsDAO.newInstance() != null, 'WebCartsdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new WebCartsDAO().getSObjectType() == WebCart.SObjectType,
                'SObject is not WebCart'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getWebCartByUserIdTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<WebCart> webCartList = WebCartsDAO.newInstance()
                .getWebCartByUserId(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(webCartList.isEmpty(), 'webCartList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getWebCartByUserIdNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            MockIdGenerator builderForWebCart = new MockIdGenerator(WebCart.sObjectType);
            List<WebCart> webCartList = WebCartsDAO.newInstance()
                .getWebCartByUserId(
                    new Set<Id>{builderForWebCart.getMockId()},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(webCartList.isEmpty(), 'webCartList is not empty');
        }
        Test.stopTest();
    }
}
