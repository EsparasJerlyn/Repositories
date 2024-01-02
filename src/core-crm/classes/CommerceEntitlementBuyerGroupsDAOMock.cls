/**
 * @description Mock DAO Class for Commerce Entitlement Buyer Group object
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Created file                 |
 */
@isTest
public inherited sharing class CommerceEntitlementBuyerGroupsDAOMock extends DmlBaseMock implements ICommerceEntitlementBuyerGroupsDAO {
    public Map<Id, CommerceEntitlementBuyerGroup> CommerceEntitlementBuyerGroupsMap;

    public Schema.SObjectType getSObjectType() {
        return CommerceEntitlementBuyerGroup.SObjectType;
    }

    public CommerceEntitlementBuyerGroupsDAOMock() {
        super(new Map<Id, CommerceEntitlementBuyerGroup>(), Schema.CommerceEntitlementBuyerGroup.SObjectType);
        this.CommerceEntitlementBuyerGroupsMap = (Map<Id, CommerceEntitlementBuyerGroup>) super.records;
    }

    public List<CommerceEntitlementBuyerGroup> getCommerceEntitlementBuyerGroupsByBuyerGroupId(
        Set<Id> buyerGroupIdSet,
        AccessLevel accessLevel
    ){
        List<CommerceEntitlementBuyerGroup> CommerceEntitlementBuyerGroupsList = new List<CommerceEntitlementBuyerGroup>();
        for (CommerceEntitlementBuyerGroup record : CommerceEntitlementBuyerGroupsMap.values()) {
            if (buyerGroupIdSet.contains(record.BuyerGroupId)){
                CommerceEntitlementBuyerGroupsList.add(record);
            }
        }
        return CommerceEntitlementBuyerGroupsList;
    }
}
