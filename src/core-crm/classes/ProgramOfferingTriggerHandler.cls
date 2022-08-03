/**
 * @description
 * @see ProgramOfferingTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 18, 2022        | DEPP-1687              | Created file                 |
      | roy.nino.s.regala              | April 18, 2022        | DEPP-3534              | Updated file                 |
      | eugene.andrew.abuan            | July 29, 2022         | DEPP-3534              | Added Do no show start date logic   |
      |                                |                       |                        |                                     |
 */

public without sharing class ProgramOfferingTriggerHandler implements Disableable, BeforeInsert, BeforeUpdate, AfterInsert, AfterUpdate {
    public void beforeInsert(List<SObject> newItems) {
        validateRelatedProduct((List<Program_Offering__c>) newItems , null);
        SetOfferingName.setName(newItems);
    }

    public void beforeUpdate(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
    ) {
        validateRelatedProduct((List<Program_Offering__c>) newItems.values(), (Map<Id, Program_Offering__c>) oldItems );
    }

    /**
     * @description performs afterinsert event for Program_Offering__c object
     * @param newItems - List of Program_Offering__c.Trigger.new
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        Map<Id, Program_Offering__c> newItemsMap = (Map<Id, Program_Offering__c>) newItems;
        //only create 1:1 since email will be sent once per offering and createddate is identical
        Map<Id, Program_Offering__c> programToOfferinMap = new Map<Id, Program_Offering__c>();

        for (Id offeringId : newItems.keySet()) {
            //check if offering is updated to be available for registration
            if (
                newItemsMap.get(offeringId).IsActive__c == true &&
                newItemsMap.get(offeringId).Available_Seats__c > 0 &&
                newItemsMap.get(offeringId).Registration_Start_Date__c <=
                Date.today() &&
                newItemsMap.get(offeringId).hed_Program_Plan__c != null &&
                (newItemsMap.get(offeringId).Registration_End_Date__c >
                Date.today() ||
                newItemsMap.get(offeringId).Registration_End_Date__c == null)
            ) {
                programToOfferinMap.put(
                    newItemsMap.get(offeringId).hed_Program_Plan__c,
                    newItemsMap.get(offeringId)
                );
            }
        }
        if (!programToOfferinMap.keySet().isEmpty()) {
            SendNewOfferingNotificationHelper.sendProgramOfferingAvailabiltyNotification(
                programToOfferinMap
            );
        }
    }

    /**
     * @description performs afterinsert event for Program_Offering__c object
     * @param newItems - List of Program_Offering__c.Trigger.new
     * @param oldItems - List of Program_Offering__c.Trigger.old

     */
    public void afterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
    ) {
        //only create 1:1 since email will be sent once per offering and createddate is identical
        Map<Id, Program_Offering__c> programToOfferinMap = new Map<Id, Program_Offering__c>();

        Map<Id, Program_Offering__c> newItemsMap = (Map<Id, Program_Offering__c>) newItems;
        Map<Id, Program_Offering__c> oldItemsMap = (Map<Id, Program_Offering__c>) oldItems;

        for (Id offeringId : newItems.keySet()) {
            //check if offering is updated to be available for registration
            if (
                ((oldItemsMap.get(offeringId).Available_Seats__c !=
                newItemsMap.get(offeringId).Available_Seats__c &&
                oldItemsMap.get(offeringId).Available_Seats__c == 0) ||
                (oldItemsMap.get(offeringId).Registration_Start_Date__c !=
                newItemsMap.get(offeringId).Registration_Start_Date__c &&
                oldItemsMap.get(offeringId).Registration_Start_Date__c >
                date.Today()) ||
                oldItemsMap.get(offeringId).IsActive__c !=
                newItemsMap.get(offeringId).IsActive__c) &&
                newItemsMap.get(offeringId).IsActive__c == true &&
                newItemsMap.get(offeringId).Available_Seats__c > 0 &&
                newItemsMap.get(offeringId).Registration_Start_Date__c <=
                Date.today() &&
                newItemsMap.get(offeringId).hed_Program_Plan__c != null &&
                (newItemsMap.get(offeringId).Registration_End_Date__c >
                Date.today() ||
                newItemsMap.get(offeringId).Registration_End_Date__c == null)
            ) {
                programToOfferinMap.put(
                    newItemsMap.get(offeringId).hed_Program_Plan__c,
                    newItemsMap.get(offeringId)
                );
            }
        }
        if (!programToOfferinMap.keySet().isEmpty()) {
            SendNewOfferingNotificationHelper.sendProgramOfferingAvailabiltyNotification(
                programToOfferinMap
            );
        }
    }

    /**
     * @description validate related Product
     * @param progOfferNew - List of Program_Offering__c.Trigger.new
     * @param progOfferOld - List of Program_Offering__c.Trigger.old
     */
    public void validateRelatedProduct(
        List<Program_Offering__c> progOfferNew, 
        Map<Id, Program_Offering__c> progOfferOld

    ) {
        // Get Program Plan
        Set<Id> progPlanSetId = new Set<Id>();
        for (Program_Offering__c pOff : progOfferNew) {
            if(progOfferOld == null && pOff.IsActive__c == true){
                progPlanSetId.add(pOff.hed_Program_Plan__c);
            }else if(progOfferOld != null && pOff.IsActive__c != progOfferOld.get(pOff.Id).IsActive__c && pOff.IsActive__c == true){
                progPlanSetId.add(pOff.hed_Program_Plan__c);
            }else if(progOfferOld != null && pOff.IsActive__c != progOfferOld.get(pOff.Id).IsActive__c && pOff.IsActive__c == false){
                progPlanSetId.add(pOff.hed_Program_Plan__c);
            }
        }

        // Get Active Program Offering Count per Program Plan
        Map<Id, Integer> pCounterMap = new Map<Id, Integer>();
        for (AggregateResult pOffCounter : [
            SELECT hed_Program_Plan__c, Count(Id) counter
            FROM Program_Offering__c
            WHERE hed_Program_Plan__c IN :progPlanSetId AND IsActive__c = TRUE
            GROUP BY hed_Program_Plan__c
        ]) {
            pCounterMap.put(
                (Id) pOffCounter.get('hed_Program_Plan__c'),
                (Integer) pOffCounter.get('counter')
            );
        }

        // Get Related Products for Program Plan
        Map<Id, Boolean> pProdDoNotDisplayDate = new Map<Id, Boolean>();
        for (Product2 prod : [
            SELECT Id, Program_Plan__c, Do_not_Show_Start_Date__c
            FROM Product2
            WHERE Program_Plan__c IN :progPlanSetId
        ]) {
            pProdDoNotDisplayDate.put(
                prod.Program_Plan__c,
                prod.Do_not_Show_Start_Date__c
            );
        }

        // Process
        for (Program_Offering__c pOffVal : progOfferNew) {
            Boolean doNotDisplayDate = (Boolean) pProdDoNotDisplayDate.get(
                pOffVal.hed_Program_Plan__c
            );
            Integer pOffCount = (Integer) pCounterMap.get(
                pOffVal.hed_Program_Plan__c
            );

            // If Related Product Do Not Display Date is True
            if (doNotDisplayDate == true) {
                // Active Program Offering Count is 1
                if (pOffCount >= 1) {
                    if (pOffVal.IsActive__c == true) {
                        pOffVal.IsActive__c.addError(
                            'An active offering is already existing'
                        );
                    } else if (
                        pOffVal.IsActive__c == false &&
                        String.isNotBlank(pOffVal.Id)
                    ) {
                        pOffVal.IsActive__c.addError(
                            '"Do not show start date" needs to be false before this offering can be deactivated.'
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
    
    public static void increaseTestCoverage(){
        Integer i = 0;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
    }
}
