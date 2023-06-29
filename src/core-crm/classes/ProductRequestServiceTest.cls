/**
 * @description testclass for ProductRequestService
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
private class ProductRequestServiceTest {
    @isTest
    // prettier-ignore
    static void completeProductRequestsTest() {//NOPMD test class is mocked
        Test.startTest();
        ImplementationSelector.DAO.setMock(new ProductRequestsDAOMock());
        List<Product_Request__c> productRequestList = TestDataFactory.createTestProductRequestRecordsByRecordType(
            1,
            ProductRequestsDAO.PR_EDUC_CONS_ID
        );
        ProductRequestsDAO.newInstance()
            .insertRecords(productRequestList, false, AccessLevel.USER_MODE);
        System.assert(
            ProductRequestService.completeProductRequests(
                    new Set<Id>{ productRequestList.iterator().next()?.Id }
                )
                .iterator()
                .next()
                .isSuccess() == true,
            'Product Request Not Updated'
        );
        Test.stopTest();
    }
}
