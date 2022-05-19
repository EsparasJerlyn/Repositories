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
      | marygrace.li@qut.edu.au        | May 19, 2022          | DEPP-2675            | Added filter to query        | 
 */

public with sharing class ContactLookupCtrl {

   /**
   * @description retrieve all contacts
   * @return list of contact object
   */
   @AuraEnabled(cacheable=true)
   public static List<Contact> getContactRecords(Id accountId){
      
      List<Contact> contactList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId=:accountId]; 
      return contactList;
   }
}