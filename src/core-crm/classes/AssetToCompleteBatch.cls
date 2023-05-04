/**
 * @description Batch class to complete related product requests of assets
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin   	       | Aug. 11, 2022         | DEPP-3481              | Created file                 | 
      | rhea.b.torres                  | April 25, 2023        | DEPP-5567              | Applied dao framework
 */
public class AssetToCompleteBatch implements Database.Batchable<sObject> {
    /**
     * @description to complete SOA product request
     * @param bc - BatchableContext
     * @return query - filtered query of Asset records
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return AssetsDAO.newInstance()
            .queryLocatorProductRequestsOfAssetToComplete();
    }
    /**
     * @description Method to execute the batch
     * @param bc - BatchableContext
     * @param assetWithProductRequestsToComplete - List of assets with related Product Request
     */
    public void execute(
        Database.BatchableContext bc,
        List<Asset> assetWithProductRequestsToComplete
    ) {
        try {
            Set<Id> productRequestSetIds = AssetService.extractProductRequestIds(
                assetWithProductRequestsToComplete
            );

            List<Database.SaveResult> productRequestSaveResults = ProductRequestService.completeProductRequests(
                productRequestSetIds
            );

            Set<Id> completedProductRequestIds = new Set<Id>();
            for (Database.SaveResult saveResult : productRequestSaveResults) {
                if (saveResult.isSuccess()) {
                    completedProductRequestIds.add(saveResult.getId());
                }
            }

            AssociatedProductsService.deactivateByProductRequest(
                completedProductRequestIds
            );
        } catch (Exception e) {
            // prettier-ignore
            NebulaLoggerService.logExceptionDetails('Exception caught in AssetToCompleteBatch.cls',e);
            throw e;
        }
    }

    // prettier-ignore
    public void finish(Database.BatchableContext bc) {} //NOPMD
}
