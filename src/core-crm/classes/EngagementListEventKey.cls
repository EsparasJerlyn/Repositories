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
    private String previousAcademicStatus;
    private String courseEnrollmentStatus;   
    private String programEnrollmentStatus;
    private Datetime keyDate;
    private Boolean hasDomesticPhone;
    
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
        previousAcademicStatus = event.Previous_Academic_Status__c;
        courseEnrollmentStatus = event.Course_Enrollment_Status__c;
        keyDate = event.Key_Date__c;
        programEnrollmentStatus = event.Program_Enrollment_Status__c;
        hasDomesticPhone = event.Has_Domestic_Phone__c;
    }

    public Integer hashCode() {

        final Integer prime = 31;
        Integer result = 1;

        result = prime * result + (this.contactId != null ? this.contactId.hashCode() : 0);
        result = prime * result + (this.criteriaId != null ? this.criteriaId.hashCode() : 0);
        result = prime * result + (this.programEnrollmentId != null ? this.programEnrollmentId.hashCode() : 0);
        result = prime * result + (this.completedCadenceId != null ? this.completedCadenceId.hashCode() : 0);
        result = prime * result + (this.courseConnectionId != null ? this.courseConnectionId.hashCode() : 0);
        result = prime * result + (this.courseConnectionAssessmentId != null ? this.courseConnectionAssessmentId.hashCode() : 0);
        result = prime * result + (this.programEnrollmentBreachId != null ? this.programEnrollmentBreachId.hashCode() : 0);
        result = prime * result + (this.leaveOfAbsenceId != null ? this.leaveOfAbsenceId.hashCode() : 0);
        result = prime * result + (this.academicStatus != null ? this.academicStatus.hashCode() : 0);
        result = prime * result + (this.previousAcademicStatus != null ? this.previousAcademicStatus.hashCode() : 0);
        result = prime * result + (this.courseEnrollmentStatus != null ? this.courseEnrollmentStatus.hashCode() : 0);
        result = prime * result + (this.keyDate != null ? this.keyDate.hashCode() : 0);
        result = prime * result + (this.programEnrollmentStatus != null ? this.programEnrollmentStatus.hashCode() : 0);
        result = prime * result + (this.hasDomesticPhone != null ? this.hasDomesticPhone.hashCode() : 0);
        return result;
        
    }

    public Boolean equals(Object obj) {
        if (obj instanceof EngagementListEventKey) {
            EngagementListEventKey key = (EngagementListEventKey)obj;
            return             
                this.contactId == key.contactId &&
                this.criteriaId == key.criteriaId &&
                this.programEnrollmentId == key.programEnrollmentId &&
                this.completedCadenceId == key.completedCadenceId &&
                this.courseConnectionId == key.courseConnectionId &&
                this.courseConnectionAssessmentId == key.courseConnectionAssessmentId &&
                this.programEnrollmentBreachId == key.programEnrollmentBreachId &&
                this.leaveOfAbsenceId == key.leaveOfAbsenceId &&
                this.academicStatus == key.academicStatus &&
                this.previousAcademicStatus == key.previousAcademicStatus &&
                this.courseEnrollmentStatus == key.courseEnrollmentStatus &&
                this.keyDate == key.keyDate &&
                this.programEnrollmentStatus == key.programEnrollmentStatus &&
                this.hasDomesticPhone == key.hasDomesticPhone;
        }
        return false;
    }

}