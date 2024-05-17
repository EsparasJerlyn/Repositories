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
        this.contactId = contactId;
        this.criteriaId = criteriaId;
        programEnrollmentId = event.Program_Enrollment__c;
        completedCadenceId = event.Completed_Cadence__c;
        courseConnectionId = event.Course_Connection__c;
        courseConnectionAssessmentId = event.Course_Connection_Assessment__c;
        programEnrollmentBreachId = event.Program_Enrollment_Breach__c;
        leaveOfAbsenceId = event.Leave_of_Absence__c;
        academicStatus = event.Academic_Status__c;
        courseEnrollmentStatus = event.Course_Enrollment_Status__c;
        keyDate = event.Key_Date__c;
        programEnrollmentStatus = event.Program_Enrollment_Status__c;
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

}