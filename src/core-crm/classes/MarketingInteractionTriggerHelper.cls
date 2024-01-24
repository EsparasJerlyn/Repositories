/**
 * @description helper class for MarketingInteractionTriggerHandler
 * @see MarketingInteractionTriggerHandler
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                 |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------------|
      | roy.nino.s.regala              | Nov 28, 2023          | DEPP-6879              | Created File                                                   |
 */
public with sharing class MarketingInteractionTriggerHelper {

    public static void mapMarketingFields(List<Marketing_Interaction__c> newItems){

        //ensure that there are no duplicate contacts
        Map<Id,Contact> contactsToUpdate = new Map<Id,Contact>();
        Contact con;
        for(Marketing_Interaction__c marInt: newItems){
            //ensure that there is a contact record
            if(marInt.Contact__c == null){
                continue;
            }

            con = new Contact();
            con.Id = marInt.Contact__c;
            //update the marketing fields of the contact
            MarketingService.optInOrOutMarketing(con, true);
            contactsToUpdate.put(con.Id,con);
        }

        if(!contactsToUpdate.isEmpty()){
            ContactsDAO.newInstance().updateRecords(contactsToUpdate.values(),false,AccessLevel.SYSTEM_MODE);
        }
    }
}