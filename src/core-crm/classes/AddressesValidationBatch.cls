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
public with sharing class AddressesValidationBatch implements Database.Batchable<hed__Address__c>, Database.AllowsCallouts {
    
    private List<hed__Address__c> addressList;

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public AddressesValidationBatch(){}

    public AddressesValidationBatch(List<hed__Address__c> addressList){
        this.addressList = addressList;
    }
    
    public List<hed__Address__c> start(Database.BatchableContext bc){
        return addressList;
    }    

    public void execute(Database.BatchableContext bc, List<hed__Address__c> addressList){
        processValidation(addressList);
    }  

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}

    public void processValidation(List<hed__Address__c> addressList){
        try{ 
            Map<Id, hed__Address__c> addressByContactMap = new AddressValidation(addressList).validateAddresses();

            ABS_Categorisation__c absCategorisation = new ABS_Categorisation__c();
            List<ABS_Categorisation__c> absCategorisationList = ABSCategorisationsDAO.newInstance().getLatestUpdatedActiveCategorisationRecord('USER_MODE');
            for(ABS_Categorisation__c absCateg : absCategorisationList){
                absCategorisation = absCateg;
            }

            List<Contact> contactsToUpdate = new List<Contact>();
            List<hed__Address__c> addressToUpdate = new List<hed__Address__c>();
            for(Id contactId : addressByContactMap.keySet()){

                hed__Address__c address = addressByContactMap.get(contactId);
                address.ABS_Categorisation__c = absCategorisation?.Id;
                addressToUpdate.add(address);

                contactsToUpdate.add(
                    new Contact(
                        Id = contactId,
                        Low_Socio_Economic_Status__c = AddressValidationManager.setLowSocioEconomicStatus(address, absCategorisation)
                    )
                );
            }
            
            if(!contactsToUpdate.isEmpty()){
                ContactsDAO.newInstance().updateRecords(contactsToUpdate, true, AccessLevel.USER_MODE);
            }

            if(!addressToUpdate.isEmpty()){
                AddressesDAO.newInstance().updateRecords(addressToUpdate, true, AccessLevel.USER_MODE);
            }

        }catch(Exception e){
            Logger.error('Exception caught in execute method in Apex class AddressesValidationBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

}