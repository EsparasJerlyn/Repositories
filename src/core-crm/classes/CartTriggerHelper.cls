/**
 * @description helper class for webcart
 * @see carttriggerhandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | July 15 2022          | DEPP-3485              | Created file                 |
      |                                |                       |                        |                              |
 */

public without sharing class CartTriggerHelper {
  
    /**
    * @description creates a cart payment record linked to the cart on insert
    * @param newItems - Map of WebCart.Trigger.new
    */
    public static void createCartPayment(List<WebCart> newItems) {
        List<Cart_Payment__c> cartPaymentToInsert = new List<Cart_Payment__c>();
        for(WebCart webCart: newItems){
            cartPaymentToInsert.add(new Cart_Payment__c());
        }

        if(!cartPaymentToInsert.isEmpty()){
            insert cartPaymentToInsert;
        }
        
        for(Integer i = 0; i < newItems.size(); i++){
            newItems[i].Cart_Payment__c = cartPaymentToInsert[i].Id;
        }
    }
  }