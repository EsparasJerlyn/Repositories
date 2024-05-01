/**
 * @description Class to be used in parsing Engagement_List_Criteria__c for outreach case
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | eccarius.munoz                 | May 1, 2024           | DEPP-8041              | Created file                                                |
*/
public with sharing class ELCEvaluationJob {
    private Engagement_List_Criteria__c criteria;
    private Date executionDate;

    public ELCEvaluationJob(Engagement_List_Criteria__c criteria, Date executionDate){
        this.criteria = criteria;
        this.executionDate = executionDate;
    }

    public Engagement_List_Criteria__c getCriteria(){
        return criteria;
    }

    public Date getExecutionDate(){
        return executionDate;
    }
}