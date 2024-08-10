/**
 * @description DAO Class for Commerce Entitlement Product object. Contains soql and constants related to the Commerce Entitlement Product object.
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Created file                 |
 */
public inherited sharing class CommerceEntitlementProductsDAO extends DmlBase implements ICommerceEntitlementProductsDAO {

    public Schema.SObjectType getSObjectType() {
        return CommerceEntitlementProduct.SObjectType;
    } 

    public static ICommerceEntitlementProductsDAO newInstance() {
        return (ICommerceEntitlementProductsDAO) ImplementationSelector.DAO.newInstance(
            CommerceEntitlementProduct.SObjectType
        );
    }

    public List<CommerceEntitlementProduct> getCommerceEntitlementProductByPolicyIdAndProductId(
        List<Id> entPolicyCCEIdSet,
        Set<Id> productIdSet,
        AccessLevel accessLevel
    ){

        if(entPolicyCCEIdSet.isEmpty() && productIdSet.isEmpty()){
            return new List<CommerceEntitlementProduct>();
        }
        return Database.query(
            'SELECT PolicyId, ProductId ' +
            'FROM CommerceEntitlementProduct ' +
            'WHERE PolicyId IN :entPolicyCCEIdSet ' +
            'AND ProductId IN :productIdSet ',
            accessLevel
        );
    }

}
