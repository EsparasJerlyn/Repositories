/**
 * @description DAO Class for CartItem Object. Contains SOQL and Constants related to the CartItem object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                          |
 *    |--------------------------------|-----------------------|------------------------|-----------------------------------------|
 *    | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                            |
 *    | julie.jane.alegre              | January 03, 2024      | ApexCRUDViolationFix   | Add countCartItemsGroupByCourseOffering |
 *    |                                |                       |                        | Add countCartItemsGroupByProgramOffering|
 *    | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCartItemsByWebCartId|
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

    public List<CartItem> getCartItemsByWebCartId(
        Set<Id> webCartId,
        AccessLevel accessLevel
    ) {
        if(webCartId.isEmpty()){
            return new List<CartItem>();
        }
        return Database.query(
            'SELECT  Id, Cart.Cart_Payment__c, Cart.External_Id__c, TotalPrice,  Course_Offering__c,  ' +
                'Cart.TotalAmount, CartId, Contact__c, Pricebook_Entry_ID__c, Program_Offering__c ' +
                'FROM CartItem ' +
                'WHERE CartId IN: webCartId ',
            accessLevel
        );
    }

    public List<AggregateResult> countCartItemsGroupByCourseOffering(
        Set<Id> courseOfferIdSet,
        AccessLevel accessLevel
    ) {
        if(courseOfferIdSet.isEmpty()){
            return new List<AggregateResult>();
        }
        return Database.query(
            'SELECT Course_Offering__c, COUNT(Id) counter ' +
                'FROM CartItem ' +
                'WHERE Course_Offering__c IN :courseOfferIdSet  ' +
                'AND Cart.Status__c = \'Checkout\' ' + 
                'GROUP BY Course_Offering__c',
            accessLevel
        );
    }

    public List<AggregateResult> countCartItemsGroupByProgramOffering(
        Set<Id> programOfferIdSet,
        AccessLevel accessLevel
    ) {
        if(programOfferIdSet.isEmpty()){
            return new List<AggregateResult>();
        }
        return Database.query(
            'SELECT Program_Offering__c, COUNT(Id) counter ' +
                'FROM CartItem ' +
                'WHERE Program_Offering__c IN :programOfferIdSet  ' +
                'AND Cart.Status__c = \'Checkout\' ' + 
                'GROUP BY Program_Offering__c',
            accessLevel
        );
    }

}
