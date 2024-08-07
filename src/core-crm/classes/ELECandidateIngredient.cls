/**
 * @description ELECandidateIngredient
 * @ELECandidateIngredient
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 |                       | DEPP-8488              | Created file                 |
 */
public with sharing class ELECandidateIngredient {
    
    private ELCParser elcParser;
    private Contact contact;
    private List<hed__Program_Enrollment__c> programEnrollments;
    private List<hed__Course_Enrollment__c> courseEnrollments;
    private List<Course_Connection_Assessment__c> courseConnectionAssessments;
    private List<Leave_of_Absence__c> leaveOfAbsences;
    private List<Completed_Cadence__c> completedCadences;
    private List<Program_Enrollment_Breach__c> programEnrollmentBreaches;
    
    // Getter and setter for ELCParser
    public ELCParser getELCParser() {
        return elcParser;
    }
    
    public void setELCParser(ELCParser elcParser) {
        this.elcParser = elcParser;
    }
    
    // Getter and setter for contact
    public Contact getContact() {
        return contact;
    }
    
    public void setContact(Contact contact) {
        this.contact = contact;
    }
    
    // Getter and setter for programEnrollments
    public List<hed__Program_Enrollment__c> getProgramEnrollments() {
        return programEnrollments;
    }
    
    public void setProgramEnrollments(List<hed__Program_Enrollment__c> programEnrollments) {
        this.programEnrollments = programEnrollments;
    }
    
    // Getter and setter for courseEnrollments
    public List<hed__Course_Enrollment__c> getCourseEnrollments() {
        return courseEnrollments;
    }
    
    public void setCourseEnrollments(List<hed__Course_Enrollment__c> courseEnrollments) {
        this.courseEnrollments = courseEnrollments;
    }
    
    // Getter and setter for courseConnectionAssessments
    public List<Course_Connection_Assessment__c> getCourseConnectionAssessments() {
        return courseConnectionAssessments;
    }
    
    public void setCourseConnectionAssessments(List<Course_Connection_Assessment__c> courseConnectionAssessments) {
        this.courseConnectionAssessments = courseConnectionAssessments;
    }
    
    // Getter and setter for leaveOfAbsences
    public List<Leave_of_Absence__c> getLeaveOfAbsences() {
        return leaveOfAbsences;
    }
    
    public void setLeaveOfAbsences(List<Leave_of_Absence__c> leaveOfAbsences) {
        this.leaveOfAbsences = leaveOfAbsences;
    }
    
    // Getter and setter for completedCadences
    public List<Completed_Cadence__c> getCompletedCadences() {
        return completedCadences;
    }
    
    public void setCompletedCadences(List<Completed_Cadence__c> completedCadences) {
        this.completedCadences = completedCadences;
    }
    
    // Getter and setter for programEnrollmentBreaches
    public List<Program_Enrollment_Breach__c> getProgramEnrollmentBreaches() {
        return programEnrollmentBreaches;
    }
    
    public void setProgramEnrollmentBreaches(List<Program_Enrollment_Breach__c> programEnrollmentBreaches) {
        this.programEnrollmentBreaches = programEnrollmentBreaches;
    }
}