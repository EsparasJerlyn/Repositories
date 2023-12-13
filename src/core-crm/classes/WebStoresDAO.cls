/**
 * @description DAO Class for WebStore Object. Contains soql and constants related to the WebStore object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file
 */
public inherited sharing class WebStoresDAO extends DmlBase implements IWebStoresDAO {
    public Schema.SObjectType getSObjectType() {
        return WebStore.SObjectType;
    }

    public static IWebStoresDAO newInstance() {
        return (IWebStoresDAO) ImplementationSelector.DAO.newInstance(WebStore.sObjectType);
    }
}
