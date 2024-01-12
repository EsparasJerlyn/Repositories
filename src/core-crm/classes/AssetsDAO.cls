/**
 * @description DAO Class for Asset Object. Contains soql and constants related to the Asset object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | rhea.b.torres                  | April 24, 2023        | DEPP-5567              | Created                      | 
 *    | alexander.cadalin              | Jan 05 ,2024          | n/a                    | Added methods
 */
public inherited sharing class AssetsDAO extends DmlBase implements IAssetsDAO {
    public Database.QueryLocator queryLocatorProductRequestsOfAssetToComplete() {
        String query =
            'SELECT Id, Product_Request__c ' +
            'FROM Asset ' +
            'WHERE (End_Date__c <= TODAY)' +
            'AND Product_Request__r.Product_Request_Status__c != \' ' +
            ProductRequestsDAO.PR_COMPLETED +
            '\' ' +
            'AND Product_Request__r.Product_Request_Status__c != \' ' +
            ProductRequestsDAO.PR_NOT_PROCEEDING +
            '\'';
        return Database.getQueryLocator(query);
    }

    public Schema.SObjectType getSObjectType() {
        return Asset.SObjectType;
    }

    public static IAssetsDAO newInstance() {
        return (IAssetsDAO) ImplementationSelector.DAO.newInstance(Asset.SObjectType);
    }

    public List<Asset> getAssetsByProductRequestIds(
        Set<Id> productRequestIds,
        AccessLevel accessLevel
    ) {
        if(!productRequestIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Total_Value__c, Remaining_Value__c, Product_Request__c ' +
                'FROM Asset ' +
                'WHERE Product_Request__c IN :productRequestIds ' +
                'AND Product_Request__c != null',
                accessLevel
            );
        } else { return new List<Asset>(); }
    }
}
