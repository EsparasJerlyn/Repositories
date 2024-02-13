/**
* @description ActionCadenceTrackerChangeEvent object trigger handler class
* @see ActionCadenceTrackerCETriggerHandler
*
* @author Accenture
*
* @history
*    | Developer                 | Date                  | JIRA         | Change Summary                                                        |
     |---------------------------|-----------------------|--------------|-----------------------------------------------------------------------|
     | mark.j.mahilum            | Aug 23, 2023          | DEPP-5846    | Created file                                                          |
*/
public with sharing class ActionCadenceTrackerCETriggerHandler implements Disableable,  AfterInsert {
    
    /**
    * @description afterInsert trigger event
    * @param newItems - Map<Id, SObject> of ActionCadenceTrackerChangeEvent.Trigger.new
    */
    public void afterInsert(Map<Id, SObject> newItems) {
        processCompletedCadenceTracker((List<ActionCadenceTrackerChangeEvent>) newItems.values());           
    }
    
    
   /**
    * @description indicates it the trigger is disabled
    * @return disabled bypass
    */
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
    
   /**
    * @description Process the cadence and create completed cadence record
    * @param newItems  List<ActionCadenceTrackerChangeEvent> newItems
    */
    public static void processCompletedCadenceTracker(List<ActionCadenceTrackerChangeEvent> newItems) {       
        List<String> recordIds = new List<String>();  
        try {
            for(ActionCadenceTrackerChangeEvent event : newItems) {
                EventBus.ChangeEventHeader header = event.ChangeEventHeader;                
                recordIds.addAll(header.getRecordIds());         
                if(recordIds.size() == 0) {
                    continue;
                }       
            }
            
            if(!recordIds.isEmpty()) {                
                SalesCadenceCalloutService.processCompletedCadenceTracker(recordIds);   
            }
            
        } catch(Exception e) {
            Logger.error('Exception caught in method execute in Apex Trigger ActionCadenceTrackerCETriggerHandler.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        } 
    }    
}