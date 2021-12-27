/**
 * @description TriggerHandler Class for PendingRegistrationTrigger
 * @see ..PendingRegistrationTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | johnbo.pineda@qut.edu.au       | December 20, 2021     | DEPP-1150              | Created file                 |
      |                                |                       |                        |                              |
 */
public without sharing class PendingRegistrationTriggerHandler implements Disableable, AfterInsert, AfterUpdate, AfterDelete {
  /**
   * @description update counter for Pending Registration
   * @param newItems - List of Pending_Registration__c.Trigger.new
   */
  public void afterInsert(Map<Id, SObject> newItems) {
    updatePendingRegistrationCounter(
      (List<Pending_Registration__c>) newItems.values(),
      null
    );
  }

  /**
   * @description update counter for Pending Registration
   * @param newItems - List of Pending_Registration__c.Trigger.new
   * @param oldItems - Map of Pending_Registration__c.Trigger.old
   */
  public void afterUpdate(
    Map<Id, SObject> newItems,
    Map<Id, SObject> oldItems
  ) {
    updatePendingRegistrationCounter(
      (List<Pending_Registration__c>) newItems.values(),
      (List<Pending_Registration__c>) oldItems.values()
    );
  }

  /**
   * @description update counter for Pending Registration
   * @param newItems - List of Pending_Registration__c.Trigger.new
   * @param oldItems - Map of Pending_Registration__c.Trigger.old
   */
  public void afterDelete(Map<Id, SObject> oldItems) {
    updatePendingRegistrationCounter(
      (List<Pending_Registration__c>) oldItems.values(),
      null
    );
  }

  /**
   * @description update counter for Pending Registration
   * @param idSet - Set of Pending_Registration__c.Ids
   */
  public void updatePendingRegistrationCounter(
    List<Pending_Registration__c> pendRegListNew,
    List<Pending_Registration__c> pendRegListOld
  ) {
    try {
      Map<Id, Integer> courseOfferMap = new Map<Id, Integer>();
      Set<Id> idSet = new Set<Id>();
      for (Pending_Registration__c pendReg : pendRegListNew) {
        if (String.isNotBlank(pendReg.Course_Offering__c)) {
          idSet.add(pendReg.Course_Offering__c);
        }
      }

      if (pendRegListOld != null) {
        for (Pending_Registration__c pendRegOld : pendRegListOld) {
          if (String.isNotBlank(pendRegOld.Course_Offering__c)) {
            idSet.add(pendRegOld.Course_Offering__c);
          }
        }
      }

      List<AggregateResult> aggrList = [
        SELECT Course_Offering__c, COUNT(Id) counter
        FROM Pending_Registration__c
        WHERE Course_Offering__c IN :idSet
        GROUP BY Course_Offering__c
      ];

      for (AggregateResult aggr : aggrList) {
        if (String.isNotBlank((Id) aggr.get('Course_Offering__c'))) {
          courseOfferMap.put(
            (Id) aggr.get('Course_Offering__c'),
            (Integer) aggr.get('counter')
          );
        }
      }

      List<hed__Course_Offering__c> courseOfferList = [
        SELECT Id, On_Hold_Seat__c
        FROM hed__Course_Offering__c
        WHERE Id IN :idSet
      ];

      for (hed__Course_Offering__c courseOffer : courseOfferList) {
        if (courseOfferMap.containsKey(courseOffer.Id)) {
          courseOffer.On_Hold_Seat__c = courseOfferMap.get(courseOffer.Id);
        } else {
          courseOffer.On_Hold_Seat__c = 0;
        }
      }

      update courseOfferList;
    } catch (Exception e) {
      System.debug(
        'Error on PendingRegistrationTriggerHandler.updatePendingRegistrationCounter'
      );
      System.debug(e);
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
