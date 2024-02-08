/**
  * @description helper Class for MarketingSegmentationTriggerHelper
  * @see ..MarketingSegmentationTriggerHandler
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
  *    |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
  *    | roy.nino.s.regala              | Oct 25, 2022          | DEPP-4327              | Created file                                     |
  *    | alexander.cadalin              | Aug 15, 2023          | DEPP-6124              | Rework contact/lead update logic                 |
  *    | roy.nino.s.regala              | Feb 5, 2024           | DEPP-7742              | update to a without sharing context for site user|
  */

public with sharing class MarketingSegmentationTriggerHelper{
    
    /** 
      * @description Perform field updates on the related contact of the inserted marketing segmentations passing thru the trigger.
      * @param newItems A map of inserted marketing segmentation records
      */
    public static void updateRelatedRecords(Map<Id, SObject> newItems) {
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        Map<Id, Lead> leadsToUpdate = new Map<Id, Lead>();

        for(Marketing_Segmentation__c marSeg : (List<Marketing_Segmentation__c>) newItems.values()) {
            // contact updates start here
            setSegmentationOnContact(contactsToUpdate, marSeg);
            // contact updates end here
            // lead updates start here
            setSegmentationOnLead(leadsToUpdate, marSeg);
            // lead updates end here
        }
        if(!contactsToUpdate.keySet().isEmpty()) {
            MarketingSegWithoutSharingService.updateContactRecordsWithoutSharing(contactsToUpdate.values());   
        }
        if(!leadsToUpdate.keySet().isEmpty()) {
            LeadsDAO.newInstance().updateRecords(leadsToUpdate.values(), false, AccessLevel.SYSTEM_MODE);
        }
    }
    
    /** 
      * @description Perform field updates on the related contact of the updated marketing segmentations passing thru the trigger.
      * @param newItems A map of updated marketing segmentation records
      * @param oldItems A map of marketing segmentations before they were updated 
      */
    public static void updateRelatedRecords(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id,Marketing_Segmentation__c> oldMarSegMap = (Map<Id,Marketing_Segmentation__c>) oldItems;
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        Map<Id, Lead> leadsToUpdate = new Map<Id, Lead>();
        Set<Id> segmentationWithUpdatedMovingToBrisbane = new Set<Id>();
        Map<Id, Id> marSegIdToContactIdMap = new Map<Id,Id>();
        for(Marketing_Segmentation__c marSeg: (List<Marketing_Segmentation__c>)newItems.values() ){
            if(marSeg.My_Moving_To_Brisbane__c != oldMarSegMap.get(marSeg.Id).My_Moving_To_Brisbane__c){
                segmentationWithUpdatedMovingToBrisbane.add(marSeg.Id);
            }
        }
        if(!segmentationWithUpdatedMovingToBrisbane.isEmpty()){
            marSegIdToContactIdMap = getMarSegIdToContactIdMap(segmentationWithUpdatedMovingToBrisbane);
        }

        for(Marketing_Segmentation__c marSeg : (List<Marketing_Segmentation__c>) newItems.values()) {
            Marketing_Segmentation__c oldMarSeg = (Marketing_Segmentation__c) oldItems.get(marSeg.Id);
            // contact updates start here
            setSegmentationOnContact(contactsToUpdate, marSeg, oldMarSeg);
            setMovingToBrisbaneOnContact(contactsToUpdate, marSeg, marSegIdToContactIdMap);
            // contact updates end here
            // lead updates start here
            setSegmentationOnLead(leadsToUpdate, marSeg, oldMarSeg);
            // lead updates end here
        }
        if(!contactsToUpdate.keySet().isEmpty()) {
            MarketingSegWithoutSharingService.updateContactRecordsWithoutSharing(contactsToUpdate.values());   
        }
        if(!leadsToUpdate.keySet().isEmpty()) {
            LeadsDAO.newInstance().updateRecords(leadsToUpdate.values(), false, AccessLevel.SYSTEM_MODE);
        }
    }
    
    /**
     * @description Set an inserted marketing segmentation to its related contact.
     * @param contactsToUpdate The id-contact map to put the updated contact
     * @param marSeg The marketing segmentation
     */
    private static void setSegmentationOnContact(Map<Id, Contact> contactsToUpdate, Marketing_Segmentation__c marSeg) {
        if(marSeg.Contact__c != null) {
            Contact con = getRecordFromContactMap(contactsToUpdate, marSeg.Contact__c);
            con.Marketing_Segmentation__c = marSeg.Id;
            contactsToUpdate.put(con.Id, con);
        }
    }
    
    /**
     * @description Set an updated marketing segmentation to its related contact.
     * @param contactsToUpdate The id-contact map to put the updated contact
     * @param marSeg The marketing segmentation
     * @param oldMarSeg The marketing segmentation before being updated
     */
    private static void setSegmentationOnContact(
        Map<Id, Contact> contactsToUpdate, 
        Marketing_Segmentation__c marSeg, 
        Marketing_Segmentation__c oldMarSeg
    ) {
        if(marSeg.Contact__c != oldMarSeg.Contact__c && marSeg.Contact__c != null) {
            Contact con = getRecordFromContactMap(contactsToUpdate, marSeg.Contact__c);
            con.Marketing_Segmentation__c = marSeg.Id;
            contactsToUpdate.put(con.Id, con);
            
            Contact prevCon = getRecordFromContactMap(contactsToUpdate, oldMarSeg.Contact__c);
            prevCon.Marketing_Segmentation__c = null;
            contactsToUpdate.put(prevCon.Id, prevCon);
        }
    }
    
    /**
     * @description Set an inserted marketing segmentation to its related lead.
     * @param leadsToUpdate The id-lead map to put the updated lead
     * @param marSeg The marketing segmentation
     */
    private static void setSegmentationOnLead(Map<Id, Lead> leadsToUpdate, Marketing_Segmentation__c marSeg) {
        if(marSeg.Lead__c != null) {
            Lead ld = getRecordFromLeadMap(leadsToUpdate, marSeg.Lead__c);
            ld.Marketing_Segmentation__c = marSeg.Id;
            leadsToUpdate.put(ld.Id, ld);
        }
    }
    
    /**
     * @description Set an updated marketing segmentation to its related lead.
     * @param leadsToUpdate The id-lead map to put the updated lead
     * @param marSeg The marketing segmentation
     * @param oldMarSeg The marketing segmentation before being updated
     */
    private static void setSegmentationOnLead(
        Map<Id, Lead> leadsToUpdate, 
        Marketing_Segmentation__c marSeg, 
        Marketing_Segmentation__c oldMarSeg
    ) {
        if(marSeg.Lead__c != oldMarSeg.Lead__c && marSeg.Lead__c != null) {
            Lead ld = getRecordFromLeadMap(leadsToUpdate, marSeg.Lead__c);
            ld.Marketing_Segmentation__c = marSeg.Id;
            leadsToUpdate.put(ld.Id, ld);
            
            Lead prevLd = getRecordFromLeadMap(leadsToUpdate, oldMarSeg.Lead__c);
            prevLd.Marketing_Segmentation__c = null;
            leadsToUpdate.put(prevld.Id, prevLd);
        }
    }
    
    /**
     * @description Set the Moving To Brisbane field of the related contact to match the inserted marketing segmentation's My Moving To Brisbane field.
     * @param contactsToUpdate The id-contacts map to put the updated contact
     * @param marSeg The marketing segmentation
     * @param relatedContactIds A set of Ids of contacts whose marketing segmentation is passing thru the trigger
     */
    private static void setMovingToBrisbaneOnContact(
        Map<Id, Contact> contactsToUpdate, 
        Marketing_Segmentation__c marSeg,
        Map<Id, Id> marSegIdToContactIdMap
    ) {
        if(marSegIdToContactIdMap.containsKey(marSeg.Id)){
            Contact con = getRecordFromContactMap(contactsToUpdate, marSegIdToContactIdMap.get(marSeg.Id));
            con.Moving_to_Brisbane__c = marSeg.My_Moving_To_Brisbane__c;
            contactsToUpdate.put(con.Id, con);
        }
    }
    
    /**
     * @description Get a record from an ids-contact map given a record Id. If it does not exist, it returns a new contact Sobject.
     * @param contactMap The contact map to get the record from
     * @param recordId The record to look for, or to create a new record from.
     * @return Contact
     */
    private static Contact getRecordFromContactMap(Map<Id, Contact> contactMap, Id recordId) {
        if(contactMap.containsKey(recordId)) {
            return contactMap.get(recordId);
        } else {
            return new Contact(Id = recordId);
        }
    }
    
    /**
     * @description Get a record from an ids-lead map given a record Id. If it does not exist, it returns a new lead Sobject.
     * @param leadMap The lead map to get the record from
     * @param recordId The record to look for, or to create a new record from.
     * @return Lead
     */
    private static Lead getRecordFromLeadMap(Map<Id, Lead> leadMap, Id recordId) {
        if(leadMap.containsKey(recordId)) {
            return leadMap.get(recordId);
        } else {
            return new Lead(Id = recordId);
        }
    }
    
    /**
     * @description Get contact records if their marketing segmentation is in the given list.
     * @param marSegList A list of marketing segmentations to check
     * @return A list of contact Ids with marketing segmentations in the given list
     */
    private static Map<Id, Id> getMarSegIdToContactIdMap(Set<Id> marSegIdSet) {
        List<Contact> contacts = [SELECT Id, Marketing_Segmentation__c FROM Contact WHERE Marketing_Segmentation__c IN :marSegIdSet WITH SYSTEM_MODE];
        Map<Id, Id> marSegIdToContactIdMap = new Map<Id, Id>();
        for(Contact con : contacts) {
            marSegIdToContactIdMap.put(con.Marketing_Segmentation__c, con.Id);
        }
        return marSegIdToContactIdMap;
    }

}