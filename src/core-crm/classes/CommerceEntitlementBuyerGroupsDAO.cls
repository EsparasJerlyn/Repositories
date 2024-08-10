/**
 * @description DAO Class for Commerce Entitlement Buyer Group object. Contains soql and constants related to the Commerce Entitlement Buyer Group object.
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Created file                 |
 */
public inherited sharing class CommerceEntitlementBuyerGroupsDAO extends DmlBase implements ICommerceEntitlementBuyerGroupsDAO {

    public Schema.SObjectType getSObjectType() {
        return CommerceEntitlementBuyerGroup.SObjectType;
    }

    public static ICommerceEntitlementBuyerGroupsDAO newInstance() {
        return (ICommerceEntitlementBuyerGroupsDAO) ImplementationSelector.DAO.newInstance(
            CommerceEntitlementBuyerGroup.SObjectType
        ); 
    }

    public List<CommerceEntitlementBuyerGroup> getCommerceEntitlementBuyerGroupsByBuyerGroupId(
        Set<Id> buyerGroupIdSet,
        AccessLevel accessLevel
    ){

        if(buyerGroupIdSet.isEmpty()){
            return new List<CommerceEntitlementBuyerGroup>();
        }
        return Database.query(
            'SELECT Id, BuyerGroupId, PolicyId ' +
            'FROM CommerceEntitlementBuyerGroup ' +
            'WHERE BuyerGroupId IN :buyerGroupIdSet ' +
            'AND PolicyId != null ',
            accessLevel
        );
    }

}
