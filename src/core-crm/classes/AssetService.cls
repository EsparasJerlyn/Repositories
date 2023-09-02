/**
 * @description Service class for asset object. contains all reusable methods related to the asset object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | rhea.b.torres                  | April 24, 2023        | DEPP-5567              | Created                      | 
 */
public with sharing class AssetService {
    public static Set<Id> extractProductRequestIds(List<Asset> assetsWithRelatedProductRequests) {
        Set<Id> parentProductRequestIds = new Set<Id>();
        for (Asset record : assetsWithRelatedProductRequests) {
            parentProductRequestIds.add(record.Product_Request__c);
        }
        return parentProductRequestIds;
    }
}
