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
}
