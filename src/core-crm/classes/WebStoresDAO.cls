/**
 * @description DAO Class for WebStore Object. Contains SOQL and Constants related to the WebStore object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                 |
 */
public inherited sharing class WebStoresDAO extends DmlBase implements IWebStoresDAO {
    public static final String WEBSTORE_NAME_CCE = 'CCE';

    public Schema.SObjectType getSObjectType() {
        return WebStore.SObjectType;
    }

    public static IWebStoresDAO newInstance() {
        return (IWebStoresDAO) ImplementationSelector.DAO.newInstance(WebStore.sObjectType);
    }

    public WebStore getCCEWebStoreId() {
        try {
            // Intentionally accessing on SYSTEM_MODE
            return Database.query('SELECT Id FROM WebStore WHERE Name = :WEBSTORE_NAME_CCE LIMIT 1');
        } catch (QueryException qe) {
            return null;
        }
    }
}
