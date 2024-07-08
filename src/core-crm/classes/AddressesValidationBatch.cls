/**
 * @description Batch class to process address validation from hed__Address__c after insert trigger
 * @see AddressTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.karl.munoz            | May 29, 2024          | DEPP-8955              | Created file                 |
 */
public with sharing class AddressesValidationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    private Set<Id> addressIds;
    private Map<Id, Contact> contactMap;
    private Boolean isUpdatedMailingAddress;

    public AddressesValidationBatch(Set<Id> addressIds){
        this.addressIds = addressIds;
    }

    public AddressesValidationBatch(Set<Id> addressIds, Map<Id, Contact> contactMap, Boolean isUpdatedMailingAddress){
        this.addressIds = addressIds;
        this.contactMap = contactMap;
        this.isUpdatedMailingAddress = isUpdatedMailingAddress;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return AddressesDAO.newInstance().getQueryLocatorByIds(addressIds);
    }    

    public void execute(Database.BatchableContext bc, List<hed__Address__c> addressList){
        AddressValidationManager addressValidation;
        if(contactMap != null){
            if(isUpdatedMailingAddress){
                for(hed__Address__c address : addressList){
                    address.Statistical_Area_1_Id__c = null;
                    address.Meshblock_Id__c = null;                
                    address.Socio_Economic_Percentile__c = null;
                    address.Remoteness_Class__c = null;
                    address.GNAF_Id__c = null;
                    address.Validated__c = null;
                    address.ABS_Categorisation__c = null;
                }
            }
            addressValidation = new AddressValidationManager(addressList, contactMap);
            addressValidation.processValidationForAddress();
        }else{
            addressValidation = new AddressValidationManager(addressList);
            addressValidation.processValidateAddress();
        }
    }  

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}

}