/**
 * @description Test class for Engagement List Event Candidate Process Result
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 |  May 17, 2024         | DEPP-8484              | Created file                 |
 */
@isTest
public with sharing class ELECandidateProcessResultTest {

    @isTest
    static void processCreateEventTest() {   
        Test.startTest();
        ELECandidateProcessResult processResult = new ELECandidateProcessResult(new Engagement_List_Event__c(), ELECandidateProcessResult.Outcome.CASE_CREATED);
        Test.stopTest();

        System.assert(processResult.getEngagementListEvent() != null, 'Event should not be null.');  
        System.assertEquals(ELECandidateProcessResult.Outcome.CASE_CREATED, processResult.getResult(), 'Event should not be null.');  
    }
}