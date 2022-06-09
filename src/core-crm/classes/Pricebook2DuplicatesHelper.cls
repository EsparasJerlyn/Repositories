/**
 * @description Helper class for detecting duplicates for Pricebook2
 * @see Pricebook2TriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kathy.cornejo                  | June 03, 2022         | DEPP-2664              | Created file                 |
 */
public with sharing class Pricebook2DuplicatesHelper {
    
	/**
     * @description detects duplicates of pricebook2 records
    * @param newItems - List of SObjects.Trigger.new
    */
    public static void detectPricebook2Duplicates(Set<String> duplicateNames, List<Pricebook2> newItems){
          	
		for(Pricebook2 pbName: newItems){
            if(pbName.Name != null && duplicateNames.contains(pbName.name)){
            	pbName.Name.addError('Pricebook already exist with the same name.');
            }
		}    
    }
}