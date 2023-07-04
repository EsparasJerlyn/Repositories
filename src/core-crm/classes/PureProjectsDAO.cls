/**
 * @description DAO Class for Pure_Project__c Object. Contains soql and constants related to the Pure_Project__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                         |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------|
 *    | ryan.j.a.dela.cruz             | July 03, 2023         | DEPP-5390              | Created file                           |
 */
public inherited sharing class PureProjectsDAO extends DmlBase implements IPureProjectsDAO {
    public Schema.SObjectType getSObjectType() {
        return Pure_Project__c.SObjectType;
    }

    public static IPureProjectsDAO newInstance() {
        return (IPureProjectsDAO) ImplementationSelector.DAO.newInstance(
            Pure_Project__c.SObjectType
        );
    }
}
