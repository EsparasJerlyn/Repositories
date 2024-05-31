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
public with sharing class AddressesValidationBatch implements Database.Batchable<sObject> {
    
    private List<hed__Address__c> addresses;

    public AddressesValidationBatch(List<hed__Address__c> addresses){
        this.addresses = addresses;
    }
    
    public List<hed__Address__c> start(Database.BatchableContext bc){
        return addresses;
    }

    public void execute(Database.BatchableContext bc, List<hed__Address__c> addressList){
        try{ 

            Map<Id, hed__Address__c> addressByContactMap = new Map<Id, hed__Address__c>();
            //addressByContactMap = AddressValidation.validateAddresses(addressList);
            
            ABS_Categorisation__c absCategorisation = new ABS_Categorisation__c();
            List<ABS_Categorisation__c> absCategorisationList = [SELECT Id, Low_SES_Lower_Boundary__c, Low_SES_Upper_Boundary__c FROM ABS_Categorisation__c Order by LastModifiedDate DESC];
            for(ABS_Categorisation__c absCateg : absCategorisationList){
                absCategorisation = absCateg;
            }

            List<Contact> contactsToUpdate = new List<Contact>();
            List<hed__Address__c> addressToUpdate = new List<hed__Address__c>();
            for(Id contactId : addressByContactMap.keySet()){

                hed__Address__c address = addressByContactMap.get(contactId);
                address.ABS_Categorisation__c = absCategorisation?.Id;
                addressToUpdate.add(address);

                Contact contact = new Contact();
                contactsToUpdate.add(
                    new Contact(
                        Id = contact.Id,
                        Low_Socio_Economic_Status__c = setLowSocioEconomicStatus(absCategorisation, address)
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

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}

    private String setLowSocioEconomicStatus(ABS_Categorisation__c absCategorisation, hed__Address__c address){
        String lowSocioEcoStatus = 'No';
        if(
            address.Validated__c == 'Validated' && 
            address.Socio_Economic_Percentile__c >= absCategorisation.Low_SES_Lower_Boundary__c && 
            address.Socio_Economic_Percentile__c <= absCategorisation.Low_SES_Upper_Boundary__c
        ){
            lowSocioEcoStatus = 'Yes';
        }
        return lowSocioEcoStatus;
    }

}