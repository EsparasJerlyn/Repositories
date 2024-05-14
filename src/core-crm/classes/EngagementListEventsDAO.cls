/**
 * @description DAO Class for Engagement List Event Object that contains soql and constants related to it.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 14, 2024         | DEPP-8484              | Created file                 |
 */
public inherited sharing class EngagementListEventsDAO extends DmlBase implements IEngagementListEventsDAO{

    public Schema.SObjectType getSObjectType() {
        return Engagement_List_Event__c.SObjectType;
    }

    public static IEngagementListEventsDAO newInstance() {
        return (IEngagementListEventsDAO) ImplementationSelector.DAO.newInstance(Engagement_List_Event__c.SObjectType);
    }

}