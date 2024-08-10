/**
 * @description DAO Class for Buyer Group object. Contains soql and constants related to the Buyer Group object.
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Created file                 |
 */
public inherited sharing class BuyerGroupsDAO extends DmlBase implements IBuyerGroupsDAO {

    public Schema.SObjectType getSObjectType() {
        return BuyerGroup.SObjectType;
    }

    public static IBuyerGroupsDAO newInstance() {
        return (IBuyerGroupsDAO) ImplementationSelector.DAO.newInstance(
            BuyerGroup.SObjectType 
        );
    }

    public List<BuyerGroup> getBuyerGroupsByProductRequestId(
        Set<Id> productRequestIds,
        AccessLevel accessLevel
    ){

        if(productRequestIds.isEmpty()){
            return new List<BuyerGroup>();
        }
        return Database.query(
            'SELECT Id, Name, BuyerGroup.Product_Request__c ' +
            'FROM BuyerGroup ' +
            'WHERE BuyerGroup.Product_Request__c IN :productRequestIds ',
            accessLevel
        );
    }

}
