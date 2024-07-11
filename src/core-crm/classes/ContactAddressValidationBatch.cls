/**
 * @description Batch class to validate address of contact 
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      |                                |                       |                        |                              |
      | mark.j.mahilum                 | May 31, 2024          | DEPP-8956              | Created file                 |
 */
public with sharing class ContactAddressValidationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
    private Set<Id> recordIdSet;
        
    public ContactAddressValidationBatch(Set<Id> recordIdSet) {
        this.recordIdSet = recordIdSet;
    }
    
   /**
    * @description Method to query the hed__Address__c records 
    * @param bc - BatchableContext
    * @return query - hed__Address__c records
    */

    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return AddressesDAO.newInstance().getQueryLocatorByIds(recordIdSet);
    }

   /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param List<SObject> sObjectList - list of addresses 
    */
    public void execute(Database.BatchableContext bc, List<SObject> sObjectList){      
        // call the method to validate Address
        AddressValidationManager addressValidation = new AddressValidationManager(sObjectList);
        addressValidation.executeAddressValidation();        
    } 

    /**
    * @description chain current batch job to Complete Cadence job
    * @param bc - BatchableContext
    */
    public void finish(Database.BatchableContext bc) {}//NOPMD
}