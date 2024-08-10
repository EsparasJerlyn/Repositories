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
    public Map<Id, CommerceEntitlementProduct> commerceEntitlementProductsMap;

    public Schema.SObjectType getSObjectType() {
        return CommerceEntitlementProduct.SObjectType;
    } 

    public CommerceEntitlementProductsDAOMock() {
        super(new Map<Id, CommerceEntitlementProduct>(), Schema.CommerceEntitlementProduct.SObjectType);
        this.commerceEntitlementProductsMap = (Map<Id, CommerceEntitlementProduct>) super.records;
    }

    public List<CommerceEntitlementProduct> getCommerceEntitlementProductByPolicyIdAndProductId(
        List<Id> entPolicyCCEIdSet,
        Set<Id> productIdSet,
        AccessLevel accessLevel
    ){
        List<CommerceEntitlementProduct> commerceEntitlementProductsList = new List<CommerceEntitlementProduct>();
        for (CommerceEntitlementProduct record : commerceEntitlementProductsMap.values()) {
            if (entPolicyCCEIdSet.contains(record.PolicyId) && productIdSet.contains(record.ProductId)){
                commerceEntitlementProductsList.add(record);
            }
        }
        return commerceEntitlementProductsList;
    }
}
