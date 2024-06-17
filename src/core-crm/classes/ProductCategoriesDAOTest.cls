/**
 * @description test class for productcategoriesdao
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Created file                 |
 */
@isTest
public with sharing class ProductCategoriesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getProductCategoriesByProduct2CategoryTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                ProductCategoriesDAO.newInstance()
                    .getProductCategoriesByProduct2Category(
                        new List<String>(),
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'product category retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getProductCategoriesByProduct2CategoryNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            MockIdGenerator builder = new MockIdGenerator(ProductCategory.sObjectType);
            System.assert(
                ProductCategoriesDAO.newInstance()
                    .getProductCategoriesByProduct2Category(
                        new List<String>{builder.getMockId()},
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'product category retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new ProductCategoriesDAO().getSObjectType() == ProductCategory.SObjectType,
                'SObject is not Product Categories'
            );
        }
        Test.stopTest();
    }
}
