/**
 * @description Class to be used in parsing Engagement_List_Criteria__c to Completed Cadence criteria
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-8041              | Created file                                                |
*/
public with sharing class ELCCompletedCadenceParser {

    private Engagement_List_Criteria__c engagementListCriteria;
    private Date executionDate;

    private CompletedCadencesDAO.Criteria completedCadenceCriteria;

    public ELCCompletedCadenceParser(Engagement_List_Criteria__c engagementListCriteria, Date executionDate) {
        this.engagementListCriteria = engagementListCriteria;
        this.executionDate = executionDate;
        parse();
    }

    private void parse() {
        completedCadenceCriteria = processCadenceName(engagementListCriteria, completedCadenceCriteria);
        completedCadenceCriteria = applyCompletedCadenceHiddenCriteria(completedCadenceCriteria);
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

    private CompletedCadencesDAO.Criteria applyCompletedCadenceHiddenCriteria(CompletedCadencesDAO.Criteria completedCadenceCriteria) {
        if (completedCadenceCriteria == null) {
            completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
        }
        completedCadenceCriteria.status = CompletedCadencesDAO.SUCCESSFUL_STATUS;

        return completedCadenceCriteria;
    }
    
    public CompletedCadencesDAO.Criteria getCompletedCadenceCriteria() {
        return completedCadenceCriteria;
    }
}