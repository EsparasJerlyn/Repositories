/**
 * @description TriggerHandler Class for CourseConnectionTrigger
 * @see ..CourseConnectionTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                           |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------|
      | johnbo.pineda@qut.edu.au       | December 03, 2021     | DEPP-789               | Created file                                             |
      | johnbo.pineda@qut.edu.au       | January 03, 2021      | DEPP-1382              | Updated Test Class to include changes for DEPP-1382.     |
      |                                |                       |                        |                                                          |
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
   * @param crseEnrollListNew - List of hed__Course_Enrollment__c.Trigger.new
   * @param crseEnrollListOld - Map of hed__Course_Enrollment__c.Trigger.old
   */
  public void updateCourseConnectionCounter(
    List<hed__Course_Enrollment__c> crseEnrollListNew,
    List<hed__Course_Enrollment__c> crseEnrollListOld
  ) {
    try {
      Map<Id, Integer> courseOfferMap = new Map<Id, Integer>();
      Map<Id, Integer> programOfferMap = new Map<Id, Integer>();
      Set<Id> courseOfferIdSet = new Set<Id>();
      Set<Id> programOfferIdSet = new Set<Id>();

      for (hed__Course_Enrollment__c crseEnroll : crseEnrollListNew) {
        if (String.isNotBlank(crseEnroll.hed__Course_Offering__c)) {
          courseOfferIdSet.add(crseEnroll.hed__Course_Offering__c);
        }

        if (String.isNotBlank(crseEnroll.Program_Offering__c)) {
          programOfferIdSet.add(crseEnroll.Program_Offering__c);
        }
      }

      if (crseEnrollListOld != null) {
        for (hed__Course_Enrollment__c crseEnrollOld : crseEnrollListOld) {
          if (String.isNotBlank(crseEnrollOld.hed__Course_Offering__c)) {
            courseOfferIdSet.add(crseEnrollOld.hed__Course_Offering__c);
          }

          if (String.isNotBlank(crseEnrollOld.Program_Offering__c)) {
            programOfferIdSet.add(crseEnrollOld.Program_Offering__c);
          }
        }
      }

      List<AggregateResult> aggrCourseOfferList = [
        SELECT hed__Course_Offering__c, COUNT(Id) counter
        FROM hed__Course_Enrollment__c
        WHERE
          hed__Course_Offering__c IN :courseOfferIdSet
          AND hed__Status__c != 'Cancelled'
        GROUP BY hed__Course_Offering__c
      ];

      for (AggregateResult aggrCourseOffer : aggrCourseOfferList) {
        if (
          String.isNotBlank((Id) aggrCourseOffer.get('hed__Course_Offering__c'))
        ) {
          courseOfferMap.put(
            (Id) aggrCourseOffer.get('hed__Course_Offering__c'),
            (Integer) aggrCourseOffer.get('counter')
          );
        }
      }

      List<AggregateResult> aggrProgramOfferList = [
        SELECT Program_Offering__c, COUNT(Id) counter
        FROM hed__Course_Enrollment__c
        WHERE
          Program_Offering__c IN :programOfferIdSet
          AND hed__Status__c != 'Cancelled'
        GROUP BY Program_Offering__c
      ];

      for (AggregateResult aggrProgramOffer : aggrProgramOfferList) {
        if (
          String.isNotBlank((Id) aggrProgramOffer.get('Program_Offering__c'))
        ) {
          programOfferMap.put(
            (Id) aggrProgramOffer.get('Program_Offering__c'),
            (Integer) aggrProgramOffer.get('counter')
          );
        }
      }

      List<hed__Course_Offering__c> courseOfferList = [
        SELECT Id, Total_Course_Connections__c
        FROM hed__Course_Offering__c
        WHERE Id IN :courseOfferIdSet
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

      List<Program_Offering__c> programOfferList = [
        SELECT Id, Total_Course_Connections__c
        FROM Program_Offering__c
        WHERE Id IN :programOfferIdSet
      ];

      for (Program_Offering__c programOffer : programOfferList) {
        if (programOfferMap.containsKey(programOffer.Id)) {
          programOffer.Total_Course_Connections__c = programOfferMap.get(
            programOffer.Id
          );
        } else {
          programOffer.Total_Course_Connections__c = 0;
        }
      }

      update programOfferList;
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
