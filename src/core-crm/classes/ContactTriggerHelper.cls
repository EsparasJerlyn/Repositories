/**
 * @description helper for ContactTriggerHandler
 * @see ContactTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | roy.nino.s.regala              | June 09, 2022         | DEPP-2869              | Created file, converted flow                     |
      | roy.nino.s.regala              | Sep 10, 2022          | DEPP-4225              | updated to reparet contact and update work email | 
      | john.m.tambasen                | September 23, 2022    | DEPP-4367              | birthdate validation                             |
 */
public without sharing class ContactTriggerHelper {
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    /**
     * @description set the administrative account as parent account
     * @param conNew - List of Contact.Trigger.new
     */
    public static void reparentAccount(List<Contact> newItems) {
        
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Account> businessAccounts = new Map<Id,Account>();

        //get account ids
        for(Contact con:newItems){
          if(con.AccountId != null){ 
            accountIds.add(con.AccountId);
          }
        }
        //get account records recordtype
        if(!accountIds.isEmpty()){
          businessAccounts = new Map<Id,Account>([
            SELECT Id 
            FROM Account
            WHERE Id IN: accountIds
            AND RecordTypeId =: BUSINESS_ACC_RECTYPEID
          ]);
        }

        for(Contact con: newItems){
            //set business org to primary org if RT is business_organization
            if(businessAccounts.containsKey(con.AccountId)){
                con.hed__Primary_Organization__c  = con.AccountId;
                con.AccountId = null;
            }
        }
    }
    
    /***
     * @description create account contact relation records for business org and contact
     * @param conNew - trigger.new contacts
     */
    public static void createAccountContactRelationRecords(List<Contact> newItems, Map<Id,Contact> oldMap){
        //map of acrt to be inserted
        Map<String,AccountContactRelation> acrToBeUpserted = new Map<String,AccountContactRelation>();

        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for(Contact con: newItems){
            if( (con.hed__Primary_Organization__c != null &&
                con.hed__Primary_Organization__c != con.AccountId
                && (  oldMap == null || 
                      oldMap.get(con.Id).hed__Primary_Organization__c != con.hed__Primary_Organization__c)
                      )){
                        
                    //store contact and account ids
                    contactIds.add(con.Id);
                    accountIds.add(con.hed__Primary_Organization__c);

                    //build ACR Record to upsert
                    acrToBeUpserted.put(String.valueOf(con.hed__Primary_Organization__c) + String.valueOf(con.Id),
                                        new AccountContactRelation( 
                                            Id = null,
                                            AccountId = con.hed__Primary_Organization__c,
                                            ContactId = con.Id,
                                            IsActive = true
                                        ));
            //deactivate old ACR when removed
            }else if( con.hed__Primary_Organization__c == null &&
                      oldMap != null &&
                      oldMap.get(con.Id).hed__Primary_Organization__c != con.hed__Primary_Organization__c){

                        contactIds.add(con.Id);
                        accountIds.add(oldMap.get(con.Id).hed__Primary_Organization__c);

                        //build ACR Record to upsert
                        //set previous acr to isactive false
                        acrToBeUpserted.put(String.valueOf(oldMap.get(con.Id).hed__Primary_Organization__c) + String.valueOf(con.Id),
                        new AccountContactRelation(
                            Id = null,
                            AccountId = oldMap.get(con.Id).hed__Primary_Organization__c,
                            ContactId = con.Id,
                            IsActive = false
                        ));
            }
        }

        if(!acrToBeUpserted.isEmpty()){

            acrToBeUpserted  = checkForExistingACR(accountIds, contactIds,acrToBeUpserted);

            upsert acrToBeUpserted.values();

            //deactivate other ACR linked the contact
            deactivateExistingACRRecords(acrToBeUpserted.values(),contactIds);

        }
    }

    private static Map<String, AccountContactRelation> checkForExistingACR(Set<Id> accountIds, Set<Id> contactIds, Map<String,AccountContactRelation> acrToBeUpserted){

        //get all ACR with the same contact and account ids
        List<AccountContactRelation> existingACR = new List<AccountContactRelation>([
            SELECT Id, AccountId, ContactId
            FROM AccountContactRelation
            WHERE AccountId IN: accountIds
            AND ContactId IN: contactIds
        ]);

        for(AccountContactRelation acr: existingACR){
            if( acr.AccountId != null &&
                acr.ContactId != null &&
                acrToBeUpserted.containsKey(String.valueOf(acr.AccountId) + String.valueOf(acr.contactId))){
                  //set the id of the ACR if found
                  //this would set the IsActive status of existing ACR to True
                  acrToBeUpserted.get(String.valueOf(acr.AccountId) + String.valueOf(acr.contactId)).Id = acr.Id;
            }
        }

        return acrToBeUpserted;
    }

    private static void deactivateExistingACRRecords(List<AccountContactRelation> newACRs, Set<Id> contactIds){


      List<AccountContactRelation> acrToDeactivate = new List<AccountContactRelation>([
          SELECT Id, IsActive
          FROM AccountContactRelation
          WHERE ContactId IN: contactIds
          AND Account.RecordType.Name = 'Business Organization'
          AND Id NOT IN: newACRs
          AND IsActive = true
      ]);

      for(AccountContactRelation acr: acrToDeactivate){
          acr.IsActive = false;
      }

      if(!acrToDeactivate.isEmpty()){
          update acrToDeactivate;
      }


    }

    public static void birthdateValidation(List<Contact> newItems){

      // Minimum value for Date of Birth
      Date minDOB = System.Today().addYears(-15);

      for(Contact con: newItems){

        if( con.Birthdate > minDOB ){
            con.Birthdate.addError('Must be 15 years or older to register');
        }
      }
    }

  }