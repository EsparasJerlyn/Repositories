/**
 * @description Helper class for AddressTrigger
 * @see AddressTrigger
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.karl.munoz            | May 29, 2024          | DEPP-8955              | Created file                 |
 */
public with sharing class AddressTriggerHelper {
    
    public static void validateAddress(List<hed__Address__c> addressList){

        List<Address_Change_Event__e> addressChangeEvents = new List<Address_Change_Event__e>();
        for(hed__Address__c address : addressList){
            if(address.hed__Parent_Contact__c != null){
                addressChangeEvents.add(
                    new Address_Change_Event__e(
                        Address_Id__c = address.Id, 
                        Address_Type__c = address.hed__Address_Type__c,
                        Change_Type__c = 'Insert'
                    )
                );
            }
        }

        try {
            EventBus.publish(addressChangeEvents);
        } catch (Exception e) {
            // prettier-ignore
            NebulaLoggerService.logExceptionDetails('Exception caught in validateAddress method.', e);
        }
        
    }

    public static void processValidateAddress(List<hed__Address__c> addressList, Map<Id, hed__Address__c> oldItems){  

        Set<Id> addressIds = new Set<Id>();
        List<hed__Address__c> successAddressList = new List<hed__Address__c>();
        List<Address_Change_Event__e> addressChangeEvents = new List<Address_Change_Event__e>();
        
        for(hed__Address__c address : addressList){

            Boolean isAddressValidationSuccess =  address.hed__Parent_Contact__c != null && 
                                                  // collect other and first admitted address types
                                                  (address.hed__Address_Type__c == AddressesDAO.OTHER_ADDRESS || 
                                                  address.hed__Address_Type__c == AddressesDAO.FIRST_ADMITTED_ADDRESS) &&
                                                  address.Address_Integration_Status__c != oldItems.get(address.Id).Address_Integration_Status__c &&
                                                  address.Address_Integration_Status__c == AddressesDAO.INTEGRATION_STATUS_SUCCESS &&
                                                  address.Validated__c == AddressesDAO.VALID_ADDRESS;
                
            //if the address is successfully validated
            if (isAddressValidationSuccess) {
                addressIds.add(address.Id);
                successAddressList.add(address);
            }

            Boolean isMailingAddressUpdated =   address.hed__Parent_Contact__c != null &&                             
                                                (address.hed__MailingStreet__c != oldItems.get(address.Id).hed__MailingStreet__c ||
                                                address.hed__MailingCity__c != oldItems.get(address.Id).hed__MailingCity__c ||
                                                address.hed__MailingPostalCode__c != oldItems.get(address.Id).hed__MailingPostalCode__c ||
                                                address.hed__MailingState__c != oldItems.get(address.Id).hed__MailingState__c ||
                                                address.hed__MailingCountry__c != oldItems.get(address.Id).hed__MailingCountry__c);
  
            //if the address mailing fields is/are updated                                    
            if(isMailingAddressUpdated){
                addressChangeEvents.add(
                    new Address_Change_Event__e(
                        Address_Id__c = address.Id, 
                        Address_Type__c = address.hed__Address_Type__c,
                        Change_Type__c = 'Update'
                    )
                );
            }   
        }
        Boolean isAsyncProcess = System.isQueueable() || System.isFuture() || System.isBatch();

        if(!addressIds.isEmpty()){
            // call the method to validate Address
            if (isAsyncProcess) {
                //Current transaction is running asynchronously
                AddressValidationManager addressValidation = new AddressValidationManager(successAddressList);
                addressValidation.processValidateAddress();           
             } else {
                //Current transaction is not running asynchronously
                AddressesValidationBatch batch = new AddressesValidationBatch(addressIds);
                Database.executeBatch(batch);
            }

        }

        if(!addressChangeEvents.isEmpty()){
            try {
                EventBus.publish(addressChangeEvents);
            } catch (Exception e) {
                // prettier-ignore
                NebulaLoggerService.logExceptionDetails('Exception caught in processValidateAddress method.', e);
            }
        }
    }    

}