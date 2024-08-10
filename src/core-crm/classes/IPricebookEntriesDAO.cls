/**
 * @description Interface for Pricebook Entries DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file
 *    | alexander.cadalin              | Jan 05 ,2024          | n/a                    | Added methods
 */
public interface IPricebookEntriesDAO extends DmlInterface {
    List<PricebookEntry> getPricebookEntriesByRecordIdsAndPricebookNames(
        Set<String> recordIds,
        Set<String> priceBookNames,
        AccessLevel accessLevel
    );

    List<PricebookEntry> getPricebookEntriesByIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    );
}
