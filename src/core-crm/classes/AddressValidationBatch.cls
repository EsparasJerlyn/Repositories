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
public with sharing class AddressValidationBatch implements Database.Batchable<sObject> {
    
    private Set<Id> addressIdSet;

    public void validateAddress(Set<Id> addressIdSet){
        this.addressIdSet = addressIdSet;
        Database.executeBatch(this);
    }

    /**
    * @description Retrieves all address that belongs to Contact with QUT Student = true
    * @param bc - BatchableContext
    * @return query - filtered query of lead score details
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        return AddressesDAO.newInstance().getQueryLocatorByIds(addressIdSet);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param addressList - List of hed__Address__c
    */
    public void execute(Database.BatchableContext bc, List<hed__Address__c> addressList){
        try{ 

            Map<Id, hed__Address__c> addressByContactMap = new Map<Id, hed__Address__c>();
            addressByContactMap = AddressValidation.validateAddress(addressList);
            

            //query abs

            List<Contact> contactsToUpdate = new List<Contact>();
            for(Id contactId : addressByContactMap.keySet()){
                Contact contact = new Contact();
                contactsToUpdate.add(
                    new Contact(
                        Id = contact.Id,
                        Low_Socio_Economic_Status__c = 'Yes' //method to get low socio using abs and value of map
                    )
                );
            }

            if(!contactsToUpdate.isEmpty()){
                ContactsDAO.newInstance().updat
            }

            //addressByContactMap.value. ABS = yung na soql sa taas
            update hed__Address__c.values();

        }catch(Exception e){
            Logger.error('Exception caught in execute method in Apex class AddressValidationBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}

}