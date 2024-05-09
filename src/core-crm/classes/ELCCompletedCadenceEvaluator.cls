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

    // Return null if query not executed
    public Map<Id, List<Completed_Cadence__c>> evaluate(Map<Id, Contact> contactMap) {

        Map<Id, List<Completed_Cadence__c>> completedCadencesMap;

        if (!elcParser.getELCCompletedCadenceParser().getCompletedCadenceCriteria().isEmpty()) {
            // if none of the child or grand child criteria defined, fire query and inherit parent / grand parent criteria
            elcParser.getELCContactParser().getContactCriteria().setContactIdSet(contactMap.keySet());
            //elcParser.getContactCriteria().contactIdSet.addAll(contactMap.keySet());

            //add contact id set into soql
            List<Completed_Cadence__c> completedCadences = CompletedCadencesDAO.newInstance().findByCriteria(
                elcParser.getELCCompletedCadenceParser().getCompletedCadenceCriteria(), 
                elcParser.getELCContactParser().getContactCriteria(), 
                AccessLevel.SYSTEM_MODE
            );
            completedCadencesMap = groupByContact(completedCadences);
        }
        // if any of the child or grandchild criteria defined, only run the query in the child or grandchild
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