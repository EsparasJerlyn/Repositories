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

    private ContactsDAO.Criteria contactCriteria;
    private ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria;
    private CompletedCadencesDAO.Criteria completedCadenceCriteria;
    private CourseConnectionsDAO.Criteria courseConnectionCriteria;
    private CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria;
    private ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria;
    private LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria;   
    
    //.... and other DAO.Criteria

    public ELCParser(Engagement_List_Criteria__c engagementListCriteria, Date executionDate) {
        this.engagementListCriteria = engagementListCriteria;
        this.executionDate = executionDate;
        parse();
    }

    private void parse() {

        // process other criterion fields;
        this.contactCriteria = processCitizenshipStatus(this.engagementListCriteria, this.contactCriteria);
        this.programEnrollmentCriteria = processAcademicStatus(this.engagementListCriteria, this.programEnrollmentCriteria);
        this.completedCadenceCriteria = processCadenceName(this.engagementListCriteria, this.completedCadenceCriteria);
        this.courseConnectionCriteria = processCourseConnectionCourseGrade(this.engagementListCriteria, this.courseConnectionCriteria);
        this.programEnrollmentBreachCriteria = processBreachName(this.engagementListCriteria, this.programEnrollmentBreachCriteria);
        this.courseConnectionAssessmentCriteria = processFailedToSubmitAssessment(this.engagementListCriteria, this.courseConnectionAssessmentCriteria);
        this.courseConnectionAssessmentCriteria = processAssessmentPriority(this.engagementListCriteria, this.courseConnectionAssessmentCriteria);
        this.leaveOfAbsenceCriteria = processleaveOfAbsenceIsOnLeave(this.engagementListCriteria, this.leaveOfAbsenceCriteria);

        if(this.engagementListCriteria.Key_Date__c != null){
            if(this.engagementListCriteria.Key_Date__c == 'Leave of Absence End Date'){ //declare to engagement list criteria dao
                this.leaveOfAbsenceCriteria = processLeaveOfAbsenceKeyDate(this.engagementListCriteria, this.leaveOfAbsenceCriteria);
            } else if(this.engagementListCriteria.Key_Date__c == 'Completed Cadence Date'){ //declare to engagement list criteria dao
                this.completedCadenceCriteria = processCompletedCadenceKeyDate(this.engagementListCriteria, this.completedCadenceCriteria);
            } 
            //add others
        }

        applyContactHiddenCriteria(this.contactCriteria);
        applyProgramEnrollmentHiddenCriteria(this.programEnrollmentCriteria);
        applyCompletedCadenceHiddenCriteria(this.completedCadenceCriteria);
        applyCourseConnectionHiddenCriteria(this.courseConnectionCriteria);
        applyProgramEnrollmentBreachHiddenCriteria(this.programEnrollmentBreachCriteria);
        // similar for other sObjects
    }

    /**
     * Hidden criterias for each sObjects
     */ 
    
    //Contact
    private ContactsDAO.Criteria applyContactHiddenCriteria(ContactsDAO.Criteria contactCriteria) {
        if (contactCriteria == null) {
            contactCriteria = new ContactsDAO.Criteria();
        }
        contactCriteria.recordType = ContactsDAO.PERSON_RECORDTYPE;
        contactCriteria.isQUTStudent = true;
        return contactCriteria;
    }

    // Program Enrollment
    private ProgramEnrollmentsDAO.Criteria applyProgramEnrollmentHiddenCriteria(ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria) {
        if (programEnrollmentCriteria == null) {
            programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
        }
        programEnrollmentCriteria.enrollmentStage = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
        programEnrollmentCriteria.enrollmentStatus = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_FOR_OUTREACH;

        return programEnrollmentCriteria;
    }

    // Completed Cadence
    private CompletedCadencesDAO.Criteria applyCompletedCadenceHiddenCriteria(CompletedCadencesDAO.Criteria completedCadenceCriteria) {
        if (completedCadenceCriteria == null) {
            completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
        }
        completedCadenceCriteria.status = CompletedCadencesDAO.SUCCESSFUL_STATUS;

        return completedCadenceCriteria;
    }

    // Course Connection
    private CourseConnectionsDAO.Criteria applyCourseConnectionHiddenCriteria(CourseConnectionsDAO.Criteria courseConnectionCriteria) {
        if (courseConnectionCriteria == null) {
            courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
        }
        courseConnectionCriteria.status = CourseConnectionsDAO.ENROLLMENT_STATUS_FOR_OUTREACH;

        return courseConnectionCriteria;
    }

    // Program Enrollment Breach
    private ProgramEnrollmentBreachesDAO.Criteria applyProgramEnrollmentBreachHiddenCriteria(ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria) {
        if (programEnrollmentBreachCriteria == null) {
            programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
        }
        programEnrollmentBreachCriteria.breachStatus = ProgramEnrollmentBreachesDAO.ACTIVE_BREACH_STATUS;

        return programEnrollmentBreachCriteria;
    }
    
    /**************************************************************
     * Criterions
     */
    private ContactsDAO.Criteria processCitizenshipStatus(Engagement_List_Criteria__c engagementListCriteria, ContactsDAO.Criteria contactCriteria){
        if (engagementListCriteria.Citizenship_Status__c != null) {
            if (contactCriteria == null) {
                contactCriteria = new ContactsDAO.Criteria();
            }
            contactCriteria.citizenshipStatus = engagementListCriteria.Citizenship_Status__c;
        }
        return contactCriteria;
    }

    private ProgramEnrollmentsDAO.Criteria processAcademicStatus(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria) {
        if (engagementListCriteria.Academic_Status__c != null) {
            if (programEnrollmentCriteria == null) {
                programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            }
            programEnrollmentCriteria.academicStatus = engagementListCriteria.Academic_Status__c;
        }
        return programEnrollmentCriteria;
    }
    //Not sure if this is Program Plan related in Program Enrollment????
    private ProgramEnrollmentsDAO.Criteria processCategoryType(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria) {
        if (engagementListCriteria.Category_Type__c != null) {
            if (programEnrollmentCriteria == null) {
                programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            }
            programEnrollmentCriteria.categoryType = engagementListCriteria.Category_Type__c;
        }
        return programEnrollmentCriteria;
    }

    private CompletedCadencesDAO.Criteria processCadenceName(Engagement_List_Criteria__c engagementListCriteria, CompletedCadencesDAO.Criteria completedCadenceCriteria) {
        if (engagementListCriteria.Completed_Cadence__c != null) {
            if (completedCadenceCriteria == null) {
                completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
            }
            completedCadenceCriteria.completedCadence = engagementListCriteria.Completed_Cadence__c;
        }
        return completedCadenceCriteria;
    }

    private CourseConnectionsDAO.Criteria processCourseConnectionCourseGrade(Engagement_List_Criteria__c engagementListCriteria, CourseConnectionsDAO.Criteria courseGradeCriteria) {
        if (engagementListCriteria.Course_Grade__c != null) {
            if (courseGradeCriteria == null) {
                courseGradeCriteria = new CourseConnectionsDAO.Criteria();
            }
            courseGradeCriteria.courseGrade = engagementListCriteria.Course_Grade__c;
        }
        return courseGradeCriteria;
    }

    private CourseConnectionAssessmentsDAO.Criteria processFailedToSubmitAssessment(Engagement_List_Criteria__c engagementListCriteria, CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria) {
        if (engagementListCriteria.Failed_To_Submit_Assessment__c != null) {
            if (courseConnectionAssessmentCriteria == null) {
                courseConnectionAssessmentCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            }
            courseConnectionAssessmentCriteria.assessmentGrade = null;
            courseConnectionAssessmentCriteria.submissionDate = null;
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
            programEnrollmentBreachCriteria.breachName = engagementListCriteria.Breach__c;
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

    /**
     * Getter methods
     */
    public ContactsDAO.Criteria getContactCriteria() {
        return contactCriteria;
    }

    public ProgramEnrollmentsDAO.Criteria getProgramEnrollmentCriteria() {
        return programEnrollmentCriteria;
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
