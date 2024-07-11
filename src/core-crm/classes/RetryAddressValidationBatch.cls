/**
 * @description Batch class to process address validation for records with retry integration status
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.karl.munoz            | June 10, 2024         | DEPP-9226              | Created file                 |
 */
public with sharing class RetryAddressValidationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return AddressesDAO.newInstance().getQueryLocatorByIntegrationStatus(new Set<String>{AddressesDAO.INTEGRATION_STATUS_RETRY});
    }    

    public void execute(Database.BatchableContext bc, List<hed__Address__c> addressList){
        try{
            List<AddressValidation.AddressValidationPayloadRequest> addressValidationRequest = new List<AddressValidation.AddressValidationPayloadRequest>();
            for(hed__address__c address: addressList){        
                addressValidationRequest.add(new AddressValidation.AddressValidationPayloadRequest(address.Id)); 
            }
    
            List<hed__address__c> addressToUpdate = new List<hed__address__c>();
            if(!addressValidationRequest.isEmpty()){
    
                Boolean isCalloutSuccess =  AddressValidation.addressValidationRequest(addressValidationRequest);
                
                for(hed__address__c address: addressList){   
                    address.Address_Integration_Status__c = isCalloutSuccess ? AddressesDAO.INTEGRATION_STATUS_SENT : AddressesDAO.INTEGRATION_STATUS_FAILED;
                    addressToUpdate.add(address);        
                }  
            }
    
            if(!addressToUpdate.isEmpty()){
                AddressesDAO.newInstance().updateRecords(addressToUpdate, true, AccessLevel.SYSTEM_MODE);
            }
        }catch(Exception e){
            Logger.error('Exception caught in class RetryAddressValidationBatch.').setExceptionDetails(e);
        }finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}

}