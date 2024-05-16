/**
 * @description Model Class for Engagement List Event Key
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 15, 2024         | DEPP-8484              | Created file                 |
 */
public with sharing class EngagementListEventKey {

    private Id contactId;
    private Id criteriaId;
    private Id programEnrollmentId;
    private Id completedCadenceId;
    private Id courseConnectionId;
    private Id courseConnectionAssessmentId;
    private Id programEnrollmentBreachId;
    private Id leaveOfAbsenceId;
    private String academicStatus;
    private String courseEnrollmentStatus;   
    private String programEnrollmentStatus;
    private Datetime keyDate;
    
    public EngagementListEventKey(Engagement_List_Event__c event, Id contactId, Id criteriaId) {
        this.contactId = setKeyAttributes(contactId, this.contactId);
        this.criteriaId = setKeyAttributes(criteriaId, this.criteriaId);
        programEnrollmentId = setKeyAttributes(event.Program_Enrollment__c, programEnrollmentId);
        completedCadenceId = setKeyAttributes(event.Completed_Cadence__c, completedCadenceId);
        courseConnectionId = setKeyAttributes(event.Course_Connection__c, courseConnectionId);
        courseConnectionAssessmentId = setKeyAttributes(event.Course_Connection_Assessment__c, courseConnectionAssessmentId);
        programEnrollmentBreachId = setKeyAttributes(event.Program_Enrollment_Breach__c, programEnrollmentBreachId);
        leaveOfAbsenceId = setKeyAttributes(event.Leave_of_Absence__c, leaveOfAbsenceId);
        academicStatus = setKeyAttributes(event.Academic_Status__c, academicStatus);
        courseEnrollmentStatus = setKeyAttributes(event.Course_Enrollment_Status__c, courseEnrollmentStatus);
        keyDate = setKeyAttributes(event.Key_Date__c, keyDate);
        programEnrollmentStatus = setKeyAttributes(event.Program_Enrollment_Status__c, programEnrollmentStatus);
    }

    public Boolean isDuplicate(EngagementListEventKey eventKey) {
        return             
            contactId == eventKey.contactId &&
            criteriaId == eventKey.criteriaId &&
            programEnrollmentId == eventKey.programEnrollmentId &&
            completedCadenceId == eventKey.completedCadenceId &&
            courseConnectionId == eventKey.courseConnectionId &&
            courseConnectionAssessmentId == eventKey.courseConnectionAssessmentId &&
            programEnrollmentBreachId == eventKey.programEnrollmentBreachId &&
            leaveOfAbsenceId == eventKey.leaveOfAbsenceId &&
            academicStatus == eventKey.academicStatus &&
            courseEnrollmentStatus == eventKey.courseEnrollmentStatus &&
            keyDate == eventKey.keyDate &&
            programEnrollmentStatus == eventKey.programEnrollmentStatus;
    }

    private Id setKeyAttributes(Id recordId, Id recordIdToSet){
        if(recordId != null){
            recordIdToSet = recordId;
        }
        return recordIdToSet;
    }

    private String setKeyAttributes(String recordString, String recordStringToSet){
        if(String.isNotBlank(recordString)){
            recordStringToSet = recordString;
        }
        return recordStringToSet;
    }

    private Datetime setKeyAttributes(Datetime recordDate, Datetime recordDateToSet){
        if(recordDate != null){
            recordDateToSet = recordDate;
        }
        return recordDateToSet;
    }

}