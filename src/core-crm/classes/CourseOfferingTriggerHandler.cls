/**
 * @description Calls the helper method when triggered to update the External Id
 * @see CourseOfferingTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------------------|
      | eugene.andrew.abuan            | March 22, 2022        | DEPP-1991              | Created file                                                  |
      | eugene.andrew.abuan            | March 22, 2022        | DEPP-3534              | Update                                                        |
      | eugene.andrew.abuan            | July 29, 2022         | DEPP-3534              | Added Do no show start date logic                             |
      | kenneth.f.alsay                | September 22, 2023    | DEPP-6299              | Added setLMSIntegrationStatusToIsChanged to before update     |
      |                                |                       |                        |                                                               |
 */

public without sharing class CourseOfferingTriggerHandler implements Disableable, BeforeInsert, BeforeUpdate, AfterInsert, AfterUpdate {
    /**
     * @description calls Validate Related Product & ExternalIdHelper function to update the External Id
     * @param newItems - List of hed__Course_Offering__c.Trigger.new
     */
    public void beforeInsert(List<SObject> newItems) {
        validateRelatedProduct((List<hed__Course_Offering__c>) newItems , null);
        SetExternalIdHelper.updateExternalId(newItems);
        SetOfferingName.setName(newItems);
    }

    /**
     * @description calls Validate Related Product
     * @param newItems - List of hed__Course_Offering__c.Trigger.new
     * @param oldItems - List of hed__Course_Offering__c.Trigger.old
     */
    public void beforeUpdate(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
    ) {
        validateRelatedProduct((List<hed__Course_Offering__c>) newItems.values(),(Map<Id, hed__Course_Offering__c>) oldItems );
        CourseOfferingTriggerHelper.setLMSIntegrationStatusToIsChanged((List<hed__Course_Offering__c>) newItems.values(), (Map<Id, hed__Course_Offering__c>) oldItems);
    }

    /**
     * @description performs afterinsert event for hed__Course_Offering object
     * @param newItems - List of hed__Course_Offering__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        Map<Id, hed__Course_Offering__c> newItemsMap = (Map<Id, hed__Course_Offering__c>) newItems;
        //only create 1:1 since email will be sent once per offering and createddate is identical
        Map<Id, hed__Course_Offering__c> courseToOfferinMap = new Map<Id, hed__Course_Offering__c>();

        for (Id offeringId : newItems.keySet()) {
            //check if offering is updated to be available for registration
            if (
                newItemsMap.get(offeringId).IsActive__c == true &&
                newItemsMap.get(offeringId).Available_Seats__c > 0 &&
                newItemsMap.get(offeringId).Registration_Start_Date__c <=
                Date.today() &&
                newItemsMap.get(offeringId).hed__Course__c != null &&
                (newItemsMap.get(offeringId).Registration_End_Date__c >
                Date.today() ||
                newItemsMap.get(offeringId).Registration_End_Date__c == null)
            ) {
                courseToOfferinMap.put(
                    newItemsMap.get(offeringId).hed__Course__c,
                    newItemsMap.get(offeringId)
                );
            }
        }
        if (!courseToOfferinMap.keySet().isEmpty()) {
            SendNewOfferingNotificationHelper.sendCourseOfferingAvailabiltyNotification(
                courseToOfferinMap
            );
        }
    }

    /**
     * @description performs afterinsert event for hed__Course_Offering object
     * @param newItems - List of hed__Course_Offering__c.Trigger.new
     */
    public void afterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
    ) {
        //only create 1:1 since email will be sent once per offering and createddate is identical
        Map<Id, hed__Course_Offering__c> courseToOfferinMap = new Map<Id, hed__Course_Offering__c>();

        Map<Id, hed__Course_Offering__c> newItemsMap = (Map<Id, hed__Course_Offering__c>) newItems;
        Map<Id, hed__Course_Offering__c> oldItemsMap = (Map<Id, hed__Course_Offering__c>) oldItems;

        for (Id offeringId : newItems.keySet()) {
            //check if offering is updated to be available for registration
            if (
                ((oldItemsMap.get(offeringId).Available_Seats__c !=
                newItemsMap.get(offeringId).Available_Seats__c &&
                oldItemsMap.get(offeringId).Available_Seats__c == 0) ||
                (oldItemsMap.get(offeringId).Registration_Start_Date__c !=
                newItemsMap.get(offeringId).Registration_Start_Date__c &&
                oldItemsMap.get(offeringId).Registration_Start_Date__c >
                Date.today()) ||
                oldItemsMap.get(offeringId).IsActive__c !=
                newItemsMap.get(offeringId).IsActive__c) &&
                newItemsMap.get(offeringId).IsActive__c == true &&
                newItemsMap.get(offeringId).Available_Seats__c > 0 &&
                newItemsMap.get(offeringId).Registration_Start_Date__c <=
                Date.today() &&
                newItemsMap.get(offeringId).hed__Course__c != null &&
                (newItemsMap.get(offeringId).Registration_End_Date__c >
                Date.today() ||
                newItemsMap.get(offeringId).Registration_End_Date__c == null)
            ) {
                courseToOfferinMap.put(
                    newItemsMap.get(offeringId).hed__Course__c,
                    newItemsMap.get(offeringId)
                );
            }
        }
        if (!courseToOfferinMap.keySet().isEmpty()) {
            SendNewOfferingNotificationHelper.sendCourseOfferingAvailabiltyNotification(
                courseToOfferinMap
            );
        }
    }

    /**
     * @description validate related Product
     * @param crseOfferNew - List of hed__Course_Offering__c.Trigger.new
     * @param crseOfferOld - List of hed__Course_Offering__c.Trigger.old
     */
    public void validateRelatedProduct(
        List<hed__Course_Offering__c> crseOfferNew,
        Map<Id, hed__Course_Offering__c> crseOfferOld
    ) {
        // Get Courses
        Set<Id> courseSetId = new Set<Id>();
        for (hed__Course_Offering__c cOff : crseOfferNew) {
            if(crseOfferOld == null &&  cOff.IsActive__c == true ){
                courseSetId.add(cOff.hed__Course__c);
            }else if(crseOfferOld != null && cOff.IsActive__c != crseOfferOld.get(cOff.Id).IsActive__c && cOff.IsActive__c == true){
                courseSetId.add(cOff.hed__Course__c);
            }else if(crseOfferOld != null && cOff.IsActive__c != crseOfferOld.get(cOff.Id).IsActive__c && cOff.IsActive__c == false){
                courseSetId.add(cOff.hed__Course__c);
            }
        }

        // Get Active Course Offering Count per Course
        Map<Id, Integer> cCounterMap = new Map<Id, Integer>();
        for (AggregateResult cOffCounter : [
            SELECT hed__Course__c, Count(Id) counter
            FROM hed__Course_Offering__c
            WHERE hed__Course__c IN :courseSetId AND IsActive__c = TRUE
            GROUP BY hed__Course__c
        ]) {
            cCounterMap.put(
                (Id) cOffCounter.get('hed__Course__c'),
                (Integer) cOffCounter.get('counter')
            );
        }

        // Get Related Products for Courses
        Map<Id, Boolean> cProdDoNotDisplayDate = new Map<Id, Boolean>();
        for (Product2 prod : [
            SELECT Id, Course__c, Do_not_Show_Start_Date__c
            FROM Product2
            WHERE Course__c IN :courseSetId
        ]) {
            cProdDoNotDisplayDate.put(
                prod.Course__c,
                prod.Do_not_Show_Start_Date__c
            );
        }

        // Process
        if(!courseSetId.isEmpty()){
            for (hed__Course_Offering__c cOffVal : crseOfferNew) {
                Boolean doNotDisplayDate = (Boolean) cProdDoNotDisplayDate.get(
                    cOffVal.hed__Course__c
                );
                Integer cOffCount = (Integer) cCounterMap.get(
                    cOffVal.hed__Course__c
                );
                
                //Check if Active Course Offering Count is 1
                Boolean cOffCountIsOne = cOffCount >= 1? true: false;
                // If Related Product Do Not Display Date is True
                Boolean isActiveCOfferingDoNotDisplayDate = (doNotDisplayDate == true && cOffCountIsOne == true && cOffVal.IsActive__c == true);
                Boolean isNotActiveCOfferingDoNotDisplayDate = (doNotDisplayDate == true && cOffCountIsOne == true && cOffVal.IsActive__c == false && String.isNotBlank(cOffVal.Id));
                if (isActiveCOfferingDoNotDisplayDate) {
                    cOffVal.IsActive__c.addError(
                        'An active offering is already existing'
                    );
                }
                if (isNotActiveCOfferingDoNotDisplayDate) {
                    cOffVal.IsActive__c.addError(
                        '"Do not show start date" needs to be false before this offering can be deactivated.'
                    );
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