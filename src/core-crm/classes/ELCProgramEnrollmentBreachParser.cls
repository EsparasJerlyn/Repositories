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

    private ProgramEnrollmentBreachesDAO.Criteria applyProgramEnrollmentBreachHiddenCriteria(ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria) {
        if (programEnrollmentBreachCriteria == null) {
            programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
        }
        programEnrollmentBreachCriteria.breachStatus = ProgramEnrollmentBreachesDAO.STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH;

        return programEnrollmentBreachCriteria;
    }

    private ProgramEnrollmentBreachesDAO.Criteria processProgramEnrollmentBreachKeyDate(Engagement_List_Criteria__c engagementListCriteria, ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria) {
        if (programEnrollmentBreachCriteria == null) {
            programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
        }

        programEnrollmentBreachCriteria.keyDateOffset = Integer.valueOf(engagementListCriteria.Key_Date_Offset__c);
        programEnrollmentBreachCriteria.executionDate = this.executionDate;

        return programEnrollmentBreachCriteria;
    }

    public ProgramEnrollmentBreachesDAO.Criteria getProgramEnrollmentBreachCriteria() {
        return programEnrollmentBreachCriteria;
    }

}