/**
 * @description Class to be used in parsing Engagement_List_Criteria__c for outreach case
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | vincent.ferrer                 | May 03, 2024          | DEPP-8750              | Created file                                                |
*/
public with sharing class ELCCompletedCadenceEvaluator {
    
    private ELCParser elcParser;
    
    public ELCCompletedCadenceEvaluator(ELCParser elcParser) {
        this.elcParser = elcParser;
    }

    public Map<Id, List<Completed_Cadence__c>> evaluate(Map<Id, Contact> contactMap) {

        Map<Id, List<Completed_Cadence__c>> completedCadencesMap;

        if (!elcParser.getELCCompletedCadenceParser().getCompletedCadenceCriteria().isEmpty()) {

            elcParser.getELCContactParser().getContactCriteria().setContactIdSet(contactMap.keySet());
            List<Completed_Cadence__c> completedCadences = CompletedCadencesDAO.newInstance().findByCriteria(
                elcParser.getELCCompletedCadenceParser().getCompletedCadenceCriteria(), 
                elcParser.getELCContactParser().getContactCriteria(), 
                AccessLevel.SYSTEM_MODE
            );

            completedCadencesMap = groupByContact(completedCadences);
        }

        return completedCadencesMap;
    }

    private Map<Id, List<Completed_Cadence__c>> groupByContact(List<Completed_Cadence__c> completedCadences) {
        Map<Id, List<Completed_Cadence__c>> completedCadenceByContactMap = new Map<Id, List<Completed_Cadence__c>>();

        for(Completed_Cadence__c comCadence : completedCadences){
            if(completedCadenceByContactMap.containsKey(comCadence.Contact__c)){
                completedCadenceByContactMap.get(comCadence.Contact__c).add(comCadence);
            }else{
                List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
                completedCadenceList.add(comCadence);
                completedCadenceByContactMap.put(comCadence.Contact__c, completedCadenceList);
            }
        }
        
        return completedCadenceByContactMap;
    }

}
