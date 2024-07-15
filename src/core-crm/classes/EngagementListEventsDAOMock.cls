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
            ){
                engagementEventList.add(record);
            }
        }
        return engagementEventList;
    }

    public List<Engagement_List_Event__c> getEngagmentListEventByCaseId(
        Set<Id> caseIds,
        AccessLevel accessLevel
    ){
        List<Engagement_List_Event__c> engagementEventList = new List<Engagement_List_Event__c>();

        for (Engagement_List_Event__c record : engagementListEventMap.values()) {
            if (caseIds.contains(record.Case__c)) {
                engagementEventList.add(record);
            }
        }
        return engagementEventList;
    }
}