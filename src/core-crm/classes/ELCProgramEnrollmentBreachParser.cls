/**
 * @description Class to be used in parsing Engagement_List_Criteria__c to program enrollment breach criteria
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-8041              | Created file                                                |
*/
public with sharing class ELCProgramEnrollmentBreachParser {
    private Engagement_List_Criteria__c engagementListCriteria;
    private Date executionDate;

    private ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria;

    public ELCProgramEnrollmentBreachParser(Engagement_List_Criteria__c engagementListCriteria, Date executionDate) {
        this.engagementListCriteria = engagementListCriteria;
        this.executionDate = executionDate;
        parse();
    }

    private void parse() {
        programEnrollmentBreachCriteria = processBreachName(engagementListCriteria, programEnrollmentBreachCriteria);
        programEnrollmentBreachCriteria = applyProgramEnrollmentBreachHiddenCriteria(programEnrollmentBreachCriteria);
        programEnrollmentBreachCriteria = processLeaveOfAbsenceKeyDateOffsets(engagementListCriteria, programEnrollmentBreachCriteria);
    }

    //configurable criteria
    private ProgramEnrollmentBreachesDAO.Criteria processBreachName(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria) {
        if (engagementListCriteria.Breach__c != null) {
            if (programEnrollmentBreachCriteria == null) {
                programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
            }
            programEnrollmentBreachCriteria.setBreach(engagementListCriteria.Breach__c);
        }
        return programEnrollmentBreachCriteria;
    }

    private ProgramEnrollmentBreachesDAO.Criteria processLeaveOfAbsenceKeyDateOffsets(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria) {
        if (
            this.executionDate != null
            && engagementListCriteria.Key_Date__c == 'Breach Start Date'
            && engagementListCriteria.Key_Date_Offset_Lower_Boundary__c != null
            && engagementListCriteria.Key_Date_Offset_Upper_Boundary__c != null
        ) {
            if (programEnrollmentBreachCriteria == null) {
                programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
            }
            programEnrollmentBreachCriteria.setBreachDateFrom(DynamicQueryService.calculateDateOffset(this.executionDate, Integer.ValueOf(engagementListCriteria.Key_Date_Offset_Lower_Boundary__c)));
            programEnrollmentBreachCriteria.setBreachDateTo(DynamicQueryService.calculateDateOffset(this.executionDate, Integer.ValueOf(engagementListCriteria.Key_Date_Offset_Upper_Boundary__c)));
        }
        return programEnrollmentBreachCriteria;
    }

    //hidden criteria
    private ProgramEnrollmentBreachesDAO.Criteria applyProgramEnrollmentBreachHiddenCriteria(ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria) {
        if (programEnrollmentBreachCriteria == null) {
            programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
        }
        programEnrollmentBreachCriteria.setBreachStatus(ProgramEnrollmentBreachesDAO.STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH);

        return programEnrollmentBreachCriteria;
    }

    public ProgramEnrollmentBreachesDAO.Criteria getProgramEnrollmentBreachCriteria() {
        return programEnrollmentBreachCriteria;
    }

}