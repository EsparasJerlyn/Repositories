/**
 * @description helper Class for MarketingSegmentationTriggerHelper
 * @see ..MarketingSegmentationTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | Oct 25, 2022          | DEPP-4327              | Created file                                   |
 */

public without sharing class MarketingSegmentationTriggerHelper{


    /**
     * @description create contact record from marketing staging fields
     * @param newItems - map of new marketing staging records
     */
    public static void setSegmentationAsParent(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
       Map<Id,Contact> contactsToUpdate = new Map<Id,Contact>();
       Map<Id,Lead> leadsToUpdate = new Map<Id,Lead>();

       for(Marketing_Segmentation__c marSeg: (List<Marketing_Segmentation__c>)newItems.values()){
            if(oldItems == null){ // if segmentation is inserted
                if(marSeg.Lead__c != null){ // if segmentation is related to a lead
                    leadsToUpdate.put(marSeg.Lead__c, new Lead(Id = marSeg.Lead__c, Marketing_Segmentation__c = marSeg.Id));
                }
                if(marSeg.Contact__c != null){// if segmentation is related to a contact
                    contactsToUpdate.put(marSeg.Contact__c, new Contact(Id = marSeg.Contact__c, Marketing_Segmentation__c = marSeg.Id));
                }
            }else if(marSeg.Lead__c != oldItems.get(marSeg.Id).get('Lead__c') && marSeg.Lead__c != null){ // if segmentation's lead is updated
                leadsToUpdate.put(marSeg.Lead__c, new Lead(Id = marSeg.Lead__c, Marketing_Segmentation__c = marSeg.Id));
                //nullify marketing segmentation of old lead
                if(oldItems.get(marSeg.Id).get('Lead__c') != null){
                    leadsToUpdate.put((Id)oldItems.get(marSeg.Id).get('Lead__c'), new Lead(Id = (Id)oldItems.get(marSeg.Id).get('Lead__c'), Marketing_Segmentation__c = null));
                }
            }else if(marSeg.Contact__c != oldItems.get(marSeg.Id).get('Contact__c') && marSeg.Contact__c != null){// if segmentation's contact is updated
                contactsToUpdate.put(marSeg.Contact__c, new Contact(Id = marSeg.Contact__c, Marketing_Segmentation__c = marSeg.Id));
                //nullify marketing segmentation of old contact
                if(oldItems.get(marSeg.Id).get('Contact__c') != null){
                    contactsToUpdate.put((Id)oldItems.get(marSeg.Id).get('Contact__c'), new Contact(Id = (Id)oldItems.get(marSeg.Id).get('Contact__c'), Marketing_Segmentation__c = null));
                }
            }
       }

       if(!contactsToUpdate.keySet().isEmpty()){
        //update parent contact
        update contactsToUpdate.values();
       }

       if(!leadsToUpdate.keySet().isEmpty()){
        //update parent lead
        update leadsToUpdate.values();
       }

    }
}