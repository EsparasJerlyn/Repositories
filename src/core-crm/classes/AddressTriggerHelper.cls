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
        for(hed__Address__c address : addressList){

            if(
                address.hed__Parent_Contact__c != null && 
                address.hed__Address_Type__c != null && 
                address.hed__Address_Type__c == AddressesDAO.OTHER_ADDRESS
            ){
                addressByContactMap.put(address.hed__Parent_Contact__c, address);
            }
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(addressByContactMap.keySet(), AccessLevel.SYSTEM_MODE));
        Map<Id, Contact> filteredContactMap = new Map<Id, Contact>();
        Map<Id, hed__Address__c> addressMap = new Map<Id, hed__Address__c>();
        for(hed__Address__c address : addressByContactMap.values()){
            if(contactMap.containsKey(address.hed__Parent_Contact__c) && contactMap.get(address.hed__Parent_Contact__c).QUT_Student__c){
                addressMap.put(address.Id, address);
                filteredContactMap.put(address.hed__Parent_Contact__c, contactMap.get(address.hed__Parent_Contact__c));
            }
        }

        processValidation(addressMap, filteredContactMap);
    }
    
    private static void processValidation (Map<Id, hed__Address__c> addressMap, Map<Id, Contact> contactMap){
        if(!addressMap.isEmpty() && !contactMap.isEmpty()){
            AddressesValidationBatch batch = new AddressesValidationBatch(addressMap.keySet(), contactMap);
            Database.executeBatch(batch);
        }
    }

    public static void processValidateAddress(List<hed__Address__c> addressList, Map<Id, hed__Address__c> oldItems){       
        List<hed__Address__c> validatedAddressList = new List<hed__Address__c>();
        Set<Id> addressIds = new Set<Id>();
        for(hed__Address__c address : addressList){

            Boolean isAddressValidationSuccess =  address.hed__Parent_Contact__c != null && 
                                                  address.hed__Address_Type__c != null && 
                                                  address.Address_Integration_Status__c != oldItems.get(address.Id).Address_Integration_Status__c &&
                                                  address.Address_Integration_Status__c == AddressesDAO.INTEGRATION_STATUS_SUCCESS &&
                                                  address.Validated__c == AddressesDAO.VALID_ADDRESS;
                
            //if the address is successfully validated
            if (isAddressValidationSuccess) {
                addressIds.add(address.Id);
                validatedAddressList.add(address);
            }
        }
        
        if(!addressIds.isEmpty()){
            // call the method to validate Address
            AddressesValidationBatch batch = new AddressesValidationBatch(addressIds);
            Database.executeBatch(batch);
            
        }
    }    
}