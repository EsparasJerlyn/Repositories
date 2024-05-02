/**
 * @description Class to be used in parsing Engagement_List_Criteria__c for outreach case
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eccarius.munoz                 | April 29, 2024        | DEPP-8041              | Created file                                                |
      |                                |                       |                        | Added criterion methods for the ff:                         |
      |                                |                       |                        | 1. citizenshipStatus                                        |
      |                                |                       |                        | 2. academicStatus                                           |
      |                                |                       |                        | 3. cadenceName                                              |
      |                                |                       |                        | Added hidden criteria methods for the ff:                   |
      |                                |                       |                        | 1. Contact                                                  |
      |                                |                       |                        | 2. Program Enrollment                                       |
      |                                |                       |                        | 3. Completed Cadence                                        |
      | julie.jane.alegre              | April 29, 2024        | DEPP-8041              | Added hidden criteria methods for the ff:                   |
      |                                |                       |                        | 1. Course Connection Assessment                             |
      |                                |                       |                        | 2. Program Enrollment Breach                                |
      | eccarius.munoz                 | April 30, 2024        | DEPP-8041              | Added getter methods                                        |
*/
public with sharing class ELCParser {

    private Engagement_List_Criteria__c engagementListCriteria;
    private Date executionDate;

    private ELCContactParser eLCContactParser;
    private ELCProgramEnrollmentParser eLCProgramEnrollmentParser;
    private ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria;
    private CompletedCadencesDAO.Criteria completedCadenceCriteria;
    private CourseConnectionsDAO.Criteria courseConnectionCriteria;
    private CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria;
    private ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria;
    private LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria;   

    public ELCParser(Engagement_List_Criteria__c engagementListCriteria, Date executionDate) {
        this.engagementListCriteria = engagementListCriteria;
        this.executionDate = executionDate;
        parse();
    }

    private void parse() {
        eLCContactParser = new ELCContactParser(engagementListCriteria, executionDate);
        eLCProgramEnrollmentParser = new ELCProgramEnrollmentParser(engagementListCriteria, executionDate);
        completedCadenceCriteria = ELCCompletedCadenceParser.processCompletedCadenceCriteria(engagementListCriteria, completedCadenceCriteria);
        courseConnectionCriteria = ELCCourseConnectionParser.processCourseConnectionCriteria(engagementListCriteria, courseConnectionCriteria);
        programEnrollmentBreachCriteria = processBreachName(engagementListCriteria, programEnrollmentBreachCriteria);
        courseConnectionAssessmentCriteria = processFailedToSubmitAssessment(engagementListCriteria, courseConnectionAssessmentCriteria);
        courseConnectionAssessmentCriteria = processAssessmentPriority(engagementListCriteria, courseConnectionAssessmentCriteria);
        leaveOfAbsenceCriteria = processLeaveOfAbsenceIsOnLeave(engagementListCriteria, leaveOfAbsenceCriteria);

        if(engagementListCriteria.Key_Date__c != null){
            if(engagementListCriteria.Key_Date__c == 'Leave of Absence End Date'){ //declare to engagement list criteria dao
                leaveOfAbsenceCriteria = processLeaveOfAbsenceKeyDate(engagementListCriteria, leaveOfAbsenceCriteria);
            } else if(engagementListCriteria.Key_Date__c == 'Completed Cadence Date'){ //declare to engagement list criteria dao
                completedCadenceCriteria = processCompletedCadenceKeyDate(engagementListCriteria, completedCadenceCriteria);
            } else if(engagementListCriteria.Key_Date__c == 'Breach Start Date'){ //declare to engagement list criteria dao
                programEnrollmentBreachCriteria = processProgramEnrollmentBreachKeyDate(engagementListCriteria, programEnrollmentBreachCriteria);
            } 
            //add others
        }

        applyProgramEnrollmentBreachHiddenCriteria(this.programEnrollmentBreachCriteria);
        // similar for other sObjects
    }

    /**
     * Hidden criterias for each sObjects
     */ 
    
    // Completed Cadence
    

    // Course Connection
    

    // Program Enrollment Breach
    private ProgramEnrollmentBreachesDAO.Criteria applyProgramEnrollmentBreachHiddenCriteria(ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria) {
        if (programEnrollmentBreachCriteria == null) {
            programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
        }
        programEnrollmentBreachCriteria.breachStatus = ProgramEnrollmentBreachesDAO.STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH;

        return programEnrollmentBreachCriteria;
    }
    
    /**************************************************************
     * Criterions
     */

    

    private CourseConnectionAssessmentsDAO.Criteria processFailedToSubmitAssessment(Engagement_List_Criteria__c engagementListCriteria, CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria) {
        if (engagementListCriteria.Failed_To_Submit_Assessment__c != null) {
            if (courseConnectionAssessmentCriteria == null) {
                courseConnectionAssessmentCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            }
            if(engagementListCriteria.Failed_To_Submit_Assessment__c == 'Yes'){
                courseConnectionAssessmentCriteria.assessmentGrade = null;
                courseConnectionAssessmentCriteria.submissionDate = null;
            }
            
        }
        return courseConnectionAssessmentCriteria;
    }

    private CourseConnectionAssessmentsDAO.Criteria processAssessmentPriority(Engagement_List_Criteria__c engagementListCriteria, CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria) {
        if (engagementListCriteria.Assessment_Priority__c != null) {
            if (courseConnectionAssessmentCriteria == null) {
                courseConnectionAssessmentCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            }
            courseConnectionAssessmentCriteria.assessmentPriority = engagementListCriteria.Assessment_Priority__c;
        }
        return courseConnectionAssessmentCriteria;
    }


    private ProgramEnrollmentBreachesDAO.Criteria processBreachName(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria) {
        if (engagementListCriteria.Breach__c != null) {
            if (programEnrollmentBreachCriteria == null) {
                programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
            }
            programEnrollmentBreachCriteria.breach = engagementListCriteria.Breach__c;
        }
        return programEnrollmentBreachCriteria;
    }

    private LeaveOfAbsencesDAO.Criteria processLeaveOfAbsenceIsOnLeave(Engagement_List_Criteria__c engagementListCriteria, LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria) {
        if (engagementListCriteria.Is_On_Leave_of_Absence__c != null) {
            if (leaveOfAbsenceCriteria == null) {
                leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
            }
            if (engagementListCriteria.Is_On_Leave_of_Absence__c == 'Yes') {
                leaveOfAbsenceCriteria.isOnLeave = true;
            } else {
                leaveOfAbsenceCriteria.isOnLeave = false;
            }
        }
        return leaveOfAbsenceCriteria;
    }   
    
    /**
     * Criterions with Key Dates
     */
    private LeaveOfAbsencesDAO.Criteria processLeaveOfAbsenceKeyDate(Engagement_List_Criteria__c engagementListCriteria, LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria) {
        if (leaveOfAbsenceCriteria == null) {
            leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
        }

        leaveOfAbsenceCriteria.keyDateOffset = Integer.valueOf(engagementListCriteria.Key_Date_Offset__c);
        leaveOfAbsenceCriteria.executionDate = this.executionDate;

        return leaveOfAbsenceCriteria;
    }

    private CompletedCadencesDAO.Criteria processCompletedCadenceKeyDate(Engagement_List_Criteria__c engagementListCriteria, CompletedCadencesDAO.Criteria completedCadenceCriteria) {
        if (completedCadenceCriteria == null) {
            completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
        }

        completedCadenceCriteria.keyDateOffset = Integer.valueOf(engagementListCriteria.Key_Date_Offset__c);
        completedCadenceCriteria.executionDate = this.executionDate;

        return completedCadenceCriteria;
    }

    private ProgramEnrollmentBreachesDAO.Criteria processProgramEnrollmentBreachKeyDate(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria) {
        if (programEnrollmentBreachCriteria == null) {
            programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
        }

        programEnrollmentBreachCriteria.keyDateOffset = Integer.valueOf(engagementListCriteria.Key_Date_Offset__c);
        programEnrollmentBreachCriteria.executionDate = this.executionDate;

        return programEnrollmentBreachCriteria;
    }

    /**
     * Getter methods
     */
    public ELCContactParser getELCContactParser() {
        return eLCContactParser;
    }
    
    public ELCProgramEnrollmentParser getELCProgramEnrollmentParser(){
        return eLCProgramEnrollmentParser;
    }

    public CompletedCadencesDAO.Criteria getCompletedCadenceCriteria() {
        return completedCadenceCriteria;
    }
    
    public CourseConnectionsDAO.Criteria getCourseConnectionCriteria() {
        return courseConnectionCriteria;
    }

    public CourseConnectionAssessmentsDAO.Criteria getCourseConnectionAssessmentCriteria() {
        return courseConnectionAssessmentCriteria;
    }

    public ProgramEnrollmentBreachesDAO.Criteria getProgramEnrollmentBreachCriteria() {
        return programEnrollmentBreachCriteria;
    }

    public LeaveOfAbsencesDAO.Criteria getLeaveOfAbsencesCriteria() {
        return leaveOfAbsenceCriteria;
    }

}
