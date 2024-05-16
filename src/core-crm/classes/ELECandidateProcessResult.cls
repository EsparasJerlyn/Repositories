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

}