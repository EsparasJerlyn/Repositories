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

    public List<Engagement_List_Event__c> getEngagementListEventsByRelatedRecordIds(
        Map<String, Set<Id>> relatedRecordIdMap,
        AccessLevel accessLevel
    ){
        List<Engagement_List_Event__c> engagementEventList = new List<Engagement_List_Event__c>();

        for (Engagement_List_Event__c record : engagementListEventMap.values()) {
            if(
                relatedRecordIdMap.get('programEnrollmentIds').contains(record.Program_Enrollment__c) &&
                relatedRecordIdMap.get('completedCadenceIds').contains(record.Completed_Cadence__c) &&
                relatedRecordIdMap.get('courseConnectionIds').contains(record.Course_Connection__c) &&
                relatedRecordIdMap.get('courseConnectionAssessmentIds').contains(record.Course_Connection_Assessment__c) &&
                relatedRecordIdMap.get('programEnrollmentBreachIds').contains(record.Program_Enrollment_Breach__c) &&
                relatedRecordIdMap.get('leaveOfAbsenceIds').contains(record.Leave_of_Absence__c)
            )){
                engagementEventList.add(record);
            }
        }
        return engagementEventList;
    }

    public List<Engagement_List_Criteria__c> findActiveEntryCriteria(
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
                record.End_Date__c >= executionDate) {
                engagementListCriteriaList.add(record);
            }
        }
        return engagementListCriteriaList;
    }

}