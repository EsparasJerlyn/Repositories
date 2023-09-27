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
      | mark.j.mahilum                 | July 21, 2023         | DEPP-5799              | Added new method to set Person Contact flag      |
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | Added new method to set Can Nurture flag         |
      | julie.jane.alegre              | Sept 14, 2023         | DEPP-6679              | Added new method to create Marketing Segmentation|
      | mark.j.mahilum                 | Sept 22, 2023         | DEPP-6488              | Updated getContactCalculatedCadence to includes  |
      |                                |                       |                        | the automated cadences in the processSaleCadences|
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

   /**
    * @description check or uncheck the QUT_Lead and QUT_Staff base on the contact details
    *
    * @param newItems  List of new Contact records
    */
    public static void setQUTPersonaFlag(List<Contact> newItems){
        for(Contact con: newItems){     
            if(con.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID){
                con.QUT_Lead__c = (con.Lead_Score__c != null && con.Lead_Score__c > 0)? true:false;
                con.QUT_Staff__c = (String.isNotEmpty(con.QUT_Employee_ID__c) && con.Staff_End_Date__c > SYSTEM.today())? true:false;
            }            
        }
    } 
   /**
    * @description check or uncheck the Can_Nurture flag
    *
    * @param newItems  List of new Contact records
    * @param oldItems  Map of old Contact records
    */
    public static void updateCanNurtureFlag(List<Contact> newItems, Map<Id, Contact> oldItems) {   
        
        List<Nurture_Track_Configuration__c> nurtureList = NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackLeadScoreThreshold('SYSTEM_MODE');
        
        for (Contact con : newItems) {			            
            Boolean isLeadScoreNotNull = con.Lead_Score__c != NULL;			                        
            if (oldItems == null && isLeadScoreNotNull) {
                con.Can_Nurture__c = isLeadScoreAboveLeadThreshold(con,nurtureList);
            } else if (oldItems != null) {
                Contact oldContact = oldItems.get(con.Id);
                if(con.Lead_Score__c != oldContact.Lead_Score__c){
                    con.Can_Nurture__c = isLeadScoreNotNull && isLeadScoreAboveLeadThreshold(con,nurtureList);
                }
            }
        }
    }
    
    /**
     * @description Update Moving To Brisbane field on contact insert
     * @param newItem List of new contacts
     */
    public static void updateMovingToBrisbane(List<SObject> newItems) {
        Map<Id, Marketing_Segmentation__c> marSegMap = getMarketingSegmentationsOnContactList((List<Contact>) newitems);
        for(Contact newItem : (List<Contact>) newItems) {
            if(newItem.Marketing_Segmentation__c != null) {
                newItem.Moving_To_Brisbane__c = marSegMap.get(newItem.Marketing_Segmentation__c).My_Moving_To_Brisbane__c;
            }
        }
    }
    
    /**
     * @description Update Moving To Brisbane field on contact with updated marketing segmentation
     * @param newItem Map of updated contacts and their ids
     * @param oldItem Map of outdated contacts and their ids
     */
    public static void updateMovingToBrisbane(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Marketing_Segmentation__c> marSegMap = new Map<Id,Marketing_Segmentation__c>();

        List<Contact> contactsWithMarSeg = new List<Contact>();

        //collect contacts where marketing segmentaion is updated
        for(Contact newItem : (List<Contact>) newItems.values()) {
            Contact oldItem = (Contact) oldItems.get(newItem.Id);
            if(
                newItem.Marketing_Segmentation__c != null && 
                newItem.Marketing_Segmentation__c != oldItem.Marketing_Segmentation__c
            ) {
                contactsWithMarSeg.add(newItem);
            }
        }
        
        //get related marketing segmentation
        if(!contactsWithMarSeg.isEmpty()){
            marSegMap = getMarketingSegmentationsOnContactList(contactsWithMarSeg);
        }

        //update moving to brisbane field
        for(Contact newItem : contactsWithMarSeg) {
            if(marSegMap.containsKey(newItem.Marketing_Segmentation__c)){
                newItem.Moving_To_Brisbane__c = marSegMap.get(newItem.Marketing_Segmentation__c).My_Moving_To_Brisbane__c;
            }
        }
    }

    private static Map<Id, Marketing_Segmentation__c> getMarketingSegmentationsOnContactList(List<Contact> contacts) {
        Map<Id,Marketing_Segmentation__c> marketingSegMap = new Map<Id,Marketing_Segmentation__c>();

        Set<Id> marSegIdsInNewItems = new Set<Id>();
        for(Contact con : (List<Contact>) contacts) {
            if(!String.isBlank(con.Marketing_Segmentation__c)){
                marSegIdsInNewItems.add(con.Marketing_Segmentation__c);
            }
        }

        if(!marSegIdsInNewItems.isEmpty()){
            return new Map<Id, Marketing_Segmentation__c>([
                SELECT Id, My_Moving_To_Brisbane__c 
                FROM Marketing_Segmentation__c 
                WHERE Id IN :marSegIdsInNewItems 
                WITH SYSTEM_MODE
            ]);
        }
        
        return marketingSegMap;
    }
    
   /**
    * @description check if the lead score is above threshold
    *
    * @param Contact con record
    * @param List of Nurture Track Configuration
    */  
    private static Boolean isLeadScoreAboveLeadThreshold(Contact con, List<Nurture_Track_Configuration__c> nurtureList) {        
        for (Nurture_Track_Configuration__c rec: nurtureList) {
            if((con.Lead_Score__c >= rec.Lead_Score_Threshold__c)) return true;
        }
        return false;
    }
   /**
    * @description get the contactIds of the contact who's calculated cadence value is updated
    *
    * @param List<Contact> newItems
    * @param Map<Id, Contact> oldItems
    */         
    public static void getContactCalculatedCadence(List<Contact> newItems, Map<Id, Contact> oldItems) {   
        
        Map<String,String> assignContactToCadenceMap = new Map<String,String>();
        Map<String,String> removeContactToCadenceMap = new Map<String,String>(); 
        
        for (Contact con : newItems) {	
            if(con.RecordTypeId != ContactsDAO.PERSON_RECORDTYPE_ID){
                continue;
            }
            
            Contact oldContact = oldItems.get(con.Id);
            String calculatedCadence = con.Calculated_Cadence__c;
            String oldCalculatedCadence = oldContact.Calculated_Cadence__c;
            
            if(calculatedCadence != oldCalculatedCadence){
                if (String.isNotEmpty(calculatedCadence) && String.isEmpty(oldCalculatedCadence)) {
                    assignContactToCadenceMap.put(con.Id,calculatedCadence);
                } else if (String.isEmpty(calculatedCadence)) {
                    removeContactToCadenceMap.put(con.Id,oldCalculatedCadence);
                }  
            }
        }
        
        if(!assignContactToCadenceMap.isEmpty() || !removeContactToCadenceMap.isEmpty()){
            SalesCadenceCalloutService.processSaleCadences(assignContactToCadenceMap,removeContactToCadenceMap);
        }
    }  
 /**
    * @description create a Marketing Segmentation on the newly created contact
    *
    * @param Map<Id, Contact> newItems
    */         
    public static void createMarketingSegmentation(Map<Id, Contact> newItems) {   
        List<Marketing_Segmentation__c> marketingSegToInsert = new List<Marketing_Segmentation__c>();

        for(Contact contacts: newItems.values()){
            if(contacts.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID && contacts.Marketing_Segmentation__c == null){
                marketingSegToInsert.add(
                    new Marketing_Segmentation__c(
                        Contact__c = contacts.Id
                    )
                );
            }
        }
        if(!marketingSegToInsert.IsEmpty()){
            MarketingSegmentationsDAO.newInstance().insertRecords(marketingSegToInsert, false, AccessLevel.SYSTEM_MODE);
        }
    }

}