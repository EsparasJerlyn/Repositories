/**
 * @description Class to be used in parsing Engagement_List_Criteria__c to Program Enrollment criteria
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-8041              | Created file                                                |
*/
public with sharing class ELCProgramEnrollmentParser {

    private Engagement_List_Criteria__c engagementListCriteria;
    private Date executionDate;

    private ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria;

    public ELCProgramEnrollmentParser(Engagement_List_Criteria__c engagementListCriteria, Date executionDate) {
        this.engagementListCriteria = engagementListCriteria;
        this.executionDate = executionDate;
        parse();
    }

    private void parse() {
        programEnrollmentCriteria = processAcademicStatus(engagementListCriteria, programEnrollmentCriteria);
        programEnrollmentCriteria = processCategoryType(engagementListCriteria, programEnrollmentCriteria);
        programEnrollmentCriteria = applyProgramEnrollmentHiddenCriteria(programEnrollmentCriteria);
    }
    
    //configurable criteria
    private ProgramEnrollmentsDAO.Criteria processAcademicStatus(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria) {
        if (engagementListCriteria.Academic_Status__c != null) {
            if (programEnrollmentCriteria == null) {
                programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            }
            programEnrollmentCriteria.academicStatus = engagementListCriteria.Academic_Status__c;
        }
        return programEnrollmentCriteria;
    }

    private ProgramEnrollmentsDAO.Criteria processCategoryType(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria) {
        if (engagementListCriteria.Category_Type__c != null) {
            if (programEnrollmentCriteria == null) {
                programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            }
            programEnrollmentCriteria.categoryType = engagementListCriteria.Category_Type__c;
        }
        return programEnrollmentCriteria;
    }

    //hidden criteria
    private ProgramEnrollmentsDAO.Criteria applyProgramEnrollmentHiddenCriteria(ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria) {
        if (programEnrollmentCriteria == null) {
            programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
        }
        programEnrollmentCriteria.enrollmentStage = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
        programEnrollmentCriteria.enrollmentStatus = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_FOR_OUTREACH;

        return programEnrollmentCriteria;
    }

    public ProgramEnrollmentsDAO.Criteria getProgramEnrollmentCriteria() {
        return programEnrollmentCriteria;
    }
}