/**
 * @description test class for AssociatedProductsService
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
private class AssociatedProductsServiceTest {
    @isTest
    // prettier-ignore
    static void testDeactivateByProductRequest() {// NOPMD test class is mocked

        ImplementationSelector.DAO.setMock(new ProductsDAOMock());
        ImplementationSelector.DAO.setMock(new ProductRequestsDAOMock());
        ImplementationSelector.DAO.setMock(new AssociatedProductsDAOMock());

        List<Product_Request__c> productRequestsList = TestDataFactory.createTestProductRequestRecordsByRecordType(
            1,
            ProductRequestsDAO.PR_CORP_BUNDLE_ID
        );
        ProductRequestsDAO.newInstance()
            .insertRecords(productRequestsList, false, AccessLevel.USER_MODE);

        List<Product2> productList = TestDataFactory.createTestProductRecords(1);
        ProductsDAO.newInstance().insertRecords(productList, false, AccessLevel.USER_MODE);

        Associated_Products__c assocProd = new Associated_Products__c(
            Product__c = productList.iterator().next().Id,
            Product_Request__c = productRequestsList.iterator().next().Id,
            IsActive__c = true
        );
        AssociatedProductsDAO.newInstance()
            .insertRecords(
                new List<Associated_Products__c>{ assocProd },
                false,
                AccessLevel.USER_MODE
            );

        Test.startTest();
        System.assert(
            AssociatedProductsService.deactivateByProductRequest(
                    new Set<Id>{ productRequestsList.iterator().next()?.Id }
                )
                .iterator()
                .next()
                .isSuccess() == true,
            'Associated Products is not updated'
        );
        Test.stopTest();
    }
}
