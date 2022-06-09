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
      Set<String> pbNameSet = new Set<String>();
      Set<String> dupeNameSet = new Set<String>();
      
      for(Pricebook2 pbCreate : (List<Pricebook2>) newItems){
          pbNameSet.add(pbCreate.Name);
      }
      for(Pricebook2 pbNames : [Select Name from Pricebook2 Where Name IN : pbNameSet] ){
          dupeNameSet.add(pbNames.Name);
      }
      if(!dupeNameSet.isEmpty()){
          Pricebook2DuplicatesHelper.detectPricebook2Duplicates(dupeNameSet, (List<Pricebook2>) newItems); 
      }       
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