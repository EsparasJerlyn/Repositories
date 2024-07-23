/**
 * @description Mock DAO Class for Buyer Group object
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
public inherited sharing class BuyerGroupsDAOMock extends DmlBaseMock implements IBuyerGroupsDAO {
    public Map<Id, BuyerGroup> buyerGroupsMap;

    public Schema.SObjectType getSObjectType() {
        return BuyerGroup.SObjectType;
    } 

    public BuyerGroupsDAOMock() {
        super(new Map<Id, BuyerGroup>(), Schema.BuyerGroup.SObjectType);
        this.buyerGroupsMap = (Map<Id, BuyerGroup>) super.records;
    }

    public List<BuyerGroup> getBuyerGroupsByProductRequestId(
        Set<Id> productRequestIds,
        AccessLevel accessLevel
    ){
        List<BuyerGroup> buyerGroupsList = new List<BuyerGroup>();
        for (BuyerGroup record : buyerGroupsMap.values()) {
            if (productRequestIds.contains(record.Id)){
                buyerGroupsList.add(record);
            }
        }
        return buyerGroupsList;
    }
}
