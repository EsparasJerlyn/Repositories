/**
 * @description Interface for Commerce Entitlement Buyer Group DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Created file                 |
 */
public interface ICommerceEntitlementBuyerGroupsDAO extends DmlInterface {

    List<CommerceEntitlementBuyerGroup> getCommerceEntitlementBuyerGroupsByBuyerGroupId(
        Set<Id> buyerGroupIdSet,
        AccessLevel accessLevel
    );  
}
