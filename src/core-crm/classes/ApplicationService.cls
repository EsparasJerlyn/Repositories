/**
 * @description Service Class for Application Object use in trigger service class
 * 
 * @see ApplicationTriggerHandler
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                    |
 *    |--------------------------------|-----------------------|------------------------|-----------------------------------|
 *    | mark.j.mahilum                 | June 19,2023          | DEPP-5846	            | Created File                      |
 *    | jerlyn.esparas                 | July 06, 2023         | DEPP-5845              | Added method for QTAC application |
 *    | arsenio.jr.dayrit              | July 06, 2023         | DEPP-5847              | Added method for SAMS application |
 *    | mark.j.mahilum                 | August 01, 2023       | DEPP-6135              | Added new record type condition   |
 *    | alexander.cadalin              | Sep 22, 2023          | DEPP-6652,6653,6654    | Added methods for contact field   |
 *    |                                |                       |                        | updates on match with application |
 *    | nicole.genon                   | Oct 4, 2023           | DEPP-6821              | Added mapping for QTAC matching   |
 *    | alexander.cadalin              | Oct 9, 2023           | DEPP-6848              | Rework QTAC address mapping       |
 */
public with sharing class ApplicationService { //NOPMD

    /**
     * @description Executes the matching rule for new applications and enqueues applications for future processing.
     *
     * @param newItems  List of new hed__Application__c records
     * @param oldItems  Map of old hed__Application__c records (Id => hed__Application__c)
     */
     public static void executeMatchingRule(List<hed__Application__c> newItems, Map<Id, hed__Application__c> oldItems) {
         
         List<hed__Application__c> newApplicationList = new List<hed__Application__c>();
         
         for (hed__Application__c app : newItems) {
            if (isNewApplication(app, oldItems)) {
                newApplicationList.add(app);
            }
         }
         
         if(!newApplicationList.isEmpty()){
            enqueueQueueableProcess(newApplicationList,'ApplicationService'); 
         }         
     }
     
    /**
     * @description: Checks if the given application is a new StudyLink application based on specified conditions.
     *
     * @param app       hed__Application__c record to evaluate
     * @param oldItems  Map of old hed__Application__c records (Id => hed__Application__c)
     * @return          True if the application is a new StudyLink application, False otherwise
     */
     private static boolean isNewApplication(hed__Application__c app, Map<Id, hed__Application__c> oldItems) {
         boolean isStudylinkRecType = app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
         boolean isEmptyApplicant = String.isEmpty(app.hed__Applicant__c);
     
         if (oldItems == null && isEmptyApplicant) {
             return true;
         } else if (oldItems != null && isStudylinkRecType && isEmptyApplicant) {
             hed__Application__c oldApp = oldItems.get(app.Id);
             String oldStatus = oldApp != null ? oldApp.Application_Status__c : null;
             return (oldStatus == 'New' || oldStatus == 'Unsubmitted') && app.Application_Status__c != oldStatus;
         }
     
         return false;
     }

    /**
     * @description Enqueues the given StudyLink applications for future processing using a DynamicQueueableProcess.
     *
     * @param applications  List of StudyLink applications to enqueue
     * @param methodName name of the method to execute in the DynamicQueueableProcess
     */
     private static void enqueueQueueableProcess(List<hed__Application__c> applications, String serviceClassName) {
         DynamicQueueableProcess queueableCalls = new DynamicQueueableProcess(applications,serviceClassName);
         System.enqueueJob(queueableCalls);
     }
     
    /**
     * @description: Matches application record type to process.
     * 
     * @param newItems The list of new StudyLink applications to process.
     * @param String recordTypeId of the application record for processing
     */ 
     public static void enqueueApplicationToExecute(List<hed__Application__c> newItems) {     
         List<hed__Application__c> newStudyLinkApplications = new List<hed__Application__c>();
         List<hed__Application__c> newSAMApplications = new List<hed__Application__c>();
         
         for (hed__Application__c app : newItems) {

            boolean isStudylinkRecType = app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
            boolean isQTACRecType = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID; 
            boolean isSAMSLegacyRecType = app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID;
            boolean isSAMSCIAnywhere = app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID;
              
             if (isStudylinkRecType || isQTACRecType) {
                 newStudyLinkApplications.add(app);
             }
             if(isSAMSLegacyRecType || isSAMSCIAnywhere){
                 newSAMApplications.add(app);
             }
         }
         
         List<Contact> existingContacts = new List<Contact>();
         
         if (!newStudyLinkApplications.isEmpty()) {
             existingContacts.addAll(matchApplicationToContactORLead(newStudyLinkApplications));     
         }
 
         if (!newSAMApplications.isEmpty()){
             existingContacts.addAll(matchSamsApplicationToContact(newSAMApplications));
         }
         
         ApplicationServiceHelper.mapOfContactIds = new Map<String, Set<Id>>();
         List<hed__Application__c> updateApplicationList = new List<hed__Application__c>();
         
         if (!existingContacts.isEmpty()) {
             Map<String, Map<Id, Contact>> contactsMap = createContactsMap(existingContacts, newItems);
             updateApplicationList = processMatchingContacts(newItems, contactsMap);
         } else {
             updateApplicationList = ApplicationServiceHelper.processNonMatchingContacts(newItems);           
         }
         
         addLogs(ApplicationServiceHelper.mapOfContactIds);
         
         if(!updateApplicationList.isEmpty()){
             ApplicationsDAO.newInstance().updateRecords(updateApplicationList, false, AccessLevel.SYSTEM_MODE);
         }
     }
     
    /**
     * @description: Matches StudyLink applications to existing Contacts or Leads based on application details.
     * 
     * @param newItems The list of new StudyLink applications to process.
     */ 
     private static List<Contact> matchApplicationToContactORLead(List<hed__Application__c> newItems) {
         ContactsDAO.QueryParamWrapper applicationDetails = extractApplicationDetails(newItems);
         return getContactsWithMatchingApplicationDetails(applicationDetails);
     }
     
    /**
     * @description: Matches SAMS applications to existing Contacts based on application details.
     * 
     * @param newItems The list of new Sams applications to process.
     */ 
     private static List<Contact> matchSamsApplicationToContact(List<hed__Application__c> newItems) {
        ContactsDAO.QueryParamWrapper samsApplicationDetails = extractApplicationDetails(newItems);
        return getContactsWithMatchingSamsApplications(samsApplicationDetails);
     }
     
     /**
      * @description: Retrieves the list of Contacts with matching SAMS application details.
      * 
      * @param applicationDetails The ApplicationDetails object containing SAMS application details.
      * @return The list of Contacts with matching details.
      */     
     private static List<Contact> getContactsWithMatchingSamsApplications(ContactsDAO.QueryParamWrapper applicationDetails) {
         return ContactsDAO.newInstance()
             .getContactsWithMatchingSamsApplications(
                 applicationDetails,
                 'SYSTEM_MODE'
             );
     }
     
    /**
     * @description: Retrieves the list of Contacts with matching application details.
     * 
     * @param applicationDetails The ApplicationDetails object containing application details.
     * @return The list of Contacts with matching details.
     */     
     private static List<Contact> getContactsWithMatchingApplicationDetails(ContactsDAO.QueryParamWrapper applicationDetails) {
         return ContactsDAO.newInstance()
             .getContactsWithMatchingApplicationDetails(
                 applicationDetails,
                 'SYSTEM_MODE'
             );
     }
     
    /**
     * @description: Extracts application details from the given list of applications.
     * 
     * @param newItems The list of new StudyLink applications.
     * @return The ApplicationDetails object containing extracted details.
     */     
     private static ContactsDAO.QueryParamWrapper extractApplicationDetails(List<hed__Application__c> newItems) {
         ContactsDAO.QueryParamWrapper applicationDetails = new ContactsDAO.QueryParamWrapper();
         for (hed__Application__c app : newItems) {
             if(app.Email__c !=null){
                 applicationDetails.emailsToMatch.add(app.Email__c);             
             }
             applicationDetails.firstNames.add(app.FirstName__c);
             applicationDetails.lastNames.add(app.LastName__c);
             applicationDetails.birthdates.add(app.Birthdate__c);
             if(app.Nominated_Student_ID__c !=null){
                 applicationDetails.nominatedStudentId.add(app.Nominated_Student_ID__c);               
             }
         }
         return applicationDetails;
     }
     
    /**
     * @description: Creates a map of contacts matching the applications.
     * 				The map key is the application Id and the value is a map of contact IDs and corresponding contacts.
     *
     * @param existingContacts   List of existing contacts
     * @param newItems           List of new applications
     * @param newItemsMatchCount Map to track the count of matching applications for each identifier
     * @return Map of contacts matching the applications
     */     
     private static Map<String, Map<Id,Contact>> createContactsMap(List<Contact> existingContacts, List<hed__Application__c> newItems) {
         Map<String, Map<Id,Contact>> contactsMap = new Map<String, Map<Id,Contact>>();      
         for (Contact contact : existingContacts) {
             for (hed__Application__c application : newItems) {
                 if (ApplicationServiceHelper.contactMatchesApplication(contact, application)) {
                     ApplicationServiceHelper.addToContactsMap(contactsMap, application.Id, contact);
                 }
             }
         }
         
         return contactsMap;
     }
 
    /**
     * Processes matching contacts based on the given newItems and contactsMap.
     * 
     * @param newItems    The list of hed__Application__c objects.
     * @param contactsMap The map of string keys to nested maps of Ids to Contact objects.
     */     
     private static List<hed__Application__c> processMatchingContacts(List<hed__Application__c> newItems, Map<String, Map<Id, Contact>> contactsMap) {
         List<hed__Application__c> nonMatchingApplication = new List<hed__Application__c>();
         List<hed__Application__c> updateApplicationList = new List<hed__Application__c>();
         
         for (hed__Application__c application : newItems) {
             if (contactsMap.containsKey(application.Id)) {
                 Map<Id, Contact> contactMap = contactsMap.get(application.Id);
                 if (contactMap.size() > 1) {
                     ApplicationServiceHelper.mapOfContactIds.put(application.Id, contactMap.keySet());
                 } else {
                     Contact contact = contactMap.values()[0];
                     hed__Application__c app = new hed__Application__c(Id = application.Id, hed__Applicant__c = contact.Id);
                     updateApplicationList.add(app);
                 }
             } else {
                 nonMatchingApplication.add(application);
             }
         }
         
         updateApplicationList.addAll(ApplicationServiceHelper.processNonMatchingContacts(nonMatchingApplication));  
         return updateApplicationList;
     }

     /**
     * Processes application list to get linked Term Ids
     * 
     * @param newItems    The list of hed__Application__c objects.
     */     
     public static Set<Id> getAllTermsIdInApplication(List<hed__Application__c> applicationList) {
        Set<Id> termsId = new Set<Id>();

        for(hed__Application__c app : applicationList){
            if(app.Applied_Intake_Study_Period__c != null){
                termsId.add(app.Applied_Intake_Study_Period__c);
            }
        }

        return termsId;
    }
    
    /**
     * @description: Adds logs based on the provided contactsIdMap.
     * 				The method iterates over the map and logs messages for multiple matches or email mismatches
     * 				It also saves the logs if the buffer size of the Logger is greater than 0. 
     * @param contactsIdMap A map of application keys to sets of contact IDs.                   
     */     
     private static void addLogs(Map<String, Set<Id>> contactsIdMap) {        
         // Iterate over the map's key-value pairs
         for (String key : contactsIdMap.keySet()) {                  
             String logMessage = 'Email already exists in system but name doesn’t match contact '+ contactsIdMap.get(key) + ' , please investigate for manual matching of records ' + key;
             if(contactsIdMap.get(key).size() > 1){
                 logMessage = 'There has been multiple matches found for the following application '+ key + ' , please investigate for manual matching of records - contact ' + contactsIdMap.get(key);
             }
             Logger.info(logMessage).setRecord(key);
         }
                        
         if (Logger.getBufferSize() > 0) {
             Logger.saveLog();
         }
     }    

    /**
     * @description Return a boolean value to indicate whether the provided application is active
     * @param app The application record
     * @return Boolean
     */
    public static Boolean isActiveApplication(hed__Application__c app) {
        return !ApplicationsDAO.samsStatuses.contains(app.Application_Status__c) && !ApplicationsDAO.studyLinkStatuses.contains(app.Application_Status__c); 
    }
    
    /**
     * @description Get a list of contact records from applicants related to a list of applications.
     * @param List<hed__Application__c> applications - A list of applications to get the contacts (applicants) from.
     * @return List<Contact>
     */
    public static List<Contact> getApplicantsFromApplications(List<hed__Application__c> applications) {
        Set<Id> applicantIdSet = new Set<Id>();
        for(hed__Application__c application : applications) {
            if(String.isNotBlank(application.hed__Applicant__c)) {
            	applicantIdSet.add(application.hed__Applicant__c);   
            }
        }
        if(!applicantIdSet.isEmpty()) {
            return ContactsDAO.newInstance().getPersonContactsBySetIds(applicantIdSet, AccessLevel.SYSTEM_MODE);
        }
        return new List<Contact>();
    }
    
    /**
     * @description For use in updateRelatedRecords method. This method returns a contact record which depends if it
     * already exists in the to-update map. If it is in the map, simply gets the contact within the map. Otherwise, it
     * creates a new contact instance, inserts it into the map, and then returns the new instance from the map.
     * @param Map<Id, Contact> contactsMapToUpdate - The contacts map from the updateRelatedRecords method.
     * @param Id applicantId - The id of the contact/applicant record to pull for.
     * @return Contact
     */
    //TO-DO: Reduce these similar methods into one single reusable getFromUpdateMap method that any SObject map can use.
    public static Contact getContactFromUpdateMap(Map<Id, Contact> contactMapToUpdate, Id applicantId) {
        if(!contactMapToUpdate.containsKey(applicantId)) {
            contactMapToUpdate.put(
                applicantId, 
                new Contact(Id = applicantId)
            );
        }
        return contactMapToUpdate.get(applicantId);
    }
    
    /**
     * @description For use in updateRelatedRecords method. This method returns a lead record which depends if it
     * already exists in the to-update map. If it is in the map, simply gets the lead within the map. Otherwise, it
     * creates a new lead instance, inserts it into the map, and then returns the new instance from the map.
     * @param Map<Id, Lead> leadsMapToUpdate - The lead map from the updateRelatedRecords method.
     * @param Id leadId - The id of the lead record to pull for.
     * @return Lead
     */
    //TO-DO: Reduce these similar methods into one single reusable getFromUpdateMap method that any SObject map can use.
    public static Lead getLeadFromUpdateMap(Map<Id, Lead> leadMapToUpdate, Id leadId) {
        if(!leadMapToUpdate.containsKey(leadId)) {
            leadMapToUpdate.put(
                leadId, 
                new Lead(Id = leadId)
            );
        }
        return leadMapToUpdate.get(leadId);
    }
    
    /**
     * @description Set fields on a contact record. This method contains field settings that are not bound by complex conditions.
     * If the field/s needs to follow certain rules, especially if it's complex, use a different method instead.
     * @param Contact contact - The contact record to modify.
     */
    public static void mapFieldsToApplicant(Contact applicant, hed__Application__c application) {
        applicant.Agency_Country__c = application.Agency_Country__c;
        applicant.Agency_Email__c = application.Agency_Email__c;
        applicant.Agency_Name__c = application.Agency_Name__c;
        applicant.Education_Disruption_Applicant__c = application.Is_Education_Disruption_Applicant__c;
        applicant.Elite_Athlete_Applicant__c = application.Is_Elite_Athlete_Applicant__c;
        applicant.Financial_Hardship_Applicant__c = application.Is_Financial_Hardship_Applicant__c;
        applicant.First_in_Family_Applicant__c = application.Is_First_In_Family_Applicant__c;
        applicant.Is_Agent_Assisted__c = application.Is_Agent_Assisted__c;
        applicant.Is_International_Applicant__c = application.Is_International_Applicant__c;
        applicant.Personal_Illness_Disability_Applicant__c = application.Is_Personal_Illness_Disability_Applicant__c;
    }
    
    /**
     * @description Switch between various field mapping methods based on the record type of the application.
     * @param Contact applicant - The applicant/contact records to update.
     * @param RecordsToReferenceWrapper recordsToReference - The collection of records to base the updates from.
     */
    public static void switchMapFieldsByRecordType(
        Contact applicant,
        RecordsToReferenceWrapper recordsToReference
    ) {
        if(recordsToReference.application.hed__Applicant__c != recordsToReference.oldApplication.hed__Applicant__c) {
            Id applicationRecordType = recordsToReference.application.RecordTypeId;
            if(applicationRecordType == ApplicationsDAO.STUDYLINK_RECTYPE_ID) {
                mapFieldsToStudyLinkApplicant(applicant, recordsToReference);
            } else if(applicationRecordType == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID) {
                mapFieldsToSAMSCIAnywhereApplicant(applicant, recordsToReference);
            } else if(applicationRecordType == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID) {
                mapFieldsToSAMSLegacyApplicant(applicant, recordsToReference);
            } else if(applicationRecordType == ApplicationsDAO.QTAC_RECTYPE_ID) {
                mapFieldsToQTACApplicant(applicant, recordsToReference);
            }
        }
    }
    
    /**
     * @description Set fields on a contact record of a StudyLink application. This method does not check the recordtype.
     * Identify the record type first before using this method!
     * @param Contact applicantToUpdate - The applicant/contact record to map the fields to.
     * @param RecordsToReferenceWrapper recordsToReference - A collection of records to base the mappings from.
     */
    private static void mapFieldsToStudyLinkApplicant(
        Contact applicantToUpdate, 
        RecordsToReferenceWrapper recordsToReference
    ) {
        applicantToUpdate.ATSI_Code__c = recordsToReference.application.Indigenous_Status__c;
        applicantToUpdate.Birthdate = recordsToReference.existingContact.Birthdate == null ? 
            recordsToReference.application.BirthDate__c : recordsToReference.existingContact.Birthdate;
        applicantToUpdate.Citizenship_Country__c = recordsToReference.application.Citizenship_Country__c;
        applicantToUpdate.Mobile_No_Locale__c = recordsToReference.application.Mobile__c;
        applicantToUpdate.hed__Citizenship_Status__c = recordsToReference.application.Citizenship_Status__c;
    }
    
    /** 
     * @description Set fields on a contact record of a SAMS CIAnywhere application. This method does not check the recordtype.
     * Identify the record type first before using this method!
     * @param Contact applicantToUpdate - The applicant/contact record to map the fields to.
     * @param RecordsToReferenceWrapper recordsToReference - A collection of records to base the mappings from.
     */
    private static void mapFieldsToSAMSCIAnywhereApplicant(
        Contact applicantToUpdate, 
        RecordsToReferenceWrapper recordsToReference
    ) {
        // As of 2023-09-21, StudyLink, SAMS CIAnywhere, and SAMS Legacy all follow the same mapping.
        mapFieldsToStudyLinkApplicant(applicantToUpdate, recordsToReference);
    }
    
    /** 
     * @description Set fields on a contact record of a SAMS Legacy application. This method does not check the recordtype.
     * Identify the record type first before using this method!
     * @param Contact applicantToUpdate - The applicant/contact record to map the fields to.
     * @param RecordsToReferenceWrapper recordsToReference - A collection of records to base the mappings from.
     */
    private static void mapFieldsToSAMSLegacyApplicant(
        Contact applicantToUpdate, 
        RecordsToReferenceWrapper recordsToReference
    ) {
        // As of 2023-09-21, StudyLink, SAMS CIAnywhere, and SAMS Legacy all follow the same mapping.
        mapFieldsToStudyLinkApplicant(applicantToUpdate, recordsToReference);
    }
    
    /**
     * @description Set fields on a contact record of a QTAC application. This method does not check the recordtype.
     * Identify the record type first before using this method!
     * @param Contact applicantToUpdate - The applicant/contact to update.
     * @param RecordsToReferenceWrapper recordsToReference - A collection of records to base the mappings from.
     */
    private static void mapFieldsToQTACApplicant(
        Contact applicantToUpdate, 
        RecordsToReferenceWrapper recordsToReference
    ) {
        applicantToUpdate.ATSI_Code__c = recordsToReference.application.Indigenous_Status__c;
        applicantToUpdate.Birth_Country__c = recordsToReference.application.Birth_Country__c;
        applicantToUpdate.Birthdate = recordsToReference.existingContact.Birthdate == null ? 
            recordsToReference.application.BirthDate__c : recordsToReference.existingContact.Birthdate;
        applicantToUpdate.Citizenship_Type__c = recordsToReference.application.Citizenship_Type__c;
        applicantToUpdate.hed__Citizenship_Status__c = recordsToReference.application.Citizenship_Status__c;
        applicantToUpdate.Home_Language__c = recordsToReference.application.Home_Language__c;
        applicantToUpdate.MiddleName = recordsToReference.application.MiddleName__c;
        applicantToUpdate.Mobile_No_Locale__c = recordsToReference.application.Mobile__c;
        applicantToUpdate.Salutation = recordsToReference.application.Salutation__c;
    }
    
    /**
     * @description Fill the address lines of an address record using address lines from an application.
     * NOTE: This method is assuming that at least one field below is populated, or that the address record
     * is always created.
     * @param hed__Address__c address - the address record to fill.
     * @param hed__Application__c application - the application record to get data from.
     * @param String addressType - the type of address (fills hed__Address_Type__c).
     * @return hed__Address__c
     */
    public static hed__Address__c fillAddressLines(hed__Address__c address, hed__Application__c application, String addressType) {
        Map<String, String> typeToFieldMap = new Map<String, String>();
        typeToFieldMap.put('Mailing', 'Postal');
        typeToFieldMap.put('Other', 'Residential');
        String field = typeToFieldMap.get(addressType);
        address.hed__Address_Type__c = addressType;
        address.hed__MailingStreet__c = getAddressLineFromApplication(application, field + '_Address_Line1__c');
        address.hed__MailingStreet2__c = getAddressLineFromApplication(application, field + '_Address_Line2__c');
        if(String.isNotBlank(address.hed__MailingStreet2__c) && application.get(field + '_Address_Line3__c') != null) {
            address.hed__MailingStreet2__c += ' ' + getAddressLineFromApplication(application, field + '_Address_Line3__c');
        } else {
        	address.hed__MailingStreet2__c += getAddressLineFromApplication(application, field + '_Address_Line3__c');    
        }
        address.hed__MailingCity__c = getAddressLineFromApplication(application, field + '_Town__c');
        address.hed__MailingState__c = getAddressLineFromApplication(application, field + '_State__c');
        address.hed__MailingCountry__c = getAddressLineFromApplication(application, field + '_Country__c');
        address.hed__MailingPostalCode__c = getAddressLineFromApplication(application, field + '_Postcode__c');
        address.hed__Parent_Contact__c = application.hed__Applicant__c;
        return address;
    }
    
    /**
     * @description Get the specified address line from the application. Returns a blank string if empty, returns a string if populated.
     * @param hed__Application__c application - the application to get the data from.
     * @param String addressLine - the api name of the address line field in the application. Must be a valid address line.
     * @return String
     */
    private static String getAddressLineFromApplication(hed__Application__c application, String addressLine) {
        List<String> validFields = new List<String>{
            'Postal_Address_Line1__c', 'Postal_Address_Line2__c', 'Postal_Address_Line3__c',
            'Postal_Country__c', 'Postal_Postcode__c', 'Postal_State__c', 'Postal_Town__c',
            'Residential_Address_Line1__c', 'Residential_Address_Line2__c', 'Residential_Address_Line3__c',
            'Residential_Country__c', 'Residential_Postcode__c', 'Residential_State__c', 'Residential_Town__c'
        };
        String value = '';
        if(validFields.contains(addressLine)) {
            value = application.get(addressLine) == null ? '' : (String) application.get(addressLine);
        }
        return value;
    }
    
    public static Boolean isContactMatchedQTACApplication(hed__Application__c application, Map<Id, SObject> oldItems) {
        Boolean isQTAC = application.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
        Boolean isContactMatched = 
            oldItems == null &&
            application.hed__Applicant__c != null;
        Boolean isContactChanged = 
            oldItems != null && 
            application.hed__Applicant__c != null &&
            application.hed__Applicant__c != (Id) oldItems.get(application.Id).get('hed__Applicant__c');
        return isQTAC && (isContactMatched || isContactChanged);
    }
    
    public class RecordsToReferenceWrapper {
        public Contact existingContact { get; set; }
        public hed__Application__c application { get; set; }
        public hed__Application__c oldApplication { get; set; }
    }

    /**
     * @description Map related Contacts Marketing Preference 
     * @param applicantIds
     */
    public static List<Contact> mapContactToUpdate(Set<Id> applicantIds) {
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsBySetIds(applicantIds, AccessLevel.SYSTEM_MODE);
        Map<Id,List<Case>> caseMap = ContactService.mapExistingCasesToContact(applicantIds, AccessLevel.SYSTEM_MODE);
        Map<Id,List<Marketing_Interaction__c>> marketingInteractionMap = ContactService.mapExistingMarketingInteractionToContact(applicantIds, AccessLevel.SYSTEM_MODE);
        Map<Id,List<hed__Application__c>> applicationMap = ContactService.mapExisitngApplicationsToContact(applicantIds, AccessLevel.SYSTEM_MODE);
        
        for(Contact contacts: contactList){
            Boolean noCaseandInteractiinRecord = !caseMap.containsKey(contacts.Id) && !marketingInteractionMap.containsKey(contacts.Id);
            Boolean hasOneApp = applicationMap.containsKey(contacts.Id) && applicationMap.get(contacts.Id).size() == 1;
            Boolean isForUpdate = noCaseandInteractiinRecord && hasOneApp;
            if(isForUpdate){
                contacts.HasOptedOutOfEmail = true;
                contacts.Email_Opt_Out_DateTime__c = System.today();
                contacts.Learner_Email_Opt_Out__c = true;
                contacts.Learner_Email_Opt_Out_DateTime__c = System.today(); 
                contacts.Staff_Email_Opt_Out__c = true;
                contacts.Staff_Email_Opt_Out_DateTime__c = System.today();
                contacts.Work_Email_Opt_Out__c = true;
                contacts.Work_Email_Opt_Out_DateTime__c = System.today();
                contacts.Work_SMS_Opt_Out__c = true;
                contacts.Work_SMS_Opt_Out_DateTime__c = System.today();
                contacts.hed__SMS_Opt_Out__c = true;
                contacts.SMS_Opt_Out_DateTime__c = System.today(); 
                contacts.DoNotCall = true;
                contacts.Sync_to_MC__c = false;
                contacts.Do_Not_Sync_To_MC_Override__c = false;
                contacts.Dont_Market_Reason__c = 'QTAC Application QUT preferences withdrawn';
                contactsToUpdate.add(contacts);
            }
        }
        return contactsToUpdate;
    }

    public static Boolean isInactiveQTACApp(hed__Application__c app, Map<Id, SObject> oldItems) {
        Boolean isForUpdate = 
            oldItems != null && 
            (Boolean) oldItems.get(app.Id).get('Is_Active__c') != app.Is_Active__c;
        Boolean isQTAC = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
        return 
            isForUpdate && 
            isQTAC &&
            app.Is_Active__c == false &&
            app.hed__Applicant__c != null;
    }
}