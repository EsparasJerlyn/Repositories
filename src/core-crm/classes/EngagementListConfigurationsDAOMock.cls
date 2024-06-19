/**
 * @description Mock DAO Class for Engagement List Configuration Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 16, 2024         | DEPP-8484              | Created file                 |
 */
@isTest
public inherited sharing class EngagementListConfigurationsDAOMock extends DmlBaseMock implements IEngagementListConfigurationsDAO {

    public Map<Id, Engagement_List_Configuration__c> engagementListConfigMap;

    public Schema.SObjectType getSObjectType() {
        return Engagement_List_Configuration__c.SObjectType;
    }

    public EngagementListConfigurationsDAOMock() {
        super(new Map<Id, Engagement_List_Configuration__c>(), Schema.Engagement_List_Configuration__c.SObjectType);
        this.engagementListConfigMap = (Map<Id, Engagement_List_Configuration__c>) super.records;
    }

}