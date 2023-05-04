/**
 * @description test class for assetservice
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2023        | DEPP-5567              | Created                      | 
 */
@isTest
private class AssetServiceTest {
    @isTest
    //prettier-ignore
    static void testExtractProductRequestIds() {//NOPMD - test class is mock

        ImplementationSelector.DAO.setMock(new ProductRequestsDAOMock());
        ImplementationSelector.DAO.setMock(new AssetsDAOMock());

        List<Product_Request__c> productRequestsList = TestDataFactory.createTestProductRequestRecordsByRecordType(
            1,
            ProductRequestsDAO.PR_CORP_BUNDLE_ID
        );
        ProductRequestsDAO.newInstance()
            .insertRecords(productRequestsList, false, AccessLevel.USER_MODE);

        List<Asset> assetsList = TestDataFactory.createTestAssetRecords(
            1,
            null,
            productRequestsList.iterator().next().Id
        );
        AssetsDAO.newInstance().insertRecords(assetsList, false, AccessLevel.USER_MODE);

        Test.startTest();
        System.assert(
            !AssetService.extractProductRequestIds(assetsList).isEmpty(),
            'productrequestids must not be empty'
        );
        Test.stopTest();
    }
}
