/**
 * @description Interface for Pricebook Entries DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                 |
 */
public interface IPricebookEntriesDAO extends DmlInterface {
    List<PricebookEntry> getPricebookEntriesByRecordIdsAndPricebookNames(
        Set<String> recordIds,
        Set<String> priceBookNames,
        AccessLevel accessLevel
    );
}
