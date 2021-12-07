/**
 * @description TriggerHandler Class for CourseConnectionTrigger
 * @see ..CourseConnectionTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | johnbo.pineda@qut.edu.au       | December 03, 2021     | DEPP-789               | Created file                 |
      |                                |                       |                        |                              |
 */
public without sharing class CourseConnectionTriggerHandler implements Disableable, AfterInsert, AfterUpdate, AfterDelete {
  /**
   * @description update counter for Course Connections
   * @param newItems - List of hed__Course_Enrollment__c.Trigger.new
   */
  public void afterInsert(Map<Id, SObject> newItems) {
    updateCourseConnectionCounter(
      (List<hed__Course_Enrollment__c>) newItems.values(),
      null
    );
  }

  /**
   * @description update counter for Course Connections
   * @param newItems - List of hed__Course_Enrollment__c.Trigger.new
   * @param oldItems - Map of hed__Course_Enrollment__c.Trigger.old
   */
  public void afterUpdate(
    Map<Id, SObject> newItems,
    Map<Id, SObject> oldItems
  ) {
    updateCourseConnectionCounter(
      (List<hed__Course_Enrollment__c>) newItems.values(),
      (List<hed__Course_Enrollment__c>) oldItems.values()
    );
  }

  /**
   * @description update counter for Course Connections
   * @param newItems - List of hed__Course_Enrollment__c.Trigger.new
   * @param oldItems - Map of hed__Course_Enrollment__c.Trigger.old
   */
  public void afterDelete(Map<Id, SObject> oldItems) {
    updateCourseConnectionCounter(
      (List<hed__Course_Enrollment__c>) oldItems.values(),
      null
    );
  }

  /**
   * @description update counter for Course Connections
   * @param idSet - Set of hed__Course_Enrollment__c.Ids
   */
  public void updateCourseConnectionCounter(
    List<hed__Course_Enrollment__c> crseEnrollListNew,
    List<hed__Course_Enrollment__c> crseEnrollListOld
  ) {
    try {
      Map<Id, Integer> courseOfferMap = new Map<Id, Integer>();
      Set<Id> idSet = new Set<Id>();
      for (hed__Course_Enrollment__c crseEnroll : crseEnrollListNew) {
        if (String.isNotBlank(crseEnroll.hed__Course_Offering__c)) {
          idSet.add(crseEnroll.hed__Course_Offering__c);
        }
      }

      if (crseEnrollListOld != null) {
        for (hed__Course_Enrollment__c crseEnrollOld : crseEnrollListOld) {
          if (String.isNotBlank(crseEnrollOld.hed__Course_Offering__c)) {
            idSet.add(crseEnrollOld.hed__Course_Offering__c);
          }
        }
      }

      List<AggregateResult> aggrList = [
        SELECT hed__Course_Offering__c, COUNT(Id) counter
        FROM hed__Course_Enrollment__c
        WHERE hed__Course_Offering__c IN :idSet
        GROUP BY hed__Course_Offering__c
      ];

      for (AggregateResult aggr : aggrList) {
        if (String.isNotBlank((Id) aggr.get('hed__Course_Offering__c'))) {
          courseOfferMap.put(
            (Id) aggr.get('hed__Course_Offering__c'),
            (Integer) aggr.get('counter')
          );
        }
      }

      List<hed__Course_Offering__c> courseOfferList = [
        SELECT Id, Total_Course_Connections__c
        FROM hed__Course_Offering__c
        WHERE Id IN :idSet
      ];

      for (hed__Course_Offering__c courseOffer : courseOfferList) {
        if (courseOfferMap.containsKey(courseOffer.Id)) {
          courseOffer.Total_Course_Connections__c = courseOfferMap.get(
            courseOffer.Id
          );
        } else {
          courseOffer.Total_Course_Connections__c = 0;
        }
      }

      update courseOfferList;
    } catch (Exception e) {
      System.debug(
        'Error on CourseConnectionTriggerHandler.updateCourseConnectionCounter'
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
