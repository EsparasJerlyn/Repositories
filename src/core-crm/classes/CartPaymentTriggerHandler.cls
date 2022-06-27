/**
 * @description Trigger handler for cart payment
 * @see CartPaymentTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                     |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------------------------|
      | roy.nino.s.regala              | June 24, 2022         | DEPP-3252              | Created file                                                       |
 */
public without sharing class CartPaymentTriggerHandler implements Disableable, AfterUpdate{



  /**
   * @description update counter for Cart Item
   * @param newItems - List of CartPayment.Trigger.new
   * @param oldItems - Map of CartPayment.Trigger.old
   */
  public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {

    Set<Id> approvedOrInvoiceCp = new Set<Id>();
    Map<Id, Cart_Payment__c> oldMap = (Map<Id,Cart_Payment__c>) oldItems;
    Map<Id, Cart_Payment__c> newMap = (Map<Id,Cart_Payment__c>) newItems;

    //loop through cartpayments and get ids that needs to be processed
    for(Id cartPayId: newItems.keySet()){
        //if payment status is updated
        // payment status is null -> Approved or Invoiced
        // payment status is Invoiced -> Approved
        if( newMap.get(cartPayId).Payment_Status__c != oldMap.get(cartPayId).Payment_Status__c && 
            ((   oldMap.get(cartPayId).Payment_Status__c == null && 
            (   newMap.get(cartPayId).Payment_Status__c == 'Approved' || 
                newMap.get(cartPayId).Payment_Status__c == 'Invoiced')) ||
                (   oldMap.get(cartPayId).Payment_Status__c == 'Invoiced' &&
                    newMap.get(cartPayId).Payment_Status__c == 'Approved'
                ))
        ){
            approvedOrInvoiceCp.add(cartPayId);
        }
    }
    if(!approvedOrInvoiceCp.isEmpty()){
        CartPaymentTriggerHelper.upsertCourseConnection(approvedOrInvoiceCp,newMap);
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