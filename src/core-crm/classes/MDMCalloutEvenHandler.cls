/**
 * @description MDM Callout Event Handler class
 * @see MDMCalloutEventListener
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 12, 2024       | DEPP-10490             | Created file                 |
 */

public with sharing class MDMCalloutEvenHandler {
    
    private List<MDM_Callout_Event__e> mdmCalloutEventList;
    
    public MDMCalloutEvenHandler(List<MDM_Callout_Event__e> mdmCalloutEventList) {
        this.mdmCalloutEventList = mdmCalloutEventList;
    }

    public void handle() {
        try{
            //Add logic for contact and course conn mdm call out
        } catch(Exception e){
            NebulaLoggerService.logExceptionDetails('Exception caught in handle method.', e);
        }
        
    }

    //create future method for callout
}