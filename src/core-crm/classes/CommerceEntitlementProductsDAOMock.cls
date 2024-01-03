/**
 * @description Mock DAO Class for Product Category object
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
public inherited sharing class CommerceEntitlementProductsDAOMock extends DmlBaseMock implements ICommerceEntitlementProductsDAO {
    public Map<Id, CommerceEntitlementProduct> CommerceEntitlementProductsMap;

    public Schema.SObjectType getSObjectType() {
        return CommerceEntitlementProduct.SObjectType;
    }

    public CommerceEntitlementProductsDAOMock() {
        super(new Map<Id, CommerceEntitlementProduct>(), Schema.CommerceEntitlementProduct.SObjectType);
        this.CommerceEntitlementProductsMap = (Map<Id, CommerceEntitlementProduct>) super.records;
    }

    public List<CommerceEntitlementProduct> getCommerceEntitlementProductByPolicyIdAndProductId(
        List<Id> entPolicyCCEIdSet,
        Set<Id> productIdSet,
        AccessLevel accessLevel
    ){
        List<CommerceEntitlementProduct> CommerceEntitlementProductsList = new List<CommerceEntitlementProduct>();
        for (CommerceEntitlementProduct record : CommerceEntitlementProductsMap.values()) {
            if (entPolicyCCEIdSet.contains(record.PolicyId) && productIdSet.contains(record.ProductId)){
                CommerceEntitlementProductsList.add(record);
            }
        }
        return CommerceEntitlementProductsList;
    }
}
