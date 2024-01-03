/**
 * @description Calls the helper method when triggered to update the External Id
 * @see CartItemTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                     |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------------------------|
      | eugene.andrew.abuan            | March 22, 2022        | DEPP-1991              | Created file                                                       |
      | arsenio.jr.dayrit              | April 07, 2022        | DEPP-2057              | add method for counting cart item  for course and program offering |
      | julie.jane.alegre              | January 02, 2024      | ApexCRUDViolationFix   | ApexCRUDViolation is fixed                                         |
 */
public without sharing class CartItemTriggerHandler implements Disableable, BeforeInsert,
                                                                            AfterInsert,
                                                                            AfterUpdate,
                                                                            AfterDelete{
	
  /**
   * @description calls the ExternalIdHelper function to update the External Id
   * @param newItems - List of CartItem.Trigger.new
   */
  public void beforeInsert(List<SObject> newItems) {
    SetExternalIdHelper.updateExternalId(newItems);
  }


   /**
   * @description update counter for Cart Item
   * @param newItems - List of CartItem.Trigger.new
   */
  public void afterInsert(Map<Id, SObject> newItems) {
    updateCartItemCounter((List<CartItem>) newItems.values(),null);
  }

  /**
   * @description update counter for Cart Item
   * @param newItems - List of CartItem.Trigger.new
   * @param oldItems - Map of CartItem.Trigger.old
   */
  public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    updateCartItemCounter((List<CartItem>) newItems.values(),(List<CartItem>) oldItems.values());
  }

  /**
   * @description update counter for Cart Item
   * @param oldItems - Map of CartItem.Trigger.old
   */
  public void afterDelete(Map<Id, SObject> oldItems) {
    updateCartItemCounter((List<CartItem>) oldItems.values(),null);
  }

  /**
   * @description description update counter for Cart Item
   * @param cartItemListNew - List of CartItem.Trigger.new
   * @param cartItemListOld - Map of CartItem.Trigger.old
   */
  public void updateCartItemCounter(List<CartItem> cartItemListNew,List<CartItem> cartItemListOld) {

    try {
      Map<Id, Integer> courseOfferMap = new Map<Id, Integer>();
      Map<Id, Integer> programOfferMap = new Map<Id, Integer>();
      Set<Id> courseOfferIdSet = new Set<Id>();
      Set<Id> programOfferIdSet = new Set<Id>();

      for (CartItem cartItemNew : cartItemListNew) {
        if (String.isNotBlank(cartItemNew.Course_Offering__c)) {
          courseOfferIdSet.add(cartItemNew.Course_Offering__c);
        }
      }

      if (cartItemListOld != null) {
        for (CartItem cartItemOld : cartItemListOld) {
          if (String.isNotBlank(cartItemOld.Course_Offering__c)) {
            courseOfferIdSet.add(cartItemOld.Course_Offering__c);
          }
        }
      }

      for (CartItem cartItemNew : cartItemListNew) {
        if (String.isNotBlank(cartItemNew.Program_Offering__c)) {
          programOfferIdSet.add(cartItemNew.Program_Offering__c);
        }
      }

      if (cartItemListOld != null) {
        for (CartItem cartItemOld : cartItemListOld) {
          if (String.isNotBlank(cartItemOld.Program_Offering__c)) {
            programOfferIdSet.add(cartItemOld.Program_Offering__c);
          }
        }
      }

      List<AggregateResult> aggrCourseOfferList = CartItemsDAO.newInstance().countCartItemsGroupByCourseOffering(courseOfferIdSet, AccessLevel.SYSTEM_MODE);

      for (AggregateResult aggrCourseOffer : aggrCourseOfferList) {
        if (String.isNotBlank((Id) aggrCourseOffer.get('Course_Offering__c'))) {
          courseOfferMap.put((Id) aggrCourseOffer.get('Course_Offering__c'),(Integer) aggrCourseOffer.get('counter'));
        }
      }

      List<hed__Course_Offering__c> courseOfferList = CourseOfferingsDAO.newInstance().getCourseOfferingByRecordIds(courseOfferIdSet, AccessLevel.SYSTEM_MODE);

      for (hed__Course_Offering__c courseOffer : courseOfferList) {
        if (courseOfferMap.containsKey(courseOffer.Id)) {
          courseOffer.Checkout_Cart_Items_Count__c = courseOfferMap.get(courseOffer.Id);
        } else {
          courseOffer.Checkout_Cart_Items_Count__c = 0;
        }
      }

      CourseOfferingsDAO.newInstance().updateRecords(courseOfferList, false, AccessLevel.SYSTEM_MODE);

      List<AggregateResult> aggrProgramOfferList = CartItemsDAO.newInstance().countCartItemsGroupByProgramOffering(programOfferIdSet, AccessLevel.SYSTEM_MODE);

      for (AggregateResult aggrProgramOffer : aggrProgramOfferList) {
        if (String.isNotBlank((Id) aggrProgramOffer.get('Program_Offering__c'))) {
          programOfferMap.put((Id) aggrProgramOffer.get('Program_Offering__c'),(Integer) aggrProgramOffer.get('counter'));
        }
      }

      List<Program_Offering__c> programOfferList = ProgramOfferingsDAO.newInstance().getProgramOfferingByRecordIds(programOfferIdSet, AccessLevel.SYSTEM_MODE);

      for (Program_Offering__c programOffer : programOfferList) {
        if (programOfferMap.containsKey(programOffer.Id)) {
          programOffer.Checkout_Cart_Items_Count__c = programOfferMap.get(programOffer.Id);
        } else {
          programOffer.Checkout_Cart_Items_Count__c = 0;
        }
      }
      ProgramOfferingsDAO.newInstance().updateRecords(programOfferList, false, AccessLevel.SYSTEM_MODE);


    } catch (Exception e) {
      Logger.error('Exception caught in method updateCartItemCounter in class CartItemTriggerHandler').setExceptionDetails(e);
    } finally {
      if(Logger.getBufferSize() > 0) {
        Logger.saveLog();
      }
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