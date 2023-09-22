/**
 * @description DAO Class for WebCart Object. Contains SOQL and Constants related to the WebCart object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                 |
 */
public inherited sharing class WebCartsDAO extends DmlBase implements IWebCartsDAO {
    public Schema.SObjectType getSObjectType() {
        return WebCart.SObjectType;
    }

    public static IWebCartsDAO newInstance() {
        return (IWebCartsDAO) ImplementationSelector.DAO.newInstance(WebCart.sObjectType);
    }
}
