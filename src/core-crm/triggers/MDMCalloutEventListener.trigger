/**
 * @description Trigger Event Listener for MDM Callout 
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 12, 2024       | DEPP-10490             | Created file                 |
 */

trigger MDMCalloutEventListener on MDM_Callout_Event__e (after insert) {

    MDMCalloutEvenHandler mDMCalloutEvenHandler = new MDMCalloutEvenHandler(Trigger.new);
    mDMCalloutEvenHandler.handle();

}