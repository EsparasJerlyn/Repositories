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
        programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
        parse();
    }

    private void parse() {
        programEnrollmentCriteria = processAcademicStatus(engagementListCriteria, programEnrollmentCriteria);
        programEnrollmentCriteria = processPreviousAcademicStatus(engagementListCriteria, programEnrollmentCriteria);
        programEnrollmentCriteria = processCategoryType(engagementListCriteria, programEnrollmentCriteria);        
        programEnrollmentCriteria = processProgramEnrollmentKeyDateOffsets(engagementListCriteria, programEnrollmentCriteria);
        if(programEnrollmentCriteria != null && !programEnrollmentCriteria.isEmpty()){
            programEnrollmentCriteria = applyProgramEnrollmentHiddenCriteria(programEnrollmentCriteria);
        }
    }
    
    //configurable criteria
    private ProgramEnrollmentsDAO.Criteria processAcademicStatus(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria) {
        if (String.isNotBlank(engagementListCriteria.Academic_Status__c)) {
            programEnrollmentCriteria.setAcademicStatus(engagementListCriteria.Academic_Status__c);
        }
        return programEnrollmentCriteria;
    }

    private ProgramEnrollmentsDAO.Criteria processPreviousAcademicStatus(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria) {
        if (String.isNotBlank(engagementListCriteria.Previous_Academic_Status__c)) {
            programEnrollmentCriteria.setPreviousAcademicStatus(engagementListCriteria.Previous_Academic_Status__c);
        }
        return programEnrollmentCriteria;
    }

    private ProgramEnrollmentsDAO.Criteria processProgramEnrollmentKeyDateOffsets(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria) {
        Boolean isKeyDateValid = this.executionDate != null && engagementListCriteria.Key_Date__c == 'Academic Status Date';
        if (isKeyDateValid && engagementListCriteria.Key_Date_Offset_Lower_Boundary__c != null) {
            programEnrollmentCriteria.setAcademicStatusDateFrom(this.executionDate.addDays(-Integer.ValueOf(engagementListCriteria.Key_Date_Offset_Lower_Boundary__c)));            
        }
        
        if (isKeyDateValid && engagementListCriteria.Key_Date_Offset_Upper_Boundary__c != null) {
            programEnrollmentCriteria.setAcademicStatusDateTo(this.executionDate.addDays(-Integer.ValueOf(engagementListCriteria.Key_Date_Offset_Upper_Boundary__c)));          
        }

        return programEnrollmentCriteria;
    }

    private ProgramEnrollmentsDAO.Criteria processCategoryType(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria) {
        if (String.isNotBlank(engagementListCriteria.Category_Type__c)) {
            programEnrollmentCriteria.setCategoryType(new List<String>(engagementListCriteria.Category_Type__c.split(';')));
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

}