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
            addressValidation = new AddressValidationManager(addressList, contactMap, isUpdatedMailingAddress );
            addressValidation.processValidationForAddress();
        }else{
            addressValidation = new AddressValidationManager(addressList);
            addressValidation.processValidateAddress();
        }
    }  

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}

}