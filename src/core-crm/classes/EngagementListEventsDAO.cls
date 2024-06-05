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

    public List<Engagement_List_Event__c> getEngagementListEventsByRelatedRecordIds(
        Map<String, Set<Id>> relatedRecordIdMap,
        AccessLevel accessLevel
    ){
        if(relatedRecordIdMap != null || relatedRecordIdMap.isEmpty()){
            String soql = 'SELECT Id, Case__r.ContactId, Case__r.Status, Engagement_List_Criteria__c, Engagement_List_Criteria__r.Id, Program_Enrollment__c, ' +
                                'Completed_Cadence__c, Course_Connection__c, Course_Connection_Assessment__c, Program_Enrollment_Breach__c, Has_Domestic_Phone__c, ' +
                                'Leave_of_Absence__c, Academic_Status__c, Previous_Academic_Status__c, Course_Enrollment_Status__c, Key_Date__c, Program_Enrollment_Status__c ' + 
                            'FROM Engagement_List_Event__c WHERE Engagement_List_Criteria__c = ' + DynamicQueryService.formatStringSetForWhereClause(relatedRecordIdMap.get('engagementListCriteriaId'));

            soql = addFilterToWhereClause(soql, relatedRecordIdMap.get('programEnrollmentIds'), 'Program_Enrollment__c');
            soql = addFilterToWhereClause(soql, relatedRecordIdMap.get('completedCadenceIds'), 'Completed_Cadence__c');
            soql = addFilterToWhereClause(soql, relatedRecordIdMap.get('courseConnectionIds'), 'Course_Connection__c');
            soql = addFilterToWhereClause(soql, relatedRecordIdMap.get('courseConnectionAssessmentIds'), 'Course_Connection_Assessment__c');
            soql = addFilterToWhereClause(soql, relatedRecordIdMap.get('programEnrollmentBreachIds'), 'Program_Enrollment_Breach__c');
            soql = addFilterToWhereClause(soql, relatedRecordIdMap.get('leaveOfAbsenceIds'), 'Leave_of_Absence__c');

            return Database.query(soql, accessLevel);
        }
        
        return new List<Engagement_List_Event__c>();
    }

    private String addFilterToWhereClause(String soql, Set<Id> idSet, String fieldName){
        if(!idSet.isEmpty()){
            soql += ' AND ' + fieldName + ' IN (' + DynamicQueryService.formatStringSetForWhereClause(idSet) + ')';
        }
        return soql;
    }

    public List<Engagement_List_Event__c> getEngagmentListEventByCaseId(
        Set<Id> caseIds,
        AccessLevel accessLevel
    ){
        if(caseIds.isEmpty()) {
            return new List<Engagement_List_Event__c>();
        }

        return Database.query(
            'SELECT Id, Case__c, Completed_Cadence__c, Course_Connection__c, Course_Connection_Assessment__c, Program_Enrollment_Breach__c, Program_Enrollment__c, ' +
                'Leave_of_Absence__c, Academic_Status__c, Previous_Academic_Status__c, Course_Enrollment_Status__c, Key_Date__c, Program_Enrollment_Status__c ' + 
            'FROM Engagement_List_Event__c ' +
            'WHERE Case__c IN :caseIds',
            accessLevel
        );
    }
}