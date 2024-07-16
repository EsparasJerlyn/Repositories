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

        Map<Id, hed__Address__c> addressByContactMap = new Map<Id, hed__Address__c>();
        Map<Id, hed__Address__c> addressMap = new Map<Id, hed__Address__c>();

        for(hed__Address__c address : addressList){

            if(
                address.hed__Parent_Contact__c != null && 
                address.hed__Address_Type__c == AddressesDAO.OTHER_ADDRESS
            ){
                addressByContactMap.put(address.hed__Parent_Contact__c, address);
                addressMap.put(address.Id, address); //collect other addresses to a map
            }
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(addressByContactMap.keySet(), AccessLevel.SYSTEM_MODE));
        processValidation(addressMap, contactMap); // validate other addresses
    }
    
    private static void processValidation ( Map<Id, hed__Address__c> addressMap, Map<Id, Contact> contactMap){

        if(addressMap.isEmpty() || contactMap.isEmpty()){
            return;
        }

        Boolean isAsyncProcess = System.isQueueable() || System.isFuture() || System.isBatch();
        
        if(isAsyncProcess){
            AddressValidationManager addressValidation = new AddressValidationManager(addressMap.values(), contactMap, false);
            addressValidation.processValidationForAddress();
        } else{
            AddressesValidationBatch batch = new AddressesValidationBatch(addressMap.keySet(), contactMap, false);
            Database.executeBatch(batch);
        }
    }

    public static void processValidateAddress(List<hed__Address__c> addressList, Map<Id, hed__Address__c> oldItems){  

        Set<Id> addressIds = new Set<Id>();
        Map<Id, hed__Address__c> filteredAddressMap = new Map<Id, hed__Address__c>();
        List<hed__Address__c> successAddressList = new List<hed__Address__c>();
        
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
                                                address.hed__Address_Type__c == AddressesDAO.OTHER_ADDRESS &&                                 
                                                (address.hed__MailingStreet__c != oldItems.get(address.Id).hed__MailingStreet__c ||
                                                address.hed__MailingCity__c != oldItems.get(address.Id).hed__MailingCity__c ||
                                                address.hed__MailingPostalCode__c != oldItems.get(address.Id).hed__MailingPostalCode__c ||
                                                address.hed__MailingState__c != oldItems.get(address.Id).hed__MailingState__c ||
                                                address.hed__MailingCountry__c != oldItems.get(address.Id).hed__MailingCountry__c);
  
            //if the address mailing fields is/are updated                                    
            if(isMailingAddressUpdated){
                filteredAddressMap.put(address.hed__Parent_Contact__c, address);
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

        if(!filteredAddressMap.isEmpty()){
            processAddressFieldUpdateValidation(filteredAddressMap , isAsyncProcess);
        }
    }    

    private static void processAddressFieldUpdateValidation(Map<Id, hed__Address__c> filteredAddressMap , Boolean isAsyncProcess){
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(filteredAddressMap.keySet(), AccessLevel.SYSTEM_MODE));
        if(!contactMap.isEmpty()){
            if(isAsyncProcess){
                //Current transaction is running asynchronously
                AddressValidationManager addressValidation = new AddressValidationManager(filteredAddressMap.values(), contactMap, true );
                addressValidation.processValidationForAddress();
            }else{
                //Current transaction is not running asynchronously
                AddressesValidationBatch batch = new AddressesValidationBatch(new Map<Id, hed__Address__c>(filteredaddressmap.values()).keySet(), contactMap, true);
                Database.executeBatch(batch);
            }

        }
    }
}