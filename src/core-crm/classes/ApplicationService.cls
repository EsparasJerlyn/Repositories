/**
 * @description Service Class for Application Object use in trigger service class
 * 
 * @see ApplicationTriggerHandler
 * 
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | mark.j.mahilum                 | June 19, 2023         | DEPP-5846              | created file                               |
 */
public with sharing class ApplicationService {

    /**
     * @description Executes the matching rule for new applications and enqueues the Studylink applications for future processing.
     *
     * @param newItems  List of new hed__Application__c records
     * @param oldItems  Map of old hed__Application__c records (Id => hed__Application__c)
     */
     public static void executeMatchingRule(List<hed__Application__c> newItems, Map<Id, hed__Application__c> oldItems) {
         List<hed__Application__c> newStudyLinkApplications = new List<hed__Application__c>();
     
         for (hed__Application__c app : newItems) {
             if (isNewStudylinkApplication(app, oldItems)) {
                 newStudyLinkApplications.add(app);
             }
         }
     
         if (!newStudyLinkApplications.isEmpty()) {
             enqueueQueueableProcess(newStudyLinkApplications,'ApplicationService');
         }
     }
     
    /**
     * @description: Checks if the given application is a new StudyLink application based on specified conditions.
     *
     * @param app       hed__Application__c record to evaluate
     * @param oldItems  Map of old hed__Application__c records (Id => hed__Application__c)
     * @return          True if the application is a new StudyLink application, False otherwise
     */
     private static boolean isNewStudylinkApplication(hed__Application__c app, Map<Id, hed__Application__c> oldItems) {
         boolean isStudylinkRecType = app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
         boolean isEmptyApplicant = String.isEmpty(app.hed__Applicant__c);
     
         if (oldItems == null && isStudylinkRecType && isEmptyApplicant) {
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
     private static void enqueueQueueableProcess(List<hed__Application__c> applications,String serviceClassName) {
         DynamicQueueableProcess queueableCalls = new DynamicQueueableProcess(applications,serviceClassName);
         System.enqueueJob(queueableCalls);
     }
     
    /**
     * @description: Matches application record type to process.
     * 
     * @param newItems The list of new StudyLink applications to process.
     * @param String recordTypeId of the application record for processing
     */ 
     public static void enqueueApplicationToExecute(List<hed__Application__c> newItems,String recordTypeId) {
         if(recordTypeId ==ApplicationsDAO.STUDYLINK_RECTYPE_ID){
             ApplicationService.matchStudyLinkApplicationToContactORLead(newItems);                               
         }
     }
     
    /**
     * @description: Matches StudyLink applications to existing Contacts or Leads based on application details.
     * 
     * @param newItems The list of new StudyLink applications to process.
     */ 
     public static void matchStudyLinkApplicationToContactORLead(List<hed__Application__c> newItems) {
         
         ContactsDAO.QueryParamWrapper applicationDetails = extractApplicationDetails(newItems);
         List<Contact> existingContacts = getContactsWithMatchingApplicationDetails(applicationDetails);
         ApplicationServiceHelper.mapOfContactIds = new Map<String, Set<Id>>();
         
         if (!existingContacts.isEmpty()) {
             Map<String, Map<Id, Contact>> contactsMap = createContactsMap(existingContacts, newItems);
             processMatchingContacts(newItems, contactsMap);
         } else {
             ApplicationServiceHelper.processNonMatchingContacts(newItems);           
         }
         
         addLogs(ApplicationServiceHelper.mapOfContactIds);
                 
         if (Logger.getBufferSize() > 0) {
             Logger.saveLog();
         }
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
             applicationDetails.emailsToMatch.add(app.Email__c);
             applicationDetails.firstNames.add(app.FirstName__c);
             applicationDetails.lastNames.add(app.LastName__c);
             applicationDetails.birthdates.add(app.Birthdate__c);
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
     public static void processMatchingContacts(List<hed__Application__c> newItems, Map<String, Map<Id, Contact>> contactsMap) {
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
         ApplicationsDAO.newInstance().updateRecords(updateApplicationList, false, AccessLevel.SYSTEM_MODE);
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
             String errorMsg = 'Email already exists in system but name doesn’t match contact '+ contactsIdMap.get(key) + ' , please investigate for manual matching of records ' + key;
             if(contactsIdMap.get(key).size() > 1){
                 errorMsg = 'There has been multiple matches found for the following application '+ key + ' , please investigate for manual matching of records - contact ' + contactsIdMap.get(key);
             }
             Logger.info(errorMsg);
         }
     }    
 }