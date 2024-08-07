/**
 * @description DAO Class for Breach__c Object. Contains soql and constants related to the Breach object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | arsenio.jr.dayrit              | May 9, 2024           | DEPP-8487              | created file                               |
 */
public inherited sharing class BreachesDAO extends DmlBase implements IBreachesDAO {

    public static IBreachesDAO newInstance() {
        return (IBreachesDAO) ImplementationSelector.DAO.newInstance(Breach__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Breach__c.SObjectType;
    }

} 