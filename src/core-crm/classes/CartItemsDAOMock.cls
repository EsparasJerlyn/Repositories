/**
 * @description Mock DAO Class for CartItem Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                          |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------|
      | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                            |
      | julie.jane.alegre              | January 03, 2024      | ApexCRUDViolationFix   | Add countCartItemsGroupByCourseOffering |
      |                                |                       |                        | Add countCartItemsGroupByProgramOffering|
      | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCartItemsByWebCartId| 
 */
@isTest
public inherited sharing class CartItemsDAOMock extends DmlBaseMock implements ICartItemsDAO {
    public Map<Id, CartItem> cartItemsMap;

    public Schema.SObjectType getSObjectType() {
        return CartItem.SObjectType;
    }

    public CartItemsDAOMock() {
        super(new Map<Id, CartItem>(), Schema.CartItem.SObjectType);
        this.cartItemsMap = (Map<Id, CartItem>) super.records;
    }

    public List<CartItem> getCartItemsWithPricebookEntryByRecordIds(
        Set<String> recordIds,
        AccessLevel accessLevel
    ) {
        List<CartItem> cartItemsList = new List<CartItem>();

        for (CartItem record : cartItemsMap.values()) {
            if (recordIds.contains(record.Id) && record.Pricebook_Entry_ID__c != null) {
                cartItemsList.add(record);
            }
        }

        return cartItemsList;
    }

    public List<CartItem> getCartItemsByCartItemName(
        Set<String> cartItemNames,
        AccessLevel accessLevel
    ) {
        List<CartItem> cartItemsList = new List<CartItem>();

        for (CartItem record : cartItemsMap.values()) {
            if (cartItemNames.contains(record.Name)) {
                cartItemsList.add(record);
            }
        }

        return cartItemsList;
    }

    public List<CartItem> getCartItemsByWebCartId(
        Set<Id> webCartId,
        AccessLevel accessLevel
    ) {
        List<CartItem> cartItemsList = new List<CartItem>();

        for (CartItem record : cartItemsMap.values()) {
            if (webCartId.contains(record.CartId)) {
                cartItemsList.add(record);
            }
        }

        return cartItemsList;
    }

    public List<AggregateResult> countCartItemsGroupByCourseOffering(
        Set<Id> courseOfferIdSet,
        AccessLevel accessLevel
    ) {
        return new List<AggregateResult>();
    }

    public List<AggregateResult> countCartItemsGroupByProgramOffering(
        Set<Id> programOfferIdSet,
        AccessLevel accessLevel
    ) {
        return  new List<AggregateResult>();
    }
}
