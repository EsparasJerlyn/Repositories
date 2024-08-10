/**
 * @description test class for productcategoryproductsdao
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
public with sharing class ProductCategoryProductsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    } 

    @isTest
    static void getProductCategoryProductByProdCatalogIdAndProdCategoryIdTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                ProductCategoryProductsDAO.newInstance()
                    .getProductCategoryProductByProdCatalogIdAndProdCategoryId(
                        new Set<Id>(),
                        new Set<Id>(),
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'product category product retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getProductCategoryProductByProdCatalogIdAndProdCategoryIdNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            MockIdGenerator builderForProductCatalog = new MockIdGenerator(ProductCatalog.sObjectType);
            MockIdGenerator builderForProductCategory = new MockIdGenerator(ProductCategory.sObjectType);
            System.assert(
                ProductCategoryProductsDAO.newInstance()
                    .getProductCategoryProductByProdCatalogIdAndProdCategoryId(
                        new Set<Id>{builderForProductCatalog.getMockId()},
                        new Set<Id>{builderForProductCategory.getMockId()},
                        AccessLevel.SYSTEM_MODE)
                    .isEmpty(),
                'product category product retrieved is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new ProductCategoryProductsDAO().getSObjectType() == ProductCategoryProduct.SObjectType,
                'SObject is not Product Category Products'
            );
        }
        Test.stopTest();
    }
}
