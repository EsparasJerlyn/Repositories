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
	
    private List<SObject> recordList;
        
    public ContactAddressValidationBatch(List<SObject> recordList) {
        this.recordList = recordList;
    }
    
   /**
    * @description return the list of addresses 
    * @param bc - BatchableContext
    * @return List<SObject> recordList - contains addresses object list
    */

    public List<SObject> start(Database.BatchableContext context)
    {
        return recordList;
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
    public void finish(Database.BatchableContext bc) {

    }
}