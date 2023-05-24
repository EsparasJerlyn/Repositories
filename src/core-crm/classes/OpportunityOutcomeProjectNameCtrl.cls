/**
 * @description Control for auto-generating project name for opportunity outcome records
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 15, 2023          | DEPP-5594              | created file
 */
public with sharing class OpportunityOutcomeProjectNameCtrl {
	public static void generateProjectName(List<Opportunity_Outcome__c> newItems) {
        Map<Id, String> recordTypeToPrefixMap = new Map<Id, String>();
        recordTypeToPrefixMap.put(OpportunityOutcomesDAO.RT_OPPTYOC_RPP_ID, 'RPP');
        recordTypeToPrefixMap.put(OpportunityOutcomesDAO.RT_OPPTYOC_INP_ID, 'INP');
        recordTypeToPrefixMap.put(OpportunityOutcomesDAO.RT_OPPTYOC_RCP_ID, 'RCP');
        recordTypeToPrefixMap.put(OpportunityOutcomesDAO.RT_OPPTYOC_RCC_ID, 'RCC');
        Set<Id> opptyIdSet = getOpptyIdsFromOpptyOutcomes(newItems);
        Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>([SELECT Id, Name FROM Opportunity WHERE Id IN :opptyIdSet]);
        for(Opportunity_Outcome__c newItem : newItems) {
            if(recordTypeToPrefixMap.containsKey(newItem.RecordTypeId)){
                newItem.Project_Name__c = recordTypeToPrefixMap.get(newItem.RecordTypeId) + opptyMap.get(newItem.Opportunity__c).Name.substring(3);
            }
        }
    }
    
    private static Set<Id> getOpptyIdsFromOpptyOutcomes(List<Opportunity_Outcome__c> opptyOutcomeList) {
        Set<Id> opptyIdSet = new Set<Id>();
        for(Opportunity_Outcome__c opptyOutcome : opptyOutcomeList) {
            if(!String.isBlank(opptyOutcome.Opportunity__c)) {
                opptyIdSet.add(opptyOutcome.Opportunity__c);
            }
        }
        return opptyIdSet;
    }
}