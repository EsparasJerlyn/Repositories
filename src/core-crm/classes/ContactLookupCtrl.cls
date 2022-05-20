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
	   | marygrace.li@qut.edu.au        | May 20, 2022          | DEPP-2675            | Revised & add affliation     | 
 */

public with sharing class ContactLookupCtrl {

   /**
   * @description retrieve all affliated contacts
   * @return list of affliated contact
   */
   @AuraEnabled(cacheable=true)
   public static List<Contact> getContactRecords(Id accountId){
      
      List<Contact> contactList = [SELECT Name, Id FROM Contact WHERE Id IN 
                                   	(SELECT hed__Contact__c  FROM hed__Affiliation__c  WHERE hed__Account__c =:accountId)
                                  ];
      return contactList;
   }
}