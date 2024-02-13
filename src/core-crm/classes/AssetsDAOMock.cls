/**
 * @description Mock DAO Class for Asset Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2023        | DEPP-5567              | Created                      | 
 *    | alexander.cadalin              | Jan 05 ,2024          | n/a                    | Added methods
 */
@isTest
public inherited sharing class AssetsDAOMock extends DmlBaseMock implements IAssetsDAO {
    public Map<Id, Asset> assetsMap;

    public AssetsDAOMock() {
        super(new Map<Id, Asset>(), Schema.Asset.SObjectType);
        this.assetsMap = (Map<Id, Asset>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return Asset.SObjectType;
    }

    public Database.QueryLocator queryLocatorProductRequestsOfAssetToComplete() {
        return null;
    }

    public List<Asset> getAssetsByProductRequestIds(
        Set<Id> productRequestIds,
        AccessLevel accessLevel
    ) {
        List<Asset> assets = new List<Asset>();
        for(Asset asset : assetsMap.values()) {
            if(productRequestIds.contains(asset.Product_Request__c)) {
                assets.add(asset);
            }
        }
        return assets;
    }
}
