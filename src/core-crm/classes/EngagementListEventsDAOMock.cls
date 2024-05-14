/**
 * @description Mock DAO Class for Engagement List Event Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 14, 2024         | DEPP-8484              | Created file                 |
 */
@isTest
public inherited sharing class EngagementListEventsDAOMock extends DmlBaseMock implements IEngagementListEventsDAO {

    public Map<Id, Engagement_List_Event__c> engagementListEventMap;

    public Schema.SObjectType getSObjectType() {
        return Engagement_List_Event__c.SObjectType;
    }

    public EngagementListEventsDAOMock() {
        super(new Map<Id, Engagement_List_Event__c>(), Schema.Engagement_List_Event__c.SObjectType);
        this.engagementListEventMap = (Map<Id, Engagement_List_Event__c>) super.records;
    }

}