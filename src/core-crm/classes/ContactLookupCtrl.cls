/**
 * @description Controller Class for Custom Lookup for Contact
 * @see ../lwc/opportunityCreation
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                 | Change Summary               |
      |--------------------------------|-----------------------|----------------------|------------------------------|
      | marygrace.li@qut.edu.au        | September 20, 2021    | DEP1-158             | Created file                 | 
      |                                |                       |                      |                              | 
 */

public with sharing class ContactLookupCtrl {

   /**
   * @description retrieve all contacts
   * @return list of contact object
   */
   @AuraEnabled(cacheable=true)
   public static List<Contact> getContactRecords(){
       List<Contact> contactList = [SELECT Id, Name, AccountId FROM Contact]; 
       return contactList;
   }
}