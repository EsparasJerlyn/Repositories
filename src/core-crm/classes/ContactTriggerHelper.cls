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
      | johanna.a.gibas                | Oct 25, 2023          | DEPP-6889              | Updated getContactCalculatedCadence to include   |
      |                                |                       |                        |     updateCompletedCadences                      |
      | julie.jane.alegre              | Oct 27, 2023          | DEPP-6955              | Added new method updateRegisteredEmail           |
      | roy.nino.s.regala              | Nov 01, 2023          | DEPP-7105              | updated createMarketingSegmentation to future    |    
 */
public without sharing class ContactTriggerHelper {
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business_Organization')
        .getRecordTypeId();

    /**
     * @description do fast updates and validation for contact(used in Before triggers)
     *
     * @param newItems  List of new Contact records
     * @param oldItems  Map of old Contact records
     */
    public static void fastFieldUpdateAndValidation(
        List<Contact> newItems,
        Map<Id, Contact> oldItems
    ) {

        List<Contact> contactsToRecalculate = new List<Contact>();

        for (Contact con : newItems) {
            Boolean isPerson = ContactsDAO.PERSON_RECORDTYPE_ID == con.RecordTypeId;
            //non person contact process start

            birthDateValidation(con); //validates contact birthdate

            //person contacts processes start
            if (!isPerson) {
                continue;
            }

            setCanNurtureFlag(con, contactsToRecalculate, oldItems); //sets can nurture flag
            setQUTPersonaFlag(con); //sets QUT_Staff__c(Persona Flags) of Contact
            updateRegisteredEmail(con, oldItems); // updates Registered email when match with Primary Email or Work Email
        }

        //processes with soql and dml start
        //recalculate Can Nurture by threshold
        recalculateCanNurture(contactsToRecalculate);
    }

    /**
     * @description set the administrative account as parent account
     * @param conNew - List of Contact.Trigger.new
     */
    public static void reparentAccount(List<Contact> newItems) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account> businessAccounts = new Map<Id, Account>();

        //get account ids
        for (Contact con : newItems) {
            if (con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }
        //get account records recordtype
        if (!accountIds.isEmpty()) {
            businessAccounts = new Map<Id, Account>(
                [
                    SELECT Id
                    FROM Account
                    WHERE Id IN :accountIds AND RecordTypeId = :BUSINESS_ACC_RECTYPEID
                ]
            );
        }

        for (Contact con : newItems) {
            //set business org to primary org if RT is business_organization
            if (businessAccounts.containsKey(con.AccountId)) {
                con.hed__Primary_Organization__c = con.AccountId;
                con.AccountId = null;
            }
        }
    }

    /***
     * @description create account contact relation records for business org and contact
     * @param conNew - trigger.new contacts
     */
    public static void createAccountContactRelationRecords(
        List<Contact> newItems,
        Map<Id, Contact> oldMap
    ) {
        //map of acrt to be inserted
        Map<String, AccountContactRelation> acrToBeUpserted = new Map<String, AccountContactRelation>();

        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for (Contact con : newItems) {
            if (
                (con.hed__Primary_Organization__c != null &&
                con.hed__Primary_Organization__c != con.AccountId &&
                (oldMap == null ||
                oldMap.get(con.Id).hed__Primary_Organization__c !=
                con.hed__Primary_Organization__c))
            ) {
                //store contact and account ids
                contactIds.add(con.Id);
                accountIds.add(con.hed__Primary_Organization__c);

                //build ACR Record to upsert
                acrToBeUpserted.put(
                    String.valueOf(con.hed__Primary_Organization__c) + String.valueOf(con.Id),
                    new AccountContactRelation(
                        Id = null,
                        AccountId = con.hed__Primary_Organization__c,
                        ContactId = con.Id,
                        IsActive = true
                    )
                );
                //deactivate old ACR when removed
            } else if (
                con.hed__Primary_Organization__c == null &&
                oldMap != null &&
                oldMap.get(con.Id).hed__Primary_Organization__c != con.hed__Primary_Organization__c
            ) {
                contactIds.add(con.Id);
                accountIds.add(oldMap.get(con.Id).hed__Primary_Organization__c);

                //build ACR Record to upsert
                //set previous acr to isactive false
                acrToBeUpserted.put(
                    String.valueOf(oldMap.get(con.Id).hed__Primary_Organization__c) +
                    String.valueOf(con.Id),
                    new AccountContactRelation(
                        Id = null,
                        AccountId = oldMap.get(con.Id).hed__Primary_Organization__c,
                        ContactId = con.Id,
                        IsActive = false
                    )
                );
            }
        }

        if (!acrToBeUpserted.isEmpty()) {
            acrToBeUpserted = checkForExistingACR(accountIds, contactIds, acrToBeUpserted);

            upsert acrToBeUpserted.values();

            //deactivate other ACR linked the contact
            deactivateExistingACRRecords(acrToBeUpserted.values(), contactIds);
        }
    }

    private static Map<String, AccountContactRelation> checkForExistingACR(
        Set<Id> accountIds,
        Set<Id> contactIds,
        Map<String, AccountContactRelation> acrToBeUpserted
    ) {
        //get all ACR with the same contact and account ids
        List<AccountContactRelation> existingACR = new List<AccountContactRelation>(
            [
                SELECT Id, AccountId, ContactId
                FROM AccountContactRelation
                WHERE AccountId IN :accountIds AND ContactId IN :contactIds
            ]
        );

        for (AccountContactRelation acr : existingACR) {
            if (
                acr.AccountId != null &&
                acr.ContactId != null &&
                acrToBeUpserted.containsKey(
                    String.valueOf(acr.AccountId) + String.valueOf(acr.contactId)
                )
            ) {
                //set the id of the ACR if found
                //this would set the IsActive status of existing ACR to True
                acrToBeUpserted.get(String.valueOf(acr.AccountId) + String.valueOf(acr.contactId))
                    .Id = acr.Id;
            }
        }

        return acrToBeUpserted;
    }

    private static void deactivateExistingACRRecords(
        List<AccountContactRelation> newACRs,
        Set<Id> contactIds
    ) {
        List<AccountContactRelation> acrToDeactivate = new List<AccountContactRelation>(
            [
                SELECT Id, IsActive
                FROM AccountContactRelation
                WHERE
                    ContactId IN :contactIds
                    AND Account.RecordType.Name = 'Business Organization'
                    AND Id NOT IN :newACRs
                    AND IsActive = TRUE
            ]
        );

        for (AccountContactRelation acr : acrToDeactivate) {
            acr.IsActive = false;
        }

        if (!acrToDeactivate.isEmpty()) {
            update acrToDeactivate;
        }
    }

    /**
     * @description Update Moving To Brisbane field on contact insert
     * @param newItem List of new contacts
     */
    public static void updateMovingToBrisbane(List<SObject> newItems) {
        Map<Id, Marketing_Segmentation__c> marSegMap = getMarketingSegmentationsOnContactList(
            (List<Contact>) newitems
        );
        for (Contact newItem : (List<Contact>) newItems) {
            if (newItem.Marketing_Segmentation__c != null) {
                newItem.Moving_To_Brisbane__c = marSegMap.get(newItem.Marketing_Segmentation__c)
                    .My_Moving_To_Brisbane__c;
            }
        }
    }

    /**
     * @description Update Moving To Brisbane field on contact with updated marketing segmentation
     * @param newItem Map of updated contacts and their ids
     * @param oldItem Map of outdated contacts and their ids
     */
    public static void updateMovingToBrisbane(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
    ) {
        Map<Id, Marketing_Segmentation__c> marSegMap = new Map<Id, Marketing_Segmentation__c>();

        List<Contact> contactsWithMarSeg = new List<Contact>();

        //collect contacts where marketing segmentaion is updated
        for (Contact newItem : (List<Contact>) newItems.values()) {
            Contact oldItem = (Contact) oldItems.get(newItem.Id);
            if (
                newItem.Marketing_Segmentation__c != null &&
                newItem.Marketing_Segmentation__c != oldItem.Marketing_Segmentation__c
            ) {
                contactsWithMarSeg.add(newItem);
            }
        }

        //get related marketing segmentation
        if (!contactsWithMarSeg.isEmpty()) {
            marSegMap = getMarketingSegmentationsOnContactList(contactsWithMarSeg);
        }

        //update moving to brisbane field
        for (Contact newItem : contactsWithMarSeg) {
            if (marSegMap.containsKey(newItem.Marketing_Segmentation__c)) {
                newItem.Moving_To_Brisbane__c = marSegMap.get(newItem.Marketing_Segmentation__c)
                    .My_Moving_To_Brisbane__c;
            }
        }
    }

    private static Map<Id, Marketing_Segmentation__c> getMarketingSegmentationsOnContactList(
        List<Contact> contacts
    ) {
        Map<Id, Marketing_Segmentation__c> marketingSegMap = new Map<Id, Marketing_Segmentation__c>();

        Set<Id> marSegIdsInNewItems = new Set<Id>();
        for (Contact con : (List<Contact>) contacts) {
            if (!String.isBlank(con.Marketing_Segmentation__c)) {
                marSegIdsInNewItems.add(con.Marketing_Segmentation__c);
            }
        }

        if (!marSegIdsInNewItems.isEmpty()) {
            return new Map<Id, Marketing_Segmentation__c>(
                [
                    SELECT Id, My_Moving_To_Brisbane__c
                    FROM Marketing_Segmentation__c
                    WHERE Id IN :marSegIdsInNewItems
                    WITH SYSTEM_MODE
                ]
            );
        }

        return marketingSegMap;
    }

    /**
     * @description get the contactIds of the contact who's calculated cadence value is updated
     *
     * @param List<Contact> newItems
     * @param Map<Id, Contact> oldItems
     */
    public static void getContactCalculatedCadence(
        List<Contact> newItems,
        Map<Id, Contact> oldItems
    ) {
        Map<String, String> assignContactToCadenceMap = new Map<String, String>();
        Map<String, String> removeContactToCadenceMap = new Map<String, String>();

        for (Contact con : newItems) {
            if (con.RecordTypeId != ContactsDAO.PERSON_RECORDTYPE_ID) {
                continue;
            }

            Contact oldContact = oldItems.get(con.Id);
            String calculatedCadence = con.Calculated_Cadence__c;
            String oldCalculatedCadence = oldContact.Calculated_Cadence__c;

            if (calculatedCadence != oldCalculatedCadence) {
                if (String.isNotEmpty(calculatedCadence) && String.isEmpty(oldCalculatedCadence)) {
                    assignContactToCadenceMap.put(con.Id, calculatedCadence);
                } else if (
                    String.isEmpty(calculatedCadence) && String.isNotEmpty(oldCalculatedCadence)
                ) {
                    removeContactToCadenceMap.put(con.Id, oldCalculatedCadence);
                }
            }
        }

        if (!assignContactToCadenceMap.isEmpty() || !removeContactToCadenceMap.isEmpty()) {
            SalesCadenceCalloutService.processSaleCadences(
                assignContactToCadenceMap,
                removeContactToCadenceMap
            );
            SalesCadenceCalloutService.updateCompletedCadences(assignContactToCadenceMap);
        }
    }
    /**
     * @description create a Marketing Segmentation on the newly created contact
     *
     * @param Set<Id> contactIds
     */
    @future
    public static void createMarketingSegmentation(Set<Id> contactIds) {
        List<Marketing_Segmentation__c> marketingSegToInsert = new List<Marketing_Segmentation__c>();
        Map<Id, Marketing_Segmentation__c> marketingSegMap = new Map<Id, Marketing_Segmentation__c>();

        for (
            Marketing_Segmentation__c marSeg : MarketingSegmentationsDAO.newInstance()
                .getMarketingSegmentationByContactIds(contactIds, AccessLevel.SYSTEM_MODE)
        ) {
            marketingSegMap.put(marSeg.Contact__c, marSeg);
        }

        for (Id contactId : contactIds) {
            if (!marketingSegMap.containsKey(contactId)) {
                marketingSegToInsert.add(new Marketing_Segmentation__c(Contact__c = contactId));
            }
        }
        if (!marketingSegToInsert.IsEmpty()) {
            MarketingSegmentationsDAO.newInstance()
                .insertRecords(marketingSegToInsert, false, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * @description Minimum value for Date of Birth
     * @param Contact to be evaluated
     */
    private static void birthDateValidation(Contact con) {
        Date minDOB = System.Today().addYears(-15);

        if (con.Birthdate > minDOB) {
            con.Birthdate.addError('Must be 15 years or older to register');
        }
    }

    /**
     * @description check or uncheck and QUT_Staff based on the contact details
     *
     * @param newItems  List of new Contact records
     */
    private static void setQUTPersonaFlag(Contact con) {
        con.QUT_Staff__c = (String.isNotEmpty(con.QUT_Employee_ID__c) &&
            con.Staff_End_Date__c > SYSTEM.today())
            ? true
            : false;
    }

    /**
     * @description set can nurture flag lead score if above or below threshold
     *
     * @param Contact con - trigger.new of contact
     * @param List<Contact> contactsToRecalculate - contacts to recalculate
     * @param Map<Id, Contact> oldContacts - trigger.old of contact
     */
    private static void setCanNurtureFlag(
        Contact con,
        List<Contact> contactsToRecalculate,
        Map<Id, Contact> oldContacts
    ) {
        Boolean isInsert = oldContacts == null;
        //on insert or update
        //check if QUT Applicant is set to false on insert or update
        Boolean isQUTApplicantChanged = (!isInsert && oldContacts.get(con.Id).QUT_Applicant__c != con.QUT_Applicant__c);
        
        //check if lead score value changed
        Boolean isLeadScoreChanged = (!isInsert && oldContacts.get(con.Id).Lead_Score__c != con.Lead_Score__c);
        
        
       //check if contact is applicant
        if (con.QUT_Applicant__c && isInsert) {
            con.Can_Nurture__c = true;
        } else if(isLeadScoreChanged || isQUTApplicantChanged) {
            contactsToRecalculate.add(con);
        }
    }

    /**
     * @description recalculate contacts and set Can_Nurture__c based on the specified criteria
     *
     * @param List<Contact> contactsToRecalculate
     */
    private static void recalculateCanNurture(List<Contact> contactsToRecalculate) {
        if (contactsToRecalculate.isEmpty()) {
            return;
        }
        
        Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack = new Map<String, Nurture_Track_Configuration__c>();
        Set<Id> contactWithActiveApplications = new Set<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>(contactsToRecalculate);
        
        // Populate mapOfNurtureTrack with nurturing track records for Strong Interest
        populateNurtureTrackMap(mapOfNurtureTrack);
        
        // Populate contactWithActiveApplications with active contact IDs
        populateActiveApplicationsSet(contactWithActiveApplications, contactMap);
        
        if (!mapOfNurtureTrack.isEmpty() || !contactWithActiveApplications.isEmpty()) {
            for (Contact con : contactsToRecalculate) {
                Decimal minScore = getMinScore(con.hed__Citizenship_Status__c, mapOfNurtureTrack);
                
                // Check if the lead score is greater than or equal to the Strong Interest threshold nurture track
                // Or if the contact is linked to an active application record, then set the Can_Nurture flag to TRUE
                con.Can_Nurture__c = LeadScoreService.isLeadScoreInRange(con.Lead_Score__c, minScore, null) || contactWithActiveApplications.contains(con.Id);
            }
        }
    }
    /**
     * @description get strong interest nurture track
     *
     * @param Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack)
     */    
    private static void populateNurtureTrackMap(Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack) {
        for (Nurture_Track_Configuration__c nurture : NurtureTrackConfigurationsDAO.newInstance().getNurtureTrackLeadScoreThreshold('SYSTEM_MODE')) {
            if (isStrongInterestCadence(nurture.Cadence_Name__c)) {
                mapOfNurtureTrack.put(nurture.Cadence_Name__c, nurture);
            }
        }
    }
    
    /**
     * @description check if cadence is strong interest
     *
     * @param String cadenceName
     */      
    private static boolean isStrongInterestCadence(String cadenceName) {
        return cadenceName == NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL ||
            cadenceName == NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL;
    }

    /**
     * @description get active application of contact
     *
     * @param Set<Id> contactWithActiveApplications, Map<Id, Contact> contactMap
     */     
    private static void populateActiveApplicationsSet(Set<Id> contactWithActiveApplications, Map<Id, Contact> contactMap) {
        for (hed__Application__c app : ApplicationsDAO.newInstance().getApplicationsActiveApplicants(contactMap.keySet(), 'SYSTEM_MODE')) {
            contactWithActiveApplications.add(app.hed__Applicant__c);
        }
    }
    
    /**
     * @description set the nurture track lead score threshold
     *
     * @param String citizenshipStatus, Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack
     */     
    private static Decimal getMinScore(String citizenshipStatus, Map<String, Nurture_Track_Configuration__c> mapOfNurtureTrack) {
        if (citizenshipStatus == 'Domestic' || citizenshipStatus == 'International') {
            String cadenceName = (citizenshipStatus == 'International') ? NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL : NurtureTrackConfigurationsDAO.DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL;
            return mapOfNurtureTrack.get(cadenceName)?.Lead_Score_Threshold__c;
        }
        return null;
    }

    /***
     * @description update Registered email when match to Primary Email or Work Email 
     * @param newItems - trigger.new contacts
     * @param oldItems - trigger.old contacts
     */
    private static void updateRegisteredEmail(Contact newItems, Map<Id, Contact> oldItems){
        Boolean isUpdate = oldItems != null;
        Boolean isPrimaryEmailChange = isUpdate && newItems.Email != oldItems.get(newItems.Id).Email;
        Boolean isWorkEmailChange = isUpdate && newItems.Work_Email__c != oldItems.get(newItems.Id).Work_Email__c;
        Boolean isRegisteredEmailMatchPrimaryEmail = isUpdate && (oldItems.get(newItems.Id).Email == oldItems.get(newItems.Id).Registered_Email__c);
        Boolean isRegisteredEmailMatchWorkEmail = isUpdate && (oldItems.get(newItems.Id).Work_Email__c == oldItems.get(newItems.Id).Registered_Email__c);
        Boolean updateRegisteredEmailFromPrimary = isPrimaryEmailChange && isRegisteredEmailMatchPrimaryEmail; 
        Boolean updateRegisteredEmailFromWork =  isWorkEmailChange && isRegisteredEmailMatchWorkEmail; 
        if(updateRegisteredEmailFromPrimary){
            newItems.Registered_Email__c = newItems.Email;
        }
        else if(updateRegisteredEmailFromWork){
            newItems.Registered_Email__c = newItems.Work_Email__c;    
        }
    }

    public static void createLeadScoreDetailRecord(Set<Id> contactIds) { 
        List<Lead_Score_Detail__c> leadScoreDetailsToInsert = new List<Lead_Score_Detail__c>();
        for (Id contactId : contactIds) {
            leadScoreDetailsToInsert.add(new Lead_Score_Detail__c(Contact__c = contactId));
        }
        LeadScoreDetailsDAO.newInstance().insertRecords(leadScoreDetailsToInsert, false, AccessLevel.SYSTEM_MODE);
    }
}
