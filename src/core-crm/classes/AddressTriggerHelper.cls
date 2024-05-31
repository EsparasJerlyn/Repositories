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

        Map<Id, hed__Address__c> addressByContactMap = new Map<Id, hed__Address__c>();
        for(hed__Address__c address : addressList){

            if(
                address.hed__Parent_Contact__c != null && 
                address.hed__Address_Type__c != null && 
                address.hed__Address_Type__c == AddressesDAO.ADDRESS_TYPE_OTHER
            ){
                addressByContactMap.put(address.hed__Parent_Contact__c, address);
            }
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(addressByContactMap.keySet(), AccessLevel.SYSTEM_MODE));
        List<hed__Address__c> addressListForValidation = new List<hed__Address__c>();
        for(hed__Address__c address : addressByContactMap.values()){
            if(contactMap.containsKey(address.hed__Parent_Contact__c) && contactMap.get(address.hed__Parent_Contact__c).QUT_Student__c){
                addressListForValidation.add(address);
            }
        }

        if(!addressListForValidation.isEmpty()){
            AddressesValidationBatch batch = new AddressesValidationBatch(addressListForValidation);
            Database.executeBatch(batch);
        }
    }

}