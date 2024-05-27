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
        completedCadenceCriteria = new CompletedCadencesDAO.Criteria();
        parse();
    }

    private void parse() {
        completedCadenceCriteria = processCadenceName(engagementListCriteria, completedCadenceCriteria);
        completedCadenceCriteria = processCompletedCadenceKeyDate(engagementListCriteria, completedCadenceCriteria);
        if(completedCadenceCriteria != null && !completedCadenceCriteria.isEmpty()){
            completedCadenceCriteria = applyCompletedCadenceHiddenCriteria(completedCadenceCriteria);
        }
    }
    
    //configurable criteria
    private CompletedCadencesDAO.Criteria processCadenceName(Engagement_List_Criteria__c engagementListCriteria, CompletedCadencesDAO.Criteria completedCadenceCriteria) {
        if (String.isNotBlank(engagementListCriteria.Completed_Cadence__c)) {
            completedCadenceCriteria.setCompletedCadence(engagementListCriteria.Completed_Cadence__c);
        }
        return completedCadenceCriteria;
    }

    private CompletedCadencesDAO.Criteria processCompletedCadenceKeyDate(Engagement_List_Criteria__c engagementListCriteria, CompletedCadencesDAO.Criteria completedCadenceCriteria) {
        Boolean isKeyDateValid = this.executionDate != null && engagementListCriteria.Key_Date__c == EngagementListCriteriasDAO.KEY_DATE_COMPLETED_CADENCE_DATE;
        if ( isKeyDateValid && engagementListCriteria.Key_Date_Offset_Lower_Boundary__c != null) {
            completedCadenceCriteria.setCompletedCadanceDateFrom(this.executionDate.addDays(-Integer.ValueOf(engagementListCriteria.Key_Date_Offset_Lower_Boundary__c)));
        }
        if ( isKeyDateValid && engagementListCriteria.Key_Date_Offset_Upper_Boundary__c != null) {
            completedCadenceCriteria.setCompletedCadanceDateTo(this.executionDate.addDays(-Integer.ValueOf(engagementListCriteria.Key_Date_Offset_Upper_Boundary__c)));
        }
        return completedCadenceCriteria;
    }

    //hidden criteria
    private CompletedCadencesDAO.Criteria applyCompletedCadenceHiddenCriteria(CompletedCadencesDAO.Criteria completedCadenceCriteria) {
        completedCadenceCriteria.setStatus(CompletedCadencesDAO.SUCCESSFUL_STATUS);
        return completedCadenceCriteria;
    }
    
    public CompletedCadencesDAO.Criteria getCompletedCadenceCriteria() {
        return completedCadenceCriteria;
    }
    
}