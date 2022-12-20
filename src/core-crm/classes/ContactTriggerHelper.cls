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
      | rhea.b.torres                  | December 19, 2022     | DEPP-5002              | Handle email opt-in/opt-out                      |
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
        Map<String,AccountContactRelation> acrToBeInserted = new Map<String,AccountContactRelation>();
        for(Contact con: newItems){
            if( (con.hed__Primary_Organization__c != null &&
                con.hed__Primary_Organization__c != con.AccountId
                && (  oldMap == null || 
                      oldMap.get(con.Id).hed__Primary_Organization__c != con.hed__Primary_Organization__c)
                      )){
                        
                    acrToBeInserted.put(String.valueOf(con.hed__Primary_Organization__c) + String.valueOf(con.Id),
                                        new AccountContactRelation( 
                                            AccountId = con.hed__Primary_Organization__c, 
                                            ContactId = con.Id
                                        ));
            }
        }

        if(!acrToBeInserted.keySet().isEmpty()){
          try{
            insert acrToBeInserted.values();
          }catch(Exception e){
            System.debug('Error creating ACR ' + e.getMessage());
          } 
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

    public static void setupEmailConsentOnInsert(List<Contact> contactList){
      for(Contact contact : contactList){
        /**Email */
        updateEmailConsentDateTime(contact);
        /**Work Email */
        updateWorkEmailConsentDateTime(contact);
        /**QUT Staff Email */
        updateStaffEmailConsentDateTime(contact);
        /**QUT Learner Email */
        updateLearnerEmailConsentDateTime(contact);
      }
    }

    public static void setupEmailConsentOnUpdate(Map<Id, Contact> newContactMap, Map<Id, Contact> oldContactMap){
      for(Id key : newContactMap.keySet()){
        Contact newContact = newContactMap.get(key);
        Contact oldContact = oldContactMap.get(key);

        /**Email */
        if(newContact.HasOptedOutOfEmail != oldContact.HasOptedOutOfEmail){
          updateEmailConsentDateTime(newContact);
        }
        
        /**Work Email */
        if(newContact.Work_Email_Opt_Out__c != oldContact.Work_Email_Opt_Out__c){
          updateWorkEmailConsentDateTime(newContact);
        }

        /**QUT Staff Email */
        if(newContact.Staff_Email_Opt_Out__c != oldContact.Staff_Email_Opt_Out__c){
          updateStaffEmailConsentDateTime(newContact);
        }

        /**QUT Learner Email */
        if(newContact.Learner_Email_Opt_Out__c != oldContact.Learner_Email_Opt_Out__c){
          updateLearnerEmailConsentDateTime(newContact);
        }
      }
    }

    private static void updateEmailConsentDateTime(Contact contact){
      if(contact.HasOptedOutOfEmail){
        contact.Email_Opt_Out_DateTime__c = System.now();
      } else{
        contact.Email_Opt_In_DateTime__c = System.now();
      }
    }

    private static void updateWorkEmailConsentDateTime(Contact contact){
      if(contact.Work_Email_Opt_Out__c){
        contact.Work_Email_Opt_Out_DateTime__c = System.now();
      } else{
        contact.Work_Email_Opt_In_DateTime__c = System.now();
      }
    }

    private static void updateStaffEmailConsentDateTime(Contact contact){
      if(contact.Staff_Email_Opt_Out__c){
        contact.Staff_Email_Opt_Out_DateTime__c = System.now();
      } else{
        contact.Staff_Email_Opt_In_DateTime__c = System.now();
      }
    }

    private static void updateLearnerEmailConsentDateTime(Contact contact){
      if(contact.Learner_Email_Opt_Out__c){
        contact.Learner_Email_Opt_Out_DateTime__c = System.now();
      } else{
        contact.Learner_Email_Opt_In_DateTime__c = System.now();
      }
    }
  }