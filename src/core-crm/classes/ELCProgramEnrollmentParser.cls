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

    public static final Set<String> ENROLLMENT_STATUS_FOR_OUTREACH = new Set<String>{
        ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED,
        ProgramEnrollmentsDAO.ENROLLMENT_STATUS_LEAVE_OF_ABSENCE
    };

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
        programEnrollmentCriteria = processProgramEnrollmentKeyDateOffsets(engagementListCriteria, programEnrollmentCriteria);
        if(programEnrollmentCriteria != null && !programEnrollmentCriteria.isEmpty()){
            programEnrollmentCriteria = applyProgramEnrollmentHiddenCriteria(programEnrollmentCriteria);
        }
    }
    
    //configurable criteria
    private ProgramEnrollmentsDAO.Criteria processAcademicStatus(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria) {
        if (engagementListCriteria.Academic_Status__c != null) {
            if (programEnrollmentCriteria == null) {
                programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            }
            programEnrollmentCriteria.setAcademicStatus(engagementListCriteria.Academic_Status__c);
        }
        return programEnrollmentCriteria;
    }

    private ProgramEnrollmentsDAO.Criteria processProgramEnrollmentKeyDateOffsets(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentsDAO.Criteria programEnrollmentsCriteria) {
        if (
            this.executionDate != null
            && engagementListCriteria.Key_Date__c == 'Academic Status Date'
            && engagementListCriteria.Key_Date_Offset_Lower_Boundary__c != null
            && engagementListCriteria.Key_Date_Offset_Upper_Boundary__c != null
        ) {
            if (programEnrollmentsCriteria == null) {
                programEnrollmentsCriteria = new ProgramEnrollmentsDAO.Criteria();
            }
            
            programEnrollmentsCriteria.setAcademicStatusDateFrom(this.executionDate.addDays(Integer.ValueOf(engagementListCriteria.Key_Date_Offset_Lower_Boundary__c)));
            programEnrollmentsCriteria.setAcademicStatusDateTo(this.executionDate.addDays(Integer.ValueOf(engagementListCriteria.Key_Date_Offset_Upper_Boundary__c)));
        }
        return programEnrollmentsCriteria;
    }

    private ProgramEnrollmentsDAO.Criteria processCategoryType(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria) {
        if (engagementListCriteria.Category_Type__c != null) {
            if (programEnrollmentCriteria == null) {
                programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            }
            programEnrollmentCriteria.setCategoryType(engagementListCriteria.Category_Type__c);
        }
        return programEnrollmentCriteria;
    }

    //hidden criteria
    private ProgramEnrollmentsDAO.Criteria applyProgramEnrollmentHiddenCriteria(ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria) {
        programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
        programEnrollmentCriteria.setEnrollmentStatus(ENROLLMENT_STATUS_FOR_OUTREACH);

        return programEnrollmentCriteria;
    }

    public ProgramEnrollmentsDAO.Criteria getProgramEnrollmentCriteria() {
        return programEnrollmentCriteria;
    }

    public Boolean isEmpty(){
        return programEnrollmentCriteria == null;
    }

}