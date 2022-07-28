/**
 * @description Calls the helper method when triggered to update the External Id
 * @see CartTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 22, 2022        | DEPP-1991              | Created file                 |
      | roy.nino.s.regala              | July 15, 2022         | DEPP-3485              | create cartpayment on insert |
 */

public without sharing class CartTriggerHandler implements Disableable, BeforeInsert{

  /**
   * @description calls the ExternalIdHelper function to update the External Id
   * @param newItems - List of Cart.Trigger.new
   */
  public void beforeInsert(List<SObject> newItems) {
    SetExternalIdHelper.updateExternalId(newItems);
    CartTriggerHelper.createCartPayment(newItems);
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