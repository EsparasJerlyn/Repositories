/**
 * @description DAO Class for WebCart Object. Contains SOQL and Constants related to the WebCart object.
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

    public List<WebCart> getWebCartByUserId(
        Set<Id> userId,
        AccessLevel accessLevel
    ) {
        if(userId.isEmpty()){
            return new List<WebCart>();
        }
        return Database.query(
            'SELECT Id, Status, (SELECT Id FROM CartItems) ' +
                'FROM WebCart ' +
                'WHERE OwnerId IN: userId ' +
                'AND Status =\'Active\' ',
            accessLevel
        );
    }
}
