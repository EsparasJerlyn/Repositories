/**
 * @description Mock DAO Class for Engagement Code Auto Number custom setting. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 18, 2023          | DEPP-5594              | created file
 */
@isTest
public inherited sharing class EngagementCodeAutoNumbersDAOMock extends DmlBaseMock implements IEngagementCodeAutoNumbersDAO {
    public Map<Id, Engagement_Code_Auto_Number__c> engagementCodeAutoNumMap;

    public Schema.SObjectType getSObjectType() {
        return Engagement_Code_Auto_Number__c.SObjectType;
    }

    public EngagementCodeAutoNumbersDAOMock() {
        super(new Map<Id, Engagement_Code_Auto_Number__c>(), Schema.Engagement_Code_Auto_Number__c.SObjectType);
        this.engagementCodeAutoNumMap = (Map<Id, Engagement_Code_Auto_Number__c>) super.records;
    }
}
