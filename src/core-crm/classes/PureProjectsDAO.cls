/**
 * @description DAO Class for Pure_Project__c Object. Contains soql and constants related to the Pure_Project__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
 *    | ryan.j.a.dela.cruz             | July 03, 2023         | DEPP-5390              | Created file                                     |
 *    | ryan.j.a.dela.cruz             | July 18, 2023         | DEPP-5457/DEPP-5468    | Added getOpportunityPureProjectRecords method    |
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

    public List<Pure_Project__c> getOpportunityPureProjectRecords(Set<Id> opportunityIds) {
        return [  // NO PMD
            SELECT Id, Opportunity__c, Opportunity_Outcome__c
            FROM Pure_Project__c
            WHERE Opportunity__c IN :opportunityIds
            WITH USER_MODE
        ];
    }
}
