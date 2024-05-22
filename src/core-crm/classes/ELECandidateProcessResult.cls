/**
 * @description Model class for Engagement List Event Candidate Process Result
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 14, 2024         | DEPP-8484              | Created file                 |
      | kim.howard.capanas             |  May 22, 2024         | DEPP-7526              | Added Case to constructor    |
 */
public with sharing class ELECandidateProcessResult {

    private Engagement_List_Event__c engagementListEvent;
    private Outcome result;
    private Case caseRecord;

    public ELECandidateProcessResult(Engagement_List_Event__c engagementListEvent, Outcome result){
        this.engagementListEvent = engagementListEvent;
        this.result = result;
    }

    public ELECandidateProcessResult(Engagement_List_Event__c engagementListEvent, Outcome result, Case caseRecord){
        this.engagementListEvent = engagementListEvent;
        this.result = result;
        this.caseRecord = caseRecord;
    }

    public enum Outcome {
        CASE_CREATED,
        EVENT_CREATED,
        EVENT_NOT_CREATED
    }

    public Outcome getResult(){
        return result;
    }

    public Engagement_List_Event__c getEngagementListEvent(){
        return engagementListEvent;
    }

    public Case getCase(){
        return caseRecord;
    }

}