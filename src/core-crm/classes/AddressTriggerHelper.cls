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
        Set<Id> addressIdSet = new Set<Id>();

        for(hed__Address__c address : addressList){

            if(
                address.hed__Parent_Contact__c != null && 
                address.hed__Address_Type__c != null && 
                address.hed__Address_Type__c == AddressesDAO.OTHER_ADDRESS
            ){
                addressByContactMap.put(address.hed__Parent_Contact__c, address);
                addressIdSet.add(address.Id);
            }
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(addressByContactMap.keySet(), AccessLevel.SYSTEM_MODE));
        processValidation(addressIdSet, contactMap);
    }
    
    private static void processValidation (Set<Id> addressIdSet, Map<Id, Contact> contactMap){
        if(!addressIdSet.isEmpty() && !contactMap.isEmpty()){
            AddressesValidationBatch batch = new AddressesValidationBatch(addressIdSet, contactMap, false);
            Database.executeBatch(batch);
        }
    }

    public static void processValidateAddress(List<hed__Address__c> addressList, Map<Id, hed__Address__c> oldItems){  

        Set<Id> addressIds = new Set<Id>();
        Map<Id, hed__Address__c> filteredAddressMap = new Map<Id, hed__Address__c>();
        
        for(hed__Address__c address : addressList){

            Boolean isAddressValidationSuccess =  address.hed__Parent_Contact__c != null && 
                                                  address.hed__Address_Type__c != null && 
                                                  address.Address_Integration_Status__c != oldItems.get(address.Id).Address_Integration_Status__c &&
                                                  address.Address_Integration_Status__c == AddressesDAO.INTEGRATION_STATUS_SUCCESS &&
                                                  address.Validated__c == AddressesDAO.VALID_ADDRESS;
                
            //if the address is successfully validated
            if (isAddressValidationSuccess) {
                addressIds.add(address.Id);
            }

            Boolean isMailingAddressUpdated =   address.hed__Parent_Contact__c != null &&     
                                                address.hed__Address_Type__c != null &&           
                                                address.hed__Address_Type__c == AddressesDAO.OTHER_ADDRESS &&                                 
                                                (address.hed__MailingStreet__c != oldItems.get(address.Id).hed__MailingStreet__c ||
                                                address.hed__MailingCity__c != oldItems.get(address.Id).hed__MailingCity__c ||
                                                address.hed__MailingPostalCode__c != oldItems.get(address.Id).hed__MailingPostalCode__c ||
                                                address.hed__MailingState__c != oldItems.get(address.Id).hed__MailingState__c ||
                                                address.hed__MailingCountry__c != oldItems.get(address.Id).hed__MailingCountry__c) &&
                                                address.Validated__c != AddressesDAO.VALID_ADDRESS; 
  
            //if the address mailing fields is/are updated                                    
            if(isMailingAddressUpdated){
                filteredAddressMap.put(address.hed__Parent_Contact__c, address);
            }   
        }
        
        if(!addressIds.isEmpty()){
            // call the method to validate Address
            AddressesValidationBatch batch = new AddressesValidationBatch(addressIds);
            Database.executeBatch(batch);
            
        }

        if(!filteredAddressMap.isEmpty()){
            processAddressFieldUpdateValidation(filteredAddressMap);
        }
    }    

    private static void processAddressFieldUpdateValidation(Map<Id, hed__Address__c> filteredAddressMap){
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(filteredAddressMap.keySet(), AccessLevel.SYSTEM_MODE));
        if(!contactMap.isEmpty()){
            AddressesValidationBatch batch = new AddressesValidationBatch(new Map<Id, hed__Address__c>(filteredaddressmap.values()).keySet(), contactMap, true);
            Database.executeBatch(batch);
        }
    }
}