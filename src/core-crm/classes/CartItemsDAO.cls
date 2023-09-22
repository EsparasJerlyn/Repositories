/**
 * @description DAO Class for CartItem Object. Contains soql and constants related to the CartItem object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public inherited sharing class CartItemsDAO extends DmlBase implements ICartItemsDAO {
    public Schema.SObjectType getSObjectType() {
        return CartItem.SObjectType;
    }

    public static ICartItemsDAO newInstance() {
        return (ICartItemsDAO) ImplementationSelector.DAO.newInstance(CartItem.sObjectType);
    }

    public List<CartItem> getCartItemsWithPricebookEntryByRecordIds(
        Set<String> recordIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Pricebook_Entry_ID__c ' +
                'FROM CartItem ' +
                'WHERE Id IN :recordIds ' +
                'AND Pricebook_Entry_ID__c != NULL ',
            accessLevel
        );
    }

    public List<CartItem> getCartItemsByCartItemName(
        Set<String> cartItemNames,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Pricebook_Entry_ID__c ' +
                'FROM CartItem ' +
                'WHERE Name IN: cartItemNames ',
            accessLevel
        );
    }
}
