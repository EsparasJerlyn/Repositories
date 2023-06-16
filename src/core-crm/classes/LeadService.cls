/**
 * @description Helper class for updating the Lead Status of Lead Type = Learner
 * 
 * @see LeadTriggerHandler
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------|
 *    | mark.j.mahilum                 | June 08,2023          | DEPP-5798              | Created File                  | 
 */
public with sharing class LeadService {
                                                                
    public static void updateLearnerLeadStatus(List<Lead> newItems, Map<Id, Lead> oldItems) {        
        for (Lead lead : newItems) {            
            if (String.isNotBlank(lead.Lead_Type__c) && lead.Lead_Type__c == 'Learner') {
                if (isLeadScoreNullOrUnderFifty(lead)) {
                    lead.Status = 'New';
                } else if (isLeadScoreInRange(lead, 50, 100)) {
                    lead.Status = 'Engaging';
                } else {
                    lead.Status = isLeadScoreGreaterThanOrEqual(lead, 100) ? 'Nurturing' : 'Qualified';
                }
            }
        }
    }

    private static Boolean isLeadScoreNullOrUnderFifty(Lead lead) {
        return !lead.IsConverted && (lead.Lead_Score__c == null || lead.Lead_Score__c < 50);
    }

    private static Boolean isLeadScoreInRange(Lead lead, Integer minScore, Integer maxScore) {
        return !lead.IsConverted && lead.Lead_Score__c >= minScore && lead.Lead_Score__c < maxScore;
    }

    private static Boolean isLeadScoreGreaterThanOrEqual(Lead lead, Integer score) {
        return !lead.IsConverted && lead.Lead_Score__c >= score;
    }
}