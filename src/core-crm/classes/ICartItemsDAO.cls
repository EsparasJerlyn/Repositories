/**
 * @description Interface for CartItems DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                          |
 *    |--------------------------------|-----------------------|------------------------|-----------------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                            |
 *    | julie.jane.alegre              | January 03, 2024      | ApexCRUDViolationFix   | Add countCartItemsGroupByCourseOffering |
 *    |                                |                       |                        | Add countCartItemsGroupByProgramOffering|
 *    | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCartItemsByWebCartId|
 */
public interface ICartItemsDAO extends DmlInterface {
    List<CartItem> getCartItemsWithPricebookEntryByRecordIds(
        Set<String> recordIds,
        AccessLevel accessLevel
    );

    List<CartItem> getCartItemsByCartItemName(
        Set<String> cartItemNames,
        AccessLevel accessLevel
    );

    List<CartItem> getCartItemsByWebCartId(
        Set<Id> webCartId,
        AccessLevel accessLevel
    );

    List<AggregateResult> countCartItemsGroupByCourseOffering(
        Set<Id> courseOfferIdSet,
        AccessLevel accessLevel
    );

    List<AggregateResult> countCartItemsGroupByProgramOffering(
        Set<Id> programOfferIdSet,
        AccessLevel accessLevel
    );
}
