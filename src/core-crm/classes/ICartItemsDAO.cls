/**
 * @description Interface for CartItem DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                 |
 *    | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCourseOfferingByProgramOfferingIdTest |
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
}
