/**
 * @description helper class to map case marketing fields
 * @see ..CaseTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                                       |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------------|
 *    | roy.nino.s.regala              | November 01, 2023     | DEPP-7060              | Created file to handle case marketing fields mapping |
 */
public with sharing class CaseMarketingHelper {
    private static final List<String> MARKETING_FIELDS = new List<String>{
        'My_Country_Of_Citizenship__c',
        'My_Citizenship_Status__c',
        'My_Country_Of_Residency__c',
        'My_Education_Level__c',
        'My_Primary_Study_Level__c'
    };

    public static void mapMarketingFieldsFromCase(List<Case> newItems, Map<Id, Case> oldItems) {
        Boolean isInsert = oldItems == null;

        //map that groups contact/lead to its potential new Email_Opt_In_DateTime__c
        Map<Id, Datetime> recordIdsWithDateTimeMap = new Map<Id, Datetime>();
        //map that groups contact/lead to its updated marketing segmentation record
        Map<Id, Marketing_Segmentation__c> parentIdToMarketingSegmentation = new Map<Id, Marketing_Segmentation__c>();

        for (Case caseRecord : newItems) {
            //check if case is new linked to contact/lead
            Boolean isNewContactLinked =
                caseRecord.ContactId != null &&
                (isInsert || oldItems.get(caseRecord.Id).ContactId != caseRecord.ContactId);
            Boolean isNewLeadLinked =
                caseRecord.Lead__c != null &&
                (isInsert || oldItems.get(caseRecord.Id).Lead__c != caseRecord.Lead__c);

            //map case marketing fields to new instance of marketing segmentation
            if (isNewContactLinked) {
                mapMarketingSegmenationFields(
                    caseRecord.ContactId,
                    caseRecord,
                    parentIdToMarketingSegmentation
                );
            }else if (isNewLeadLinked) {
                mapMarketingSegmenationFields(
                    caseRecord.Lead__c,
                    caseRecord,
                    parentIdToMarketingSegmentation
                );
            }

            processEmailOptInDateToBeUpdated(recordIdsWithDateTimeMap, caseRecord, oldItems);
        }

        updateMarketingSegmentationRecords(parentIdToMarketingSegmentation);
        updateLeadAndContactOptInDates(recordIdsWithDateTimeMap);
    }

    private static void mapMarketingSegmenationFields(
        Id parentId,
        Case caseRecord,
        Map<Id, Marketing_Segmentation__c> parentIdToMarketingSegmentation
    ) {
        Marketing_Segmentation__c marSegRecord = new Marketing_Segmentation__c();

        //maps case marketing fields to marketing segmentation if not empty
        //e.g Case.My_Country_Of_Citizenship__c -> Marketing_Segmentation__r.My_Country_Of_Citizenship__c
        //see MARKETING_FIELDS static variable
        for (String marketingField : MARKETING_FIELDS) {
            if (String.isNotBlank((String) caseRecord.get(marketingField))) {
                marSegRecord.put(marketingField, (String) caseRecord.get(marketingField));
                parentIdToMarketingSegmentation.put(parentId, marSegRecord);
            }
        }
    }

    private static void updateMarketingSegmentationRecords(
        Map<Id, Marketing_Segmentation__c> parentIdToMarketingSegmentation
    ) {
        List<Marketing_Segmentation__c> marketingSegmentationsToUpdate = new List<Marketing_Segmentation__c>();
        Marketing_Segmentation__c marSegTemp;

        if (parentIdToMarketingSegmentation.keySet().isEmpty()) {
            return;
        }

        //get marketing segmentations related to the contact/lead
        //ideally, marketing segmentation has a 1:1 relationship to contact/lead
        for (
            Marketing_Segmentation__c marSeg : MarketingSegmentationsDAO.newInstance()
                .getMarketingSegmentationByContactOrLead(
                    parentIdToMarketingSegmentation.keySet(),
                    parentIdToMarketingSegmentation.keySet(),
                    AccessLevel.SYSTEM_MODE
                )
        ) {
            //set marketing segmentation fields from case
            marSegTemp = new Marketing_Segmentation__c();

            //construct marketing segmentation records to update using the contact/lead relationship
            Boolean containsContact = marSeg.Contact__c != null && parentIdToMarketingSegmentation.containsKey(marSeg.Contact__c);
            Boolean containsLead = marSeg.Lead__c != null && parentIdToMarketingSegmentation.containsKey(marSeg.Lead__c);
            if (containsContact) {
                marSegTemp = parentIdToMarketingSegmentation.get(marSeg.Contact__c);
                marSegTemp.Id = marSeg.Id;
                marketingSegmentationsToUpdate.add(marSegTemp);
            } else if (containsLead) {
                marSegTemp = parentIdToMarketingSegmentation.get(marSeg.Lead__c);
                marSegTemp.Id = marSeg.Id;
                marketingSegmentationsToUpdate.add(marSegTemp);
            }
        }

        if (!marketingSegmentationsToUpdate.isEmpty()) {

            //this process remove duplicates by force
            Map<Id,Marketing_Segmentation__c> uniqueMarketingSegmentations = new Map<Id,Marketing_Segmentation__c>();
            uniqueMarketingSegmentations.putAll(marketingSegmentationsToUpdate);

            MarketingSegmentationsDAO.newInstance()
                .updateRecords(
                    uniqueMarketingSegmentations.values(),
                    false,
                    AccessLevel.SYSTEM_MODE
                );
        }
    }

    private static void processEmailOptInDateToBeUpdated(
        Map<Id, Datetime> recordIdsWithDateTimeMap,
        Case caseRecord,
        Map<Id, Case> oldItems
    ) {
        Boolean isInsert = oldItems == null;

        //check if case has a contact/lead
        //and if case is marketing opt in true
        //and when case is newly created
        //or when lead or contact is newly linked to case
        Boolean isNewOrUpdatedContact =
            caseRecord.ContactId != null &&
            (isInsert || oldItems.get(caseRecord.Id).ContactId != caseRecord.ContactId);
        Boolean isNewOrUpdatedLead =
            caseRecord.Lead__c != null &&
            (isInsert || oldItems.get(caseRecord.Id).Lead__c != caseRecord.Lead__c);

        Boolean isOptInToTrueForContact = caseRecord.Marketing_Opt_In__c && isNewOrUpdatedContact;
        Boolean isOptInToTrueForLead = caseRecord.Marketing_Opt_In__c && isNewOrUpdatedLead;

        //collect contact ids and its new Email_Opt_In_DateTime__c
        if (isOptInToTrueForContact) {
            recordIdsWithDateTimeMap.put(caseRecord.ContactId, caseRecord.CreatedDate);
        }

        //collect lead ids and its new Email_Opt_In_DateTime__c
        if (isOptInToTrueForLead) {
            recordIdsWithDateTimeMap.put(caseRecord.Lead__c, caseRecord.CreatedDate);
        }
    }

    private static void updateLeadAndContactOptInDates(Map<Id, Datetime> recordIdsWithDateTimeMap) {
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Lead> leadsToUpdate = new List<Lead>();

        if (recordIdsWithDateTimeMap.keySet().isEmpty()) {
            return;
        }

        //get contact fields
        //and check if Email_Opt_In_DateTime__c is already populated
        //and update email opt in date of contact to Case.Createddate
        for (
            Contact contactRecord : ContactsDAO.newInstance()
                .getPersonContactsBySetIds(
                    recordIdsWithDateTimeMap.keySet(),
                    AccessLevel.SYSTEM_MODE
                )
        ) {
            boolean isConUpdateDateTime = contactRecord.HasOptedOutOfEmail == true ||
                                    contactRecord.Email_Opt_In_DateTime__c == null;
            if (
                isConUpdateDateTime
            ) {
                contactsToUpdate.add(
                    new Contact(
                        Id = contactRecord.Id,
                        Email_Opt_In_DateTime__c = recordIdsWithDateTimeMap.get(contactRecord.Id),
                        HasOptedOutOfEmail = false
                    )
                );
            }
        }

        //get lead fields
        //and check if Email_Opt_In_DateTime__c is already populated
        //and update email opt in date of lead to Case.Createddate
        for (
            Lead leadRecord : LeadsDAO.newInstance()
                .getLeadsByIdSet(recordIdsWithDateTimeMap.keySet(), AccessLevel.SYSTEM_MODE)
        ) {
            boolean isLeadUpdateDateTime = leadRecord.HasOptedOutOfEmail == true ||
                                        leadRecord.Email_Opt_In_DateTime__c == null;
            if (
                isLeadUpdateDateTime
            ) {
                leadsToUpdate.add(
                    new Lead(
                        Id = leadRecord.Id,
                        Email_Opt_In_DateTime__c = recordIdsWithDateTimeMap.get(leadRecord.Id),
                        HasOptedOutOfEmail = false
                    )
                );
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            ContactsDAO.newInstance()
                .updateRecords(contactsToUpdate, false, AccessLevel.SYSTEM_MODE);
        }

        if (!leadsToUpdate.isEmpty()) {
            LeadsDAO.newInstance().updateRecords(leadsToUpdate, false, AccessLevel.SYSTEM_MODE);
        }
    }
}
