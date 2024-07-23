/**
 * @description Interface for Commerce Entitlement Product DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Created file                 |
 */
public interface ICommerceEntitlementProductsDAO extends DmlInterface {

    List<CommerceEntitlementProduct> getCommerceEntitlementProductByPolicyIdAndProductId(
        List<Id> entPolicyCCEIdSet,
        Set<Id> productIdSet,
        AccessLevel accessLevel
    );  
}
