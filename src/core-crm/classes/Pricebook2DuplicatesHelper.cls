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
    public static void detectPricebook2Duplicates(List<Pricebook2> newItems, Set<String> setPricebook2Name){
          	
		for(Pricebook2 pbName: newItems){
			if(!setPricebook2Name.contains(pbName.Name)){
				setPricebook2Name.add(pbName.Name);
			}
			else{
				pbName.Name.addError('Pricebook already exist with the same name.');
			}
		}   
        
    }
}