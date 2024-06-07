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

    public static final String RECORD_TYPE_DEVELOPER_NAME_IMPORTED = 'Imported';
    public static final Id RECORD_TYPE_ID_IMPORTED = Schema.SObjectType.Engagement_List_Criteria__c.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_DEVELOPER_NAME_IMPORTED).getRecordTypeId();
    
    public static final String KEY_DATE_COMPLETED_CADENCE_DATE = 'Completed Cadence Date';
    public static final String KEY_DATE_LEAVE_OF_ABSENCE_END_DATE = 'Leave Of Absence End Date';
    public static final String KEY_DATE_BREACH_START_DATE = 'Breach Start Date';
    public static final String KEY_DATE_ACADEMIC_STATUS_DATE = 'Academic Status Date';
    public static final String KEY_DATE_ASSESSMENT_DUE_DATE = 'Assessment Due Date';
    public static final String COMPLETED_PREVIEW_STATUS = 'Completed';
    public static final String IN_PROGRESS_PREVIEW_STATUS = 'In Progress';
    public static final String NOT_GENERATED_PREVIEW_STATUS = 'Not Generated';
    public static final String FAILED_PREVIEW_STATUS = 'Failed';
    public static final String ACTIVE_STATUS = 'Active';
    public static final String DEACTIVATED_STATUS = 'Deactivated';
    public static final String IS_ON_LEAVE_YES = 'Yes';

    public static final Set<String> CRITERIA_FIELDS = new Set<String>{
        'Academic_Status__c', 'Previous_Academic_Status__c', 'Citizenship_Status__c','Course_Grade__c','Failed_To_Submit_Assessment__c',
        'Assessment_Priority__c','Key_Date__c','Category_Type__c','Breach__c','Completed_Cadence__c',
        'Has_Domestic_Phone__c','Failed_Assessment__c','Is_On_Leave_of_Absence__c',
        'Equity_Scholarship_Bursary__c','Key_Date_Offset_Lower_Boundary__c','Key_Date_Offset_Upper_Boundary__c',
        'Engagement_List_Configuration__c'
    };

    public Schema.SObjectType getSObjectType() {
        return Engagement_List_Criteria__c.SObjectType;
    }

    public static IEngagementListCriteriasDAO newInstance() {
        return (IEngagementListCriteriasDAO) ImplementationSelector.DAO.newInstance(Engagement_List_Criteria__c.SObjectType);
    }

    public static List<Engagement_List_Criteria__c> findActiveEngagementListCriteriasByRecordtype(
        Id recordTypeId,
        Date executionDate, 
        AccessLevel accessLevel
    ) {

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
            'Status__c, Start_Date__c, End_Date__c, RecordTypeId, ' +
            'Assessment_Priority__c, Failed_To_Submit_Assessment__c, ' +
            'Citizenship_Status__c, Academic_Status__c, Previous_Academic_Status__c, Category_Type__c, Cases_Created__c, ' +
            'Completed_Cadence__c, Course_Grade__c, Breach__c, Is_On_Leave_of_Absence__c, ' +
            'Key_Date__c, Key_Date_Offset_Lower_Boundary__c, Key_Date_Offset_Upper_Boundary__c ' +
            'FROM Engagement_List_Criteria__c ' +
            'WHERE Engagement_List_Configuration__r.Engagement_List_Configuration_Status__c = \'Active\' ' +
            'AND Status__c = \'Active\' ' +
            'AND ( Engagement_List_Configuration__r.Start_Date__c <= :executionDate OR Engagement_List_Configuration__r.Start_Date__c = null ) ' +
            'AND ( Engagement_List_Configuration__r.End_Date__c >= :executionDate OR Engagement_List_Configuration__r.End_Date__c = null ) ' +
            'AND ( Start_Date__c <= :executionDate OR Start_Date__c = null ) ' +
            'AND ( End_Date__c >= :executionDate OR End_Date__c = null ) ' +
            'AND RecordTypeId =: recordTypeId',
            accessLevel
        );
    }
    
    public static Engagement_List_Criteria__c getEntryCriteriaById(Id recordId, AccessLevel accessLevel) {
        if(recordId == null) { return null; }

        return Database.query(
            'SELECT Id, ' +
            'Name, ' +
            'Preview_Status__c, ' +
            'Status__c, ' +
            'Start_Date__c, ' +
            'End_Date__c, ' +
            'RecordTypeId, ' +
            'Assessment_Priority__c, ' +
            'Failed_To_Submit_Assessment__c,' +
            'Preview_Job_Id__c, ' +
            'Citizenship_Status__c, ' +
            'Academic_Status__c, ' +
            'Previous_Academic_Status__c, ' +
            'Category_Type__c, ' +
            'Completed_Cadence__c, ' +
            'Course_Grade__c, ' +
            'Breach__c, ' +
            'Is_On_Leave_of_Absence__c, ' +
            'Key_Date__c, ' +
            'Key_Date_Offset_Lower_Boundary__c, ' +
            'Key_Date_Offset_Upper_Boundary__c, ' +
            'Engagement_List_Criteria_Title__c, ' +
            'Preview_Result_Attachment_Id__c, ' +
            'Cases_Created__c, ' +
            'Engagement_List_Configuration__r.Engagement_List_Configuration_Status__c, ' +
            'Engagement_List_Configuration__r.Start_Date__c, ' +
            'Engagement_List_Configuration__r.End_Date__c, ' +
            'Engagement_List_Configuration__r.Name, ' +
            'Engagement_List_Configuration__r.Id, ' + 
            'Engagement_List_Configuration__c ' + 
            'FROM Engagement_List_Criteria__c ' +
            'WHERE Id = :recordId LIMIT 1 ' +
            'FOR UPDATE', //Fix racing condition during preview
            accessLevel
        );
    }
}