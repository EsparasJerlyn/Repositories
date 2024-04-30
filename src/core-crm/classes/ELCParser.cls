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
      |                                |                       |                        | 2. Program Enrollment Breach                                |                                             |
      */
public with sharing class ELCParser {
    private Engagement_List_Criteria__c engagementListCriteria;
    private Date executionDate;

    private ContactsDAO.Criteria contactCriteria;
    private ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria;
    private CompletedCadencesDAO.Criteria completedCadenceCriteria;
    private CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria;
    private ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria;
    
    //.... and other DAO.Criteria

    public ELCParser(Engagement_List_Criteria__c engagementListCriteria, Date executionDate) {
        this.engagementListCriteria = engagementListCriteria;
        this.executionDate = executionDate;
        parse();
    }

    private void parse() {
        contactCriteria = processCitizenshipStatus(engagementListCriteria, contactCriteria);
        programEnrollmentCriteria = processAcademicStatus(engagementListCriteria, programEnrollmentCriteria);
        completedCadenceCriteria = processCadenceName(engagementListCriteria, completedCadenceCriteria);
        programEnrollmentBreachCriteria = processBreachName(engagementListCriteria, programEnrollmentBreachCriteria);
        courseConnectionAssessmentCriteria = processFailedToSubmitAssessment(engagementListCriteria, courseConnectionAssessmentCriteria);
        courseConnectionAssessmentCriteria = processAssessmentPriority(engagementListCriteria, courseConnectionAssessmentCriteria);

        // process other criterion fields;

        applyContactHiddenCriteria(contactCriteria);
        applyProgramEnrollmentHiddenCriteria(programEnrollmentCriteria);
        applyCompletedCadenceHiddenCriteria(completedCadenceCriteria);
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
        contactCriteria.recordType = ContactsDAO.PERSON_RECORDTYPE_ID;
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
}
