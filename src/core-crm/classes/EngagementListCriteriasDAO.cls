/**
 * @description DAO Class for EngagementList Criteria Object. Contains soql and constants related to the EngagementList Criteria object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | vincent.ferrer                 |  May 1, 2024          | DEPP-8492              | Created file                 |
 */

 public inherited sharing class EngagementListCriteriasDAO extends DmlBase implements IEngagementListCriteriasDAO {
   
    public static final String RECORD_TYPE_DEVELOPER_NAME_ENTRY_CRITERIA = 'Entry_Criteria';
    public static final Id RECORD_TYPE_ID_ENTRY_CRITERIA = Schema.SObjectType.Engagement_List_Criteria__c.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_DEVELOPER_NAME_ENTRY_CRITERIA).getRecordTypeId();
    
    public static final String KEY_DATE_COMPLETED_CADENCE_DATE = 'Completed Cadence Date';
    public static final String KEY_DATE_LEAVE_OF_ABSENCE_END_DATE = 'Leave Of Absence End Date';
    public static final String KEY_DATE_BREACH_START_DATE = 'Breach Start Date';
    public static final String KEY_DATE_ACADEMIC_STATUS_DATE = 'Academic Status Date';
    public static final String KEY_DATE_ASSESSMENT_DUE_DATE = 'Assessment Due Date';

    public Schema.SObjectType getSObjectType() {
        return Engagement_List_Criteria__c.SObjectType;
    }

    public static IEngagementListCriteriasDAO newInstance() {
        return (IEngagementListCriteriasDAO) ImplementationSelector.DAO.newInstance(Engagement_List_Criteria__c.SObjectType);
    }

    public static List<Engagement_List_Criteria__c> findActiveEntryCriteria(Date executionDate, AccessLevel accessLevel) {

        if(executionDate == null){
            return new List<Engagement_List_Criteria__c>();
        }

        return Database.query(
            'SELECT Id, ' +
            'Engagement_List_Configuration__r.Engagement_List_Configuration_Status__c, ' +
            'Engagement_List_Configuration__r.Start_Date__c, ' +
            'Engagement_List_Configuration__r.End_Date__c, ' +
            'Engagement_List_Configuration__r.Name, ' +
            'Engagement_List_Configuration__r.Id, ' +
            'Status__c, ' +
            'End_Date__c, ' +
            'Start_Date__c ' +
            'FROM Engagement_List_Criteria__c ' +
            'WHERE Engagement_List_Configuration__r.Engagement_List_Configuration_Status__c = \'Active\' ' +
            'AND Status__c = \'Active\' ' +
            'AND Engagement_List_Configuration__r.Start_Date__c <= :executionDate ' +
            'AND Engagement_List_Configuration__r.End_Date__c >= :executionDate ' +
            'AND Start_Date__c <= :executionDate ' +
            'AND RecordType.DeveloperName =: RECORD_TYPE_DEVELOPER_NAME_ENTRY_CRITERIA '+ 
            'AND End_Date__c >= :executionDate',
            accessLevel
        );
    }
    
}