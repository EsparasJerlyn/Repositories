/**
 * @description DAO Class for Risk Object. Contains soql and constants related to the Risk object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | ryan.j.a.dela.cruz             | August 08, 2023       | DEPP-6335              | Created file
 */
public inherited sharing class RisksDAO extends DmlBase implements IRisksDAO {
    public Schema.SObjectType getSObjectType() {
        return Risk__c.SObjectType;
    }

    public static IRisksDAO newInstance() {
        return (IRisksDAO) ImplementationSelector.DAO.newInstance(Risk__c.SObjectType);
    }
}
