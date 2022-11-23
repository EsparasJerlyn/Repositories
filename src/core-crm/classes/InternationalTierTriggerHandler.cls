/**
 * @description TriggerHandler Class for InternationalTierTrigger
 * @see ..InternationalTierTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | rhea.b.torres                  | November 10, 2022     | DEPP-4448              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class InternationalTierTriggerHandler implements BeforeInsert, AfterUpdate{

    /**
     * @description 
     * @param newItems - List of International_Tier__c.Trigger.new
     */
    public void beforeInsert(List<SObject> newItems){
        validateActiveCountryTiersOnInsert((List<International_Tier__c>) newItems);
    }

    /**
     * @description 
     * @param newItems - Map of International_Tier__c.Trigger.new
     * @param oldItems - Map of International_Tier__c.Trigger.old
     */
    public void afterUpdate(Map<Id, SObject> newItems,
                            Map<Id, SObject> oldItems){
        validateActiveCountryTiersOnUpdate((Map<Id,International_Tier__c>) newItems);
    }

    /**
     * @description 
     * @param newItems - List of International_Tier__c.Trigger.new
     */
    private void validateActiveCountryTiersOnInsert(List<International_Tier__c> newItems){
        Set<String> existingActiveTiers = new Set<String>();
        Set<String> countryNameList = new Set<String>();
        
        // Process only records with IsActive__c set to TRUE
        List<International_Tier__c> toProcessRecords = getRecordsToValidate(newItems, countryNameList);
        // Query existing records if active records exist for the specified country names
        for(International_Tier__c tier : [  SELECT Id,Country_Name__c,IsActive__c 
                                            FROM International_Tier__c
                                            WHERE Country_Name__c IN :countryNameList AND IsActive__c=TRUE WITH SECURITY_ENFORCED] ){
            existingActiveTiers.add(tier.Country_Name__c);                                
        }                           
        validateTriggerRecords(toProcessRecords, existingActiveTiers);
    }

    /**
     * @description 
     * @param newItems - Map of International_Tier__c.Trigger.new
     */
    private void validateActiveCountryTiersOnUpdate(Map<Id,International_Tier__c> newItems){
        Set<String> countryNameList = new Set<String>();
        Set<String> existingActiveTiers = new Set<String>();
        List<International_Tier__c> countryTiers = new List<International_Tier__c>();
        countryTiers = newItems.values();

        // Process only records with IsActive__c set to TRUE
        List<International_Tier__c> toProcessRecords = getRecordsToValidate(countryTiers, countryNameList);
        // Query existing records if active records exist for the specified country names
        for(International_Tier__c tier : [  SELECT Id,Country_Name__c,IsActive__c 
                                            FROM International_Tier__c
                                            WHERE Country_Name__c IN :countryNameList AND IsActive__c=TRUE WITH SECURITY_ENFORCED] ){
            if(!newItems.containsKey(tier.Id)){
                existingActiveTiers.add(tier.Country_Name__c); 
            }                             
        }
        
        validateTriggerRecords(toProcessRecords, existingActiveTiers);
    }

    /**
     * @description 
     * @param newItems
     * @param countryNameList
     */
    private List<International_Tier__c> getRecordsToValidate(List<International_Tier__c> newItems, Set<String> countryNameList){
        List<International_Tier__c> toProcessRecords = new List<International_Tier__c>();
        for(International_Tier__c tier : newItems){
            if(tier.IsActive__c == true){
                if(!countryNameList.isEmpty() && countryNameList.contains(tier.Country_Name__c)){
                    tier.addError(tier.Country_Name__c + ' should only have one active record.');
                }else{
                    countryNameList.add(tier.Country_Name__c);
                    // Add items to check against existing records
                    toProcessRecords.add(tier);
                }
            }
        }
        return toProcessRecords;
    }

    /**
     * @description Validates records if there are any existing active records of the same country tier exists
     * @param toProcessRecords
     * @param existingActiveTiers
     */
    private void validateTriggerRecords(List<International_Tier__c> toProcessRecords, Set<String> existingActiveTiers){
        for(International_Tier__c tier : toProcessRecords){
            if(existingActiveTiers.contains(tier.Country_Name__c)){
                tier.addError(tier.Country_Name__c + ' should only have one active record.');
            }
        }
    }
}