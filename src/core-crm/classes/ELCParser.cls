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
      | eccarius.munoz                 | April 30, 2024        | DEPP-8041              | Added getter methods                                        |                                             |
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
    
    //.... and other DAO.Criteria

    public ELCParser(Engagement_List_Criteria__c engagementListCriteria, Date executionDate) {
        this.engagementListCriteria = engagementListCriteria;
        this.executionDate = executionDate;
        parse();
    }

    private void parse() {
        this.contactCriteria = processCitizenshipStatus(engagementListCriteria, contactCriteria);
        this.programEnrollmentCriteria = processAcademicStatus(engagementListCriteria, programEnrollmentCriteria);
        this.completedCadenceCriteria = processCadenceName(engagementListCriteria, completedCadenceCriteria);
        this.courseConnectionCriteria = processCourseConnectionCourseGrade(engagementListCriteria, courseConnectionCriteria);
        this.programEnrollmentBreachCriteria = processBreachName(engagementListCriteria, programEnrollmentBreachCriteria);
        this.courseConnectionAssessmentCriteria = processFailedToSubmitAssessment(engagementListCriteria, courseConnectionAssessmentCriteria);
        this.courseConnectionAssessmentCriteria = processAssessmentPriority(engagementListCriteria, courseConnectionAssessmentCriteria);
        // process other criterion fields;

        applyContactHiddenCriteria(contactCriteria);
        applyProgramEnrollmentHiddenCriteria(programEnrollmentCriteria);
        applyCompletedCadenceHiddenCriteria(completedCadenceCriteria);
        applyCourseConnectionHiddenCriteria(courseConnectionCriteria);
        applyProgramEnrollmentBreachHiddenCriteria(programEnrollmentBreachCriteria);
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
    ContactsDAO.Criteria processCitizenshipStatus(Engagement_List_Criteria__c engagementListCriteria, ContactsDAO.Criteria contactCriteria){
        if (engagementListCriteria.Citizenship_Status__c != null) {
            if (contactCriteria == null) {
                contactCriteria = new ContactsDAO.Criteria();
            }
            contactCriteria.citizenshipStatus = engagementListCriteria.Citizenship_Status__c;
        }
        return contactCriteria;
    }

    ProgramEnrollmentsDAO.Criteria processAcademicStatus(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria) {
        if (engagementListCriteria.Academic_Status__c != null) {
            if (programEnrollmentCriteria == null) {
                programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            }
            programEnrollmentCriteria.academicStatus = engagementListCriteria.Academic_Status__c;
        }
        return programEnrollmentCriteria;
    }

    CompletedCadencesDAO.Criteria processCadenceName(Engagement_List_Criteria__c engagementListCriteria, CompletedCadencesDAO.Criteria completedCadenceCriteria) {
        if (engagementListCriteria.Completed_Cadence__c != null) {
            if (completedCadenceCriteria == null) {
                completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
            }
            completedCadenceCriteria.completedCadence = engagementListCriteria.Completed_Cadence__c;
        }
        return completedCadenceCriteria;
    }

    CourseConnectionsDAO.Criteria processCourseConnectionCourseGrade(Engagement_List_Criteria__c engagementListCriteria, CourseConnectionsDAO.Criteria courseGradeCriteria) {
        if (engagementListCriteria.Course_Grade__c != null) {
            if (courseGradeCriteria == null) {
                courseGradeCriteria = new CourseConnectionsDAO.Criteria();
            }
            courseGradeCriteria.courseGrade = engagementListCriteria.Course_Grade__c;
        }
        return courseGradeCriteria;
    }

    CourseConnectionAssessmentsDAO.Criteria processFailedToSubmitAssessment(Engagement_List_Criteria__c engagementListCriteria, CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria) {
        if (engagementListCriteria.Failed_To_Submit_Assessment__c != null) {
            if (courseConnectionAssessmentCriteria == null) {
                courseConnectionAssessmentCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            }
            courseConnectionAssessmentCriteria.assessmentGrade = null;
            courseConnectionAssessmentCriteria.submissionDate = null;
        }
        return courseConnectionAssessmentCriteria;
    }

    CourseConnectionAssessmentsDAO.Criteria processAssessmentPriority(Engagement_List_Criteria__c engagementListCriteria, CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria) {
        if (engagementListCriteria.Assessment_Priority__c != null) {
            if (courseConnectionAssessmentCriteria == null) {
                courseConnectionAssessmentCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            }
            courseConnectionAssessmentCriteria.assessmentName = engagementListCriteria.Assessment_Priority__c;
        }
        return courseConnectionAssessmentCriteria;
    }


    ProgramEnrollmentBreachesDAO.Criteria processBreachName(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria) {
        if (engagementListCriteria.Breach__c != null) {
            if (programEnrollmentBreachCriteria == null) {
                programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
            }
            programEnrollmentBreachCriteria.breachName = engagementListCriteria.Breach__c;
        }
        return programEnrollmentBreachCriteria;
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

}
