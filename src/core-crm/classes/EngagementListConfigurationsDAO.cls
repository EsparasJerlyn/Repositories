/**
 * @description DAO Class for Engagement List Config Object that contains soql and constants related to it.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 14, 2024         | DEPP-8484              | Created file                 |
 */
public inherited sharing class EngagementListConfigurationsDAO extends DmlBase implements IEngagementListConfigurationsDAO{

    public Schema.SObjectType getSObjectType() {
        return Engagement_List_Configuration__c.SObjectType;
    }

    public static IEngagementListConfigurationsDAO newInstance() {
        return (IEngagementListConfigurationsDAO) ImplementationSelector.DAO.newInstance(Engagement_List_Configuration__c.SObjectType);
    }
}