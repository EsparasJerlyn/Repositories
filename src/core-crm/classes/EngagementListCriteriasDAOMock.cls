/**
 * @description Mock DAO Class for Engagement List Criteria Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | vincent.ferrer                 |  May 1, 2024          | DEPP-8492              | Created file                                                |
 */
@isTest
public inherited sharing class EngagementListCriteriasDAOMock extends DmlBaseMock implements IEngagementListCriteriasDAO {
    public Map<Id, Engagement_List_Criteria__c> engagementListCriteriaMap;

    public Schema.SObjectType getSObjectType() {
        return Engagement_List_Criteria__c.SObjectType;
    }

    public EngagementListCriteriasDAOMock() {
        super(new Map<Id, Engagement_List_Criteria__c>(), Schema.Engagement_List_Criteria__c.SObjectType);
        this.engagementListCriteriaMap = (Map<Id, Engagement_List_Criteria__c>) super.records;
    }

    public List<Engagement_List_Criteria__c> findActiveEngagementListCriteriasByRecordtype(
        Id recordTypeId,
        Date executionDate,
        AccessLevel accessLevel
    ) {
        List<Engagement_List_Criteria__c> engagementListCriteriaList = new List<Engagement_List_Criteria__c>();

        for (Engagement_List_Criteria__c record : engagementListCriteriaMap.values()) {
            if (record.Engagement_List_Configuration__r.Engagement_List_Configuration_Status__c == 'Active' && 
                record.Engagement_List_Configuration__r.Start_Date__c <= executionDate &&
                record.Engagement_List_Configuration__r.End_Date__c >= executionDate &&
                record.Status__c == 'Active' &&
                record.Start_Date__c <= executionDate && 
                record.End_Date__c >= executionDate &&
                record.RecordTypeId == recordTypeId) {
                engagementListCriteriaList.add(record);
            }
        }
        return engagementListCriteriaList;
    }

    public Engagement_List_Criteria__c getEntryCriteriaById(Id recordId, AccessLevel accessLevel) {
        for(Engagement_List_Criteria__c record : engagementListCriteriaMap.values()) {
            if(record.Id == recordId) { return record; }
        }
        return null;
    }
} 
