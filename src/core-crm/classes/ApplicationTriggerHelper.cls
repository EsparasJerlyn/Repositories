/**
 * @description helper class for ApplicationTriggerHelperHandler
 * @see ApplicationTriggerHelperHandler
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                 |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------------|
      | mark.j.mahilum                 | July 12, 2023         | DEPP-5799              | Created file                                                   |
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | Added new method to set Can Nurture flag                       |
      | alexander.cadalin              | Aug 16, 2023          | DEPP-6124              | Refactor to consider multiple field updates                    |
      | mark.j.mahilum                 | Aug 31, 2023          | DEPP-6455              | Updated getContactOnApplication to get the old Contact Id      |
 */
public with sharing class ApplicationTriggerHelper {
    /**
     * @description Perform field updates on related records of the inserted marketing segmentations passing thru the trigger.
     * @param newItems A map of insert marketing segmentations
     */
    public static void updateRelatedRecords(Map<Id, SObject> newItems) {
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        Map<Id, Lead> leadsToUpdate = new Map<Id, Lead>();
        for(hed__Application__c app : (List<hed__Application__c>) newItems.values()) {
            // contact updates start here
            setLogiclessFieldValuesOnContact(contactsToUpdate, app);
            // contact updates end here
            // lead updates start here
            setLogiclessFieldValuesOnLead(leadsToUpdate, app);
            // lead updates end here
        }
        if(!contactsToUpdate.keySet().isEmpty()) {
            ContactsDAO.newInstance().updateRecords(contactsToUpdate.values(), false, AccessLevel.SYSTEM_MODE);
        }
        if(!leadsToUpdate.keySet().isEmpty()) {
            LeadsDAO.newInstance().updateRecords(leadsToUpdate.values(), false, AccessLevel.SYSTEM_MODE);
        }
    }
    
    /**
     * @description get the existing contact in the application record
     *
     * @param newItems  List of new hed__Application__c records
     * @param oldItems  Map of old hed__Application__c records (Id => hed__Application__c)
     */
    public static void getContactOnApplication(List<hed__Application__c> newItems, Map<Id, hed__Application__c> oldItems) {         
        Set<Id> contactIds = new Set<Id>();
        
        for (hed__Application__c app : newItems) {
            
            boolean isStudylinkRecType = app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            boolean isSAMSRecType = (app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID || app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
            boolean isQTACRecType = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
            boolean isValidRecType = isStudylinkRecType || isSAMSRecType || isQTACRecType;
                         
            if(String.isNotEmpty(app.hed__Applicant__c) && isValidRecType){
                contactIds.add(app.hed__Applicant__c);
            }
            
            if(oldItems != null) {              
                hed__Application__c oldApp = oldItems.get(app.Id);              
                Boolean isContactChanged = (app.hed__Applicant__c != oldApp.hed__Applicant__c);
                
                if(String.isNotEmpty(oldApp.hed__Applicant__c) && isContactChanged){
                    contactIds.add(oldApp.hed__Applicant__c); 
                }                 
            }         
        }
        
        if(!contactIds.isEmpty()){
            ContactPersonaFlagsService.processContactIds(contactIds,'updateContactApplicantFlag');
        }      
    }

    /**
     * @description Set field values on the related contact of an inserted application. One-liner field setting only. Use another method if otherwise
     * @param contactsToUpdate An id-contact map of contacts to be updated
     * @param app The application record to process
     */
    private static void setLogiclessFieldValuesOnContact(Map<Id, Contact> contactsToUpdate, hed__Application__c app) {
        if(app.hed__Applicant__c != null) {
            Contact con = getRecordFromContactMap(contactsToUpdate, app.hed__Applicant__c);
            // field mapping starts here
            con.Can_Nurture__c = isActiveApplication(app);
            con.Is_Agent_Assisted__c = app.Is_Agent_Assisted__c;
            con.Is_International_Applicant__c = app.Is_International_Applicant__c;
            con.Personal_Illness_Disability_Applicant__c = app.Is_Personal_Illness_Disability_Applicant__c;
            con.Elite_Athlete_Applicant__c = app.Is_Elite_Athlete_Applicant__c;
            con.Education_Disruption_Applicant__c = app.Is_Education_Disruption_Applicant__c;
            con.First_in_Family_Applicant__c = app.Is_First_In_Family_Applicant__c;
            con.Financial_Hardship_Applicant__c = app.Is_Financial_Hardship_Applicant__c;
            con.Agency_Name__c = app.Agency_Name__c;
            con.Agency_Country__c = app.Agency_Country__c;
            con.Agency_Email__c = app.Agency_Email__c;
            // field mapping ends here
            contactsToUpdate.put(con.Id, con);
        }
    }
    /**
     * @description update the inserted Sams application record
     *
     * @param newItems  List of new hed__Application__c records
     */
    public static void updateCalculatedDateOnSamsApplicationRecords(List<hed__Application__c> newItems) {
        try{
            Set<Id> termsIdInApplication = ApplicationService.getAllTermsIdInApplication(newItems);
            Map<Id,hed__Term__c> termRecords = new Map<Id,hed__Term__c>(TermsDAO.newInstance().getTermRecordByApplication(termsIdInApplication,'SYSTEM_MODE'));

            for (hed__Application__c app : newItems) {
                boolean isSAMSRecType = (app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID || app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
                    if(isSAMSRecType && termRecords.containsKey(app.Applied_Intake_Study_Period__c)){
                        app.Calculated_Intake_Date__c = termRecords.get(app.Applied_Intake_Study_Period__c).hed__Start_Date__c;
                    }
            }
        } catch (Exception e) {
            Logger.error('Exception caught in method updateCalculatedDateOnSamsApplicationRecords in class ApplicationTriggerHelper.')
              .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }     
    
    
    /**
     * @description Set field values on a related lead. Add your field mapping here if it can be done in ONE LINE ONLY. Otherwise, use another method.
     * @param leadsToUpdate an id-lead map of leads to be updated
     * @param app The application record to process
     */
    private static void setLogiclessFieldValuesOnLead(Map<Id, Lead> leadsToUpdate, hed__Application__c app) {
        if(app.Lead__c != null) {
            Lead ld = getRecordFromLeadMap(leadsToUpdate, app.Lead__c);
            // field mapping starts here
            ld.Can_Nurture__c = isActiveApplication(app);
            // field mapping ends here
            leadsToUpdate.put(ld.Id, ld);
        }
    }
    
    /**
     * @description Return a boolean value to indicate whether the provided application is active
     * @param app The application record
     * @return Boolean
     */
    private static Boolean isActiveApplication(hed__Application__c app) {
        return !ApplicationsDAO.samsStatuses.contains(app.Application_Status__c) && !ApplicationsDAO.studyLinkStatuses.contains(app.Application_Status__c); 
    }
    
    /**
     * @description Get a record from an ids-contact map given a record Id. If it does not exist, it returns a new contact Sobject.
     * @param contactMap The contact map to get the record from
     * @param recordId The record to look for, or to create a new record from.
     * @return Contact
     */
    private static Contact getRecordFromContactMap(Map<Id, Contact> contactMap, Id recordId) {
        if(contactMap.containsKey(recordId)) {
            return contactMap.get(recordId);
        } else {
            return new Contact(Id = recordId);
        }
    }
    
    /**
     * @description Get a record from an ids-lead map given a record Id. If it does not exist, it returns a new lead Sobject.
     * @param leadMap The lead map to get the record from
     * @param recordId The record to look for, or to create a new record from.
     * @return Lead
     */
    private static Lead getRecordFromLeadMap(Map<Id, Lead> leadMap, Id recordId) {
        if(leadMap.containsKey(recordId)) {
            return leadMap.get(recordId);
        } else {
            return new Lead(Id = recordId);
        }
    }
}