/**
 * @description Other Address Change Event Handler class
 * @see OtherAddressChangeEventListener
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | July 18, 2024         | DEPP-9942              | Created file                 |
 */

public with sharing class OtherAddressChangeEventHandler {

    private List<Address_Change_Event__e> addressChangeEventList;
    
    public OtherAddressChangeEventHandler(List<Address_Change_Event__e> addressChangeEventList) {
        this.addressChangeEventList = addressChangeEventList;
    }
    
    /**
    *  main method to handle address records with address type = other
    */
    public void handle() {
        try{

            Set<Id> otherAddressIdsFromInsert = new Set<Id>();
            Set<Id> otherAddressIdsFromUpdate = new Set<Id>();

            for(Address_Change_Event__e addressChangeEvent : addressChangeEventList){
                switch on addressChangeEvent.Address_Type__c{
                    when 'Other'{
                        if(addressChangeEvent.Change_Type__c == 'Insert'){
                            otherAddressIdsFromInsert.add(addressChangeEvent.Address_Id__c);
                        }else if(addressChangeEvent.Change_Type__c == 'Update'){
                            otherAddressIdsFromUpdate.add(addressChangeEvent.Address_Id__c);
                        }
                    }
                }
            }
            
            if(!otherAddressIdsFromInsert.isEmpty()){
                process(otherAddressIdsFromInsert, false);
            }

            if(!otherAddressIdsFromUpdate.isEmpty()){
                process(otherAddressIdsFromUpdate, true);
            }
            
        }catch(Exception e){
            NebulaLoggerService.logExceptionDetails('Exception caught in handle method.', e);
        }

    }

    private static void process(Set<Id> otherAddressIdsFromInsert, Boolean isUpdate){
        if(!otherAddressIdsFromInsert.isEmpty()){
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            List<hed__Address__c> otherAddressList = AddressesDAO.newInstance().getAddressesByIds(otherAddressIdsFromInsert, AccessLevel.SYSTEM_MODE); 
            for(hed__Address__c otherAddress : otherAddressList){
                contactMap.put(
                    otherAddress.hed__Parent_Contact__c, 
                    new Contact(
                        Id = otherAddress.hed__Parent_Contact__c, 
                        QUT_Student__c = otherAddress.hed__Parent_Contact__r.QUT_Student__c,
                        Low_Socio_Economic_Status__c = otherAddress.hed__Parent_Contact__r.Low_Socio_Economic_Status__c
                    )
                );
            } 
            
            AddressesValidationBatch batch = new AddressesValidationBatch(otherAddressIdsFromInsert, contactMap, isUpdate);
            Database.executeBatch(batch);
        }
    }
}