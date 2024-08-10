/**
 * @description DAO Class for CartDeliveryGroup Object. Contains soql and constants related to the CartDeliveryGroup object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                 |
 */
public inherited sharing class CartDeliveryGroupsDAO extends DmlBase implements ICartDeliveryGroupsDAO {
    public Schema.SObjectType getSObjectType() {
        return CartDeliveryGroup.SObjectType;
    }

    public static ICartDeliveryGroupsDAO newInstance() {
        return (ICartDeliveryGroupsDAO) ImplementationSelector.DAO.newInstance(CartDeliveryGroup.sObjectType);
    }
}
