/**
 * @description Model class for Engagement List Event Candidate Process Result
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 14, 2024         | DEPP-8484              | Created file                 |
 */
public with sharing class ELECandidateProcessResult {

    private Engagement_List_Event__c engagementListEvent;
    private Outcome result;

    public ELECandidateProcessResult(Engagement_List_Event__c engagementListEvent, Outcome result){
        this.engagementListEvent = engagementListEvent;
        this.result = result;
    }

    public enum Outcome {
        CASE_CREATED,
        EVENT_CREATED,
        EVENT_NOT_CREATED
    }

    public Outcome getResult(){
        return result;
    }

    public void setResult(Outcome result){
        this.result = result;
    }

    public Engagement_List_Event__c getEngagementListEvent(){
        return engagementListEvent;
    }

    public void setEngagementListEvent(Engagement_List_Event__c engagementListEvent){
        this.engagementListEvent = engagementListEvent;
    }

}