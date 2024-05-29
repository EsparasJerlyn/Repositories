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
    
    public static void processValidation(List<hed__Address__c> addressList){

        Set<Id> addressIdSet = new Set<Id>();
        for(hed__Address__c address : addressList){

            if(
                address.hed__Parent_Contact__c != null && 
                address.hed__Address_Type__c != null && 
                address.hed__Address_Type__c == AddressesDAO.ADDRESS_TYPE_OTHER
            ){
                addressIdSet.add(address.Id);
            }
        }

        if(!addressIdSet.isEmpty()){
            AddressValidationBatch batch = new AddressValidationBatch();
            batch.validateAddress(addressIdSet);
        }
    }

}