/**
 * @description Mock DAO Class for CartDeliveryGroup Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file
 */
@isTest
public inherited sharing class CartDeliveryGroupsDAOMock extends DmlBaseMock implements ICartDeliveryGroupsDAO {
    public Map<Id, CartDeliveryGroup> cartDeliveryGroupsMap;

    public Schema.SObjectType getSObjectType() {
        return CartDeliveryGroup.SObjectType;
    }

    public CartDeliveryGroupsDAOMock() {
        super(new Map<Id, CartDeliveryGroup>(), Schema.CartDeliveryGroup.SObjectType);
        this.cartDeliveryGroupsMap = (Map<Id, CartDeliveryGroup>) super.records;
    }
}
