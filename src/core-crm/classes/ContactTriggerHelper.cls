/**
 * @description helper for ContactTriggerHandler
 * @see ContactTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 09, 2022         | DEPP-2869              | Created file, converted flow |
      |                                |                       |                        |                              |
 */
public without sharing class ContactTriggerHelper {
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    /**
     * @description set primary org business field as account parent field
     * @param conNew - List of Contact.Trigger.new
     */
    public static void setPrimaryBusinessOrgAsParent(List<Contact> conNew) {
      List<Contact> contactsToUpdate = new List<Contact>();
      Set<Id> primaryOrgIds = new Set<Id>();
      for (Contact conVal : conNew) {
        if(conVal.hed__Primary_Organization__c != null){ 
            //update parent account to be the primary organization
            contactsToUpdate.add(new Contact(Id = conVal.Id, AccountId = conVal.hed__Primary_Organization__c));
            primaryOrgIds.add(conVal.hed__Primary_Organization__c);
        }
      }
      if(!contactsToUpdate.isEmpty()){
        update contactsToUpdate;

        deleteAdministrativeAccounts(contactsToUpdate,primaryOrgIds);
      }
    }

    /***
     * @description delete administrative accounts created by eda on insert
     * @param relatedContacts - contacts where primary business org  is set to parent account
     * @param primary business org ids
     */
    public static void deleteAdministrativeAccounts(List<Contact> relatedContacts, Set<Id> primaryOrgIds){
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        List<Account> accountsToDelete = new List<Account>();
        for(AccountContactRelation acr: [SELECT Id, AccountId FROM AccountContactRelation WHERE AccountId NOT IN: primaryOrgIds AND ContactId IN: relatedContacts]){
            accountsToDelete.add(new Account(Id = acr.AccountId));
        }
        if(!accountsToDelete.isEmpty()){
            //delete all administrative accounts created via eda 
            //this will delete ACR as well
            delete accountsToDelete;
        }
    }
    
    /***
     * @description set primary org business field as account parent field
     * @param conNew - trigger.new contacts
     */
    public static void setPrimaryBusinessOrgFromParent(List<Contact> conNew){
        List<Account> businessAccounts = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> businessAccIds = new Set<Id>();
        //get all accountIds from new contacts
        for (Contact conVal : conNew) {
            if(conVal.AccountId != null){
                accountIds.add(conVal.AccountId);
            }
        }

        if(!accountIds.isEmpty()){
            //query account recordtype
            businessAccounts = [SELECT Id FROM Account WHERE Id IN: accountIds AND RecordType.Id =:BUSINESS_ACC_RECTYPEID];
            for(Account acc: businessAccounts){
                businessAccIds.add(acc.Id);
            }
            if(!businessAccIds.isEmpty()){
                for(Contact conVal : conNew){
                    //if parent accounts recordtype is business organization
                    //copy accountid to primary organization field
                    if(businessAccIds.contains(conVal.AccountId)){
                        conVal.hed__Primary_Organization__c = conVal.AccountId;
                    }
                }
            }
            
        }

    }
  }
  