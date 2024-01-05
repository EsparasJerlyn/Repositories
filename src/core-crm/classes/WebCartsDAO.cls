/**
 * @description DAO Class for WebCart Object. Contains soql and constants related to the WebCart object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file
 *    | alexander.cadalin              | Jan 05 ,2024          | n/a                    | Added methods
 */
public inherited sharing class WebCartsDAO extends DmlBase implements IWebCartsDAO {
    public static final String STATUS_ACTIVE = 'Active';

    public Schema.SObjectType getSObjectType() {
        return WebCart.SObjectType;
    }

    public static IWebCartsDAO newInstance() {
        return (IWebCartsDAO) ImplementationSelector.DAO.newInstance(WebCart.sObjectType);
    }

    public WebCart getActiveWebCartByOwnerId(Id ownerId) {
        try {
            // Intentionally accessing on SYSTEM_MODE
            return Database.query('SELECT Id, Status FROM WebCart WHERE Status= :STATUS_ACTIVE AND OwnerId = :ownerId LIMIT 1');
        } catch (QueryException qe) {
            return null;
        }
    }
}
