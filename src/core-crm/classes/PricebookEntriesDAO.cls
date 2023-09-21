/**
 * @description DAO Class for CartItem Object. Contains soql and constants related to the CartItem object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public inherited sharing class PricebookEntriesDAO extends DmlBase implements IPricebookEntriesDAO {
    public Schema.SObjectType getSObjectType() {
        return PricebookEntry.SObjectType;
    }

    public static IPricebookEntriesDAO newInstance() {
        return (IPricebookEntriesDAO) ImplementationSelector.DAO.newInstance(PricebookEntry.sObjectType);
    }

    public List<PricebookEntry> getPricebookEntriesByRecordIdsAndPricebookNames(
        Set<String> recordIds,
        Set<String> priceBookNames,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, PriceBook2.Name ' +
                'FROM PricebookEntry ' +
                'WHERE Id IN :recordIds ' +
                'AND PriceBook2.Name IN: priceBookNames',
            accessLevel
        );
    }
}
