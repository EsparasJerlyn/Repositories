/**
 * @description TriggerHandler class for Pricebook2Trigger
 * @see Pricebook2Trigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kathy.cornejo                  | June 03, 2022         | DEPP-2664              | Created file                 |
 */
public without sharing class Pricebook2TriggerHandler implements Disableable, BeforeInsert{
/**
   * @description performs beforeinsert event for Pricebook2 object
   * @param newItems - List of Pricebook2.Trigger.new
   */
  public void beforeInsert(List<SObject> newItems) { 
      List<Pricebook2> pbToCreateList = (List<Pricebook2>) newItems;
      
      Set<String> setPricebook2Name = new Set<String>();
      
      for(Pricebook2 pbName: [Select Name from Pricebook2])
		setPricebook2Name.add(pbName.Name);    
      
      Pricebook2DuplicatesHelper.detectPricebook2Duplicates((List<Pricebook2>) newItems, setPricebook2Name);
  }
    
  
/**
 * @description indicates it the trigger is disabled
 * @return disabled bypass
 */
  public Boolean isDisabled() {
    final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
    return bypass.isDisabled();
  }
}