/**
 * @description TriggerHandler Class for Product2TriggerHandler
 * @see ..Product2TriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.bo.a.pineda               | May 2, 2022           | DEPP-2403              | Created file                 |
      |                                |                       |                        |                              |
 */
public without sharing class Product2TriggerHandler implements Disableable, BeforeUpdate {
  public static final Id FACULTY_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Faculty')
    .getRecordTypeId();

  /**
   * @description call method to validate related Facilitator Contacts if Image is uploaded on Contact Image
   * @param newItems - List of Product2.Trigger.new
   * @param oldItems - List of Product2.Trigger.old
   */
  public void beforeUpdate(
    Map<Id, SObject> newItems,
    Map<Id, SObject> oldItems
  ) {
    validateFacilContactImage(
      (List<Product2>) newItems.values(),
      (Map<Id, Product2>) oldItems
    );
  }

  /**
   * @description validate related Facilitator Contacts if Image is uploaded on Contact Image
   * @param prod2New - List of Product2.Trigger.new
   * @param prod2Old - Map of Product2.Trigger.old
   */
  public void validateFacilContactImage(
    List<Product2> prod2New,
    Map<Id, Product2> prod2Old
  ) {
    // Get Course Id Set for Single Product Ready for Publishing updated to 'Yes'
    Set<Id> courseIdSet = new Set<Id>();
    for (Product2 prod : prod2New) {
      if (
        prod2Old.get(prod.Id).Ready_for_publishing__c !=
        prod.Ready_for_publishing__c &&
        prod.Ready_for_publishing__c == 'Yes' &&
        String.isBlank(prod.Program_Plan__c)
      ) {
        courseIdSet.add(prod.Course__c);
      }
    }

    if (courseIdSet.size() > 0) {
      // Get List of Course Connection Facilitators
      Map<Id, Map<Id, String>> noCourseConImageMap = new Map<Id, Map<Id, String>>();
      List<hed__Course_Offering__c> cOfferList = [
        SELECT
          Id,
          hed__Course__c,
          (
            SELECT
              Id,
              IsActive__c,
              hed__Contact__c,
              hed__Contact__r.Name,
              hed__Contact__r.Contact_Image__c
            FROM hed__Course_Enrollment__r
            WHERE RecordTypeId = :FACULTY_RECTYPEID
            AND IsActive__c = TRUE
          )
        FROM hed__Course_Offering__c
        WHERE IsActive__c = TRUE AND hed__Course__c IN :courseIdSet
      ];

      if (cOfferList.size() > 0) {
        // Validate Contact Image from Course Enrollment under Course Offering
        Map<Id, String> noConImageMap = new Map<Id, String>();
        for (hed__Course_Offering__c cOffer : cOfferList) {
          for (
            hed__Course_Enrollment__c cEnroll : cOffer.hed__Course_Enrollment__r
          ) {
            Integer imageCount = 0;
            if (String.isNotBlank(cEnroll.hed__Contact__r.Contact_Image__c)) {
              // Count Number of Images on cEnroll.hed__Contact__r.Contact_Image__c
              Matcher imgMatcher = Pattern.compile('<img(.+?)>')
                .matcher(cEnroll.hed__Contact__r.Contact_Image__c);
              while (imgMatcher.find()) {
                imageCount++;
                // Break While loop when Image File Found
                if (imageCount == 1) {
                  break;
                }
              }

              // If imageCount is 0, Add Contact Id & Name to noConImageMap
              if (imageCount == 0) {
                if (!noConImageMap.containsKey(cEnroll.hed__Contact__c)) {
                  noConImageMap.put(
                    cEnroll.hed__Contact__c,
                    cEnroll.hed__Contact__r.Name
                  );
                }
              }
            } else {
              // If Contact Image is empty, Add Contact Id & Name to noConImageMap
              if (!noConImageMap.containsKey(cEnroll.hed__Contact__c)) {
                noConImageMap.put(
                  cEnroll.hed__Contact__c,
                  cEnroll.hed__Contact__r.Name
                );
              }
            }
          }

          if (!noConImageMap.isEmpty()) {
            noCourseConImageMap.put(cOffer.hed__Course__c, noConImageMap);
          }
        }
      }

      // If there are Facilitator contacts with no Contact Image, add Error to Ready for Publishing
      if (!noCourseConImageMap.isEmpty()) {
        for (Product2 prodVal : prod2New) {
          if (noCourseConImageMap.containsKey(prodVal.Course__c)) {
            Map<Id, String> conMap = noCourseConImageMap.get(prodVal.Course__c);
            List<String> conList = conMap.values();
            prodVal.Ready_for_publishing__c.addError(
              Label.QUT_Product2_ContactImageError +
              ' ' +
              String.join(conList, ', ')
            );
          }
        }
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
