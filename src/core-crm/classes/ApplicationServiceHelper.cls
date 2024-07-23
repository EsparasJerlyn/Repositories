/**
 * @description Service Class for Application Object use in trigger service class
 *
 * @see ApplicationTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------------------------------------------|
 *    | mark.j.mahilum                 | June 19,2023          | DEPP-5846	            | Created File                                                                   |
 *    | mark.j.mahilum                 | May 06, 2024          | DEPP-7987              | Repurposed this application helper to be use in ApplicationContactMatchingBatch|
 *    |                                |                       |                        | updated logic of application to contact matching                               |
 */
public inherited sharing class ApplicationServiceHelper {
    //contact matching type
    private static final Set<String> matchingTypes = new Set<String>{
        'System Key Matching',
        'Partial Natural Key Matching',
        'No DOB Matching',
        'Natural Key Matching',
        'First Name Stem Matching',
        'Maiden Name Matching'
    };

    /**
     * Execute the application to contact matching logic based on the given application records
     * using the ContactMatchingService class.
     *
     * @param List<hed__Application__c> The list of hed__Application__c objects.
     * @param contactsMap The map of string keys to nested maps of Ids to Contact objects.
     */
    public static void executeApplicationContactMatching(
        List<hed__Application__c> applicationList
    ) {
        Map<Id, String> mapOfApplicationUniqueKeys = new Map<Id, String>();
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();

        for (hed__Application__c app : applicationList) {
            app.Batch_Process__c = 'Processed';
            ContactMatchingService.MatchingAttributes contactMatchingAttribute = getMatchingAttributes(
                app
            );
            matchingRecords.add(contactMatchingAttribute);

            String uniqueKey = ContactMatchingService.generateUniqueKey(
                contactMatchingAttribute,
                new List<String>(contactMatchingAttribute.fieldValues.keySet())
            );
            if (String.isNotBlank(uniqueKey)) {
                mapOfApplicationUniqueKeys.put(app.Id, uniqueKey);
            }
        }

        try {
            // Process the contact matching
            Map<String, MatchingResult> resultMap = ContactMatchingService.processContactMatchingWithKeyChange(
                matchingRecords
            );

            // Process the matching results
            processMatchingResults(applicationList, resultMap, mapOfApplicationUniqueKeys);
        } catch (Exception e) {
            // Log any exceptions encountered during the process
            Logger.error(
                    'Exception caught in method execute in class ApplicationServiceHelper method executeApplicationContactMatching.'
                )
                .setExceptionDetails(e);
        } finally {
            // Update application and save log if necessary
            if (!applicationList.isEmpty()) {
                ApplicationsDAO.newInstance()
                    .updateRecords(applicationList, false, AccessLevel.SYSTEM_MODE);
            }
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    /**
     * @description: process match application to contact
     *
     * @param List<hed__Application__c> applicationList
     * @param Map<String, MatchingResult> resultMap
     * @param Map<Id, String> mapOfApplicationUniqueKeys
     */
    private static void processMatchingResults(
        List<hed__Application__c> applicationList,
        Map<String, MatchingResult> resultMap,
        Map<Id, String> mapOfApplicationUniqueKeys
    ) {
        List<hed__Application__c> updateMatchApplication = new List<hed__Application__c>();
        List<hed__Application__c> notMatchedApplications = new List<hed__Application__c>();

        for (hed__Application__c app : applicationList) {
            if (mapOfApplicationUniqueKeys.containsKey(app.Id)) {
                String appUniqueKey = mapOfApplicationUniqueKeys.get(app.Id);
                MatchingResult result = resultMap.get(appUniqueKey);
                boolean isError = result.error && String.isNotBlank(result.errorMessage);

                if (!result.error && matchingTypes.contains(result.matchingType)) {
                    app.hed__Applicant__c = (id) result.contactIds.iterator().next();
                    updateMatchApplication.add(app);
                } else if (isError) {
                    // Log error message from contact matching
                    if (result.errorMessage == 'Multiple match found') {
                        String logMessage =
                            'There has been multiple matches found for the following application ' +
                            app.Name +
                            ' , please investigate for manual matching of records - contact ' +
                            result.contactIds;
                        Logger.error(logMessage, app.Id);
                    } else {
                        Logger.error(result.errorMessage, app.Id);
                    }
                } else {
                    notMatchedApplications.add(app);
                }
            }
        }

        //update match application record
        if (!updateMatchApplication.isEmpty()) {
            ApplicationsDAO.newInstance()
                .updateRecords(updateMatchApplication, false, AccessLevel.SYSTEM_MODE);
        }

        //process not matching application
        processNotMatchingApplications(notMatchedApplications);
    }

    /**
     * Processes not-matching application records and performs necessary updates.
     *
     * @param newItems The list of hed__Application__c objects.
     */
    private static void processNotMatchingApplications(
        List<hed__Application__c> notMatchApplications
    ) {
        if (notMatchApplications.isEmpty()) {
            return;
        }

        Map<String, Contact> contactToInsertMap = new Map<String, Contact>();
        List<Contact> contactToInsert = new List<Contact>();
        List<hed__Application__c> applicationToLeadMatching = new List<hed__Application__c>();
        Map<String, List<hed__Application__c>> mapOfApplicationToContactKeys = new Map<String, List<hed__Application__c>>();

        for (hed__Application__c app : notMatchApplications) {
            Boolean isApplicationStatusNewUnsubmitted =
                app.Application_Status__c == 'New' ||
                app.Application_Status__c == 'Unsubmitted';

            if (
                isApplicationStatusNewUnsubmitted &&
                app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID
            ) {
                //add studylink application for lead matching
                if (String.isNotBlank(app.Email__c) || app.Lead__c != null) {
                    applicationToLeadMatching.add(app);
                } else {
                    // Log error message
                    Logger.error('Application email is empty', app.Id);
                }
            } else {
                ContactMatchingService.MatchingAttributes contactMatchingAttribute = getApplicationMatchingAttributes(
                    app
                );
                String uniqueKey = ContactMatchingService.generateUniqueKey(
                    contactMatchingAttribute,
                    new List<String>(contactMatchingAttribute.fieldValues.keySet())
                );

                if (String.isNotBlank(app.Email__c)) {
                    uniqueKey = app.Email__c;
                }

                // If the unique key value is not already a key in the map, create a new list for it
                if (!mapOfApplicationToContactKeys.containsKey(uniqueKey)) {
                    mapOfApplicationToContactKeys.put(uniqueKey, new List<hed__Application__c>());
                }

                // Add the contact record to the list associated with the system key value in the map
                mapOfApplicationToContactKeys.get(uniqueKey).add(app);

                if (String.isNotBlank(app.Email__c)) {
                    contactToInsertMap.put(app.Email__c, createContactFromApplication(app));
                } else {
                    contactToInsert.add(createContactFromApplication(app));
                }
            }
        }

        if (!contactToInsertMap.values().isEmpty()) {
            contactToInsert.addAll(contactToInsertMap.values());
        }

        //create new contact and link to the application record
        createContactAndUpdateApplicationApplicants(contactToInsert, mapOfApplicationToContactKeys);
        //match StudyLink application to existing unconverted lead record
        matchApplicationToLead(applicationToLeadMatching);
    }

    /**
     * @description: Create new contact and link the created contact to the application
     *
     * @param List<Contact> contactToInsert  a list of contact record that will be created.
     * @param Map<String, List<hed__Application__c>> mapOfApplicationToContactKeys map of application list.
     */
    private static void createContactAndUpdateApplicationApplicants(
        List<Contact> contactToInsert,
        Map<String, List<hed__Application__c>> mapOfApplicationToContactKeys
    ) {
        if (contactToInsert.isEmpty()) {
            return;
        }

        Map<String, Contact_Alternate_ID__c> contactAlternateIdsToInsert = new Map<String,Contact_Alternate_ID__c>();
        List<hed__Application__c> applicationToUpdate = new List<hed__Application__c>();

        Database.SaveResult[] saveResults = Database.insert(contactToInsert, false);

        //DML Contact save result
        for (integer i = 0; i < saveResults.size(); i++) {
            Contact con = contactToInsert[i];
            ContactMatchingService.MatchingAttributes contactMatchingAttribute = new ContactMatchingService.MatchingAttributes(
                new Map<String, String>{
                    'firstName' => String.isNotBlank(con.FirstName) ? con.FirstName : '',
                    'lastName' => String.isNotBlank(con.LastName) ? con.LastName : '',
                    'birthDate' => String.isNotBlank(String.valueOf(con.Birthdate))
                        ? String.valueOf(con.Birthdate)
                        : '',
                    'mobilePhone' => String.isNotBlank(con.Mobile_No_Locale__c)
                        ? String.valueOf(con.Mobile_No_Locale__c)
                        : '',
                    'email' => String.isNotBlank(con.Email) ? con.Email : ''
                }
            );

            String uniqueKey = ContactMatchingService.generateUniqueKey(
                contactMatchingAttribute,
                new List<String>(contactMatchingAttribute.fieldValues.keySet())
            );

            if (String.isNotBlank(con.Email)) {
                uniqueKey = con.Email;
            }

            if (saveResults.get(i).isSuccess()) {
                //add the code here if you want to do something in success case
                if (mapOfApplicationToContactKeys.containsKey(uniqueKey)) {
                    for (hed__Application__c app : mapOfApplicationToContactKeys.get(uniqueKey)) {
                        app.hed__applicant__c = saveResults.get(i).getId();
                        applicationToUpdate.add(app);
                        createContactAlternateIds(contactAlternateIdsToInsert,app);
                    }
                }
            } else if (!saveResults.get(i).isSuccess()) {
                // Operation failed, so get all errors and relate to the application record
                Database.Error dbError = saveResults.get(i).getErrors().get(0);
                if (mapOfApplicationToContactKeys.containsKey(uniqueKey)) {
                    for (hed__Application__c app : mapOfApplicationToContactKeys.get(uniqueKey)) {
                        // Log error message
                        Logger.error(dbError.getStatusCode() + ': ' + dbError.getMessage(), app.Id);
                    }
                }
            }
        }

        if (!applicationToUpdate.isEmpty()) {
            ApplicationsDAO.newInstance()
                .updateRecords(applicationToUpdate, false, AccessLevel.SYSTEM_MODE);
        }

        if(!contactAlternateIdsToInsert.isEmpty()){
            ContactAlternateIdsDAO.newInstance().insertRecords(
                contactAlternateIdsToInsert.values(),
                false,
                AccessLevel.SYSTEM_MODE
            );
        }
    }

    /**
     * Creates Contact_Alternate_ID__c records based on the StudyLink and QTAC applicant IDs from a hed__Application__c record.
     * @param contactAlternateIdsToInsert Map to store Contact_Alternate_ID__c records to insert.
     * @param app The hed__Application__c record containing applicant details.
     */
    private static void createContactAlternateIds(Map<String, Contact_Alternate_ID__c> contactAlternateIdsToInsert, hed__Application__c app) {
        // Creating Contact_Alternate_ID__c record for StudyLink Applicant ID if present
        if (String.isNotBlank(app.StudyLink_ApplicantID__c)) {
            contactAlternateIdsToInsert.put(
                app.hed__Applicant__c + ContactAlternateIdsDAO.STUDYLINK_ID_TYPE,
                new Contact_Alternate_ID__c(
                    Contact_Alternate_Id__c = app.StudyLink_ApplicantID__c,
                    Alternate_Id_Status__c = 'Active',
                    Alternate_Id_Type__c = ContactAlternateIdsDAO.STUDYLINK_ID_TYPE,
                    Start_Date__c = System.Today(),
                    Contact__c = app.hed__Applicant__c
                )
            );
        }

        // Creating Contact_Alternate_ID__c record for QTAC Applicant ID if present
        if (String.isNotBlank(app.QTAC_ApplicantID__c)) {
            contactAlternateIdsToInsert.put(
                app.hed__Applicant__c + ContactAlternateIdsDAO.QTAC_ID_TYPE,
                new Contact_Alternate_ID__c(
                    Contact_Alternate_Id__c = app.QTAC_ApplicantID__c,
                    Alternate_Id_Status__c = 'Active',
                    Alternate_Id_Type__c = ContactAlternateIdsDAO.QTAC_ID_TYPE,
                    Start_Date__c = System.Today(),
                    Contact__c = app.hed__Applicant__c
                )
            );
        }
    }



    /**
     * @description: Match application to Existing Unconverted lead record using email
     *
     * @param List<hed__Application__c>> applicationList application list record.
     */
    private static void matchApplicationToLead(List<hed__Application__c> applicationList) {
        if (applicationList.isEmpty()) {
            return;
        }

        Map<String, List<hed__Application__c>> mapOfApplicationToLeadKeys = new Map<String, List<hed__Application__c>>();
        List<Lead> updateLeadRecords = new List<Lead>();

        for (hed__Application__c app : applicationList) {
            if (app.Lead__c != null) {
                Lead lead = createLeadFromApplication(app);
                lead.Id = app.Lead__c;
                updateLeadRecords.add(lead);
            } else {
                String uniqueKey = app.Email__c;
                // If the unique key value is not already a key in the map, create a new list for it
                if (!mapOfApplicationToLeadKeys.containsKey(uniqueKey)) {
                    mapOfApplicationToLeadKeys.put(uniqueKey, new List<hed__Application__c>());
                }
                // Add the application record to the unique key
                mapOfApplicationToLeadKeys.get(uniqueKey).add(app);
            }
        }

        if (!updateLeadRecords.isEmpty()) {
            LeadsDAO.newInstance().updateRecords(updateLeadRecords, false, AccessLevel.SYSTEM_MODE);
        }

        //match application record to existing lead using email fields
        matchApplicationEmailToExistingLead(mapOfApplicationToLeadKeys);
    }

    /**
     * @description: Checks for existing emails in the mapOfApplicationToLeadKeys map.
     * 				Match the existing lead if has one match and link to application
     *               Else if multiple matched throw error log
     *               Creates Lead and link to application if not existing
     *
     * @param Map<String, List<hed__Application__c>> mapOfApplicationToLeadKeys
     */
    private static void matchApplicationEmailToExistingLead(
        Map<String, List<hed__Application__c>> mapOfApplicationToLeadKeys
    ) {
        if (mapOfApplicationToLeadKeys.values().isEmpty()) {
            return;
        }

        Map<String, Lead> mapOfLeads = new Map<String, Lead>();
        List<hed__Application__c> applicationToUpdate = new List<hed__Application__c>();

        for (
            Lead lead : LeadsDAO.newInstance()
                .getExistingUnconvertedLeads(mapOfApplicationToLeadKeys.keySet(), 'SYSTEM_MODE')
        ) {
            if (String.isNotBlank(lead.email)) {
                mapOfLeads.put(lead.email, lead);
            }
            if (String.isNotBlank(lead.Work_Email__c)) {
                mapOfLeads.put(lead.Work_Email__c, lead);
            }
        }

        for (String uniqueKey : mapOfApplicationToLeadKeys.keySet()) {
            if (mapOfLeads.containsKey(uniqueKey)) {
                for (hed__Application__c app : mapOfApplicationToLeadKeys.get(uniqueKey)) {
                    app.Lead__c = mapOfLeads.get(uniqueKey).Id;
                    applicationToUpdate.add(app);
                }
            } else {
                for (hed__Application__c app : mapOfApplicationToLeadKeys.get(uniqueKey)) {
                    Lead lead = createLeadFromApplication(app);
                    mapOfLeads.put(lead.email, lead);
                }
            }
        }

        if (!applicationToUpdate.isEmpty()) {
            ApplicationsDAO.newInstance()
                .updateRecords(applicationToUpdate, false, AccessLevel.SYSTEM_MODE);
        }

        //create lead and link to the application record
        createLeadAndUpdateApplicationLead(mapOfLeads.values(), mapOfApplicationToLeadKeys);
    }

    /**
     * @description: Create new lead and link the created lead to the application
     *
     * @param List<Lead> leadToInsert  a list of lead record that will be created.
     * @param Map<String, List<hed__Application__c>> mapOfApplicationToLeadKeys
     */
    private static void createLeadAndUpdateApplicationLead(
        List<Lead> leadToInsert,
        Map<String, List<hed__Application__c>> mapOfApplicationToLeadKeys
    ) {
        if (leadToInsert.isEmpty()) {
            return;
        }

        List<hed__Application__c> applicationToUpdate = new List<hed__Application__c>();
        Database.SaveResult[] saveResults = Database.insert(leadToInsert, false);

        //DML save result
        for (integer i = 0; i < saveResults.size(); i++) {
            Lead lead = leadToInsert[i];

            if (saveResults.get(i).isSuccess()) {
                //add the code here if you want to do something in success case
                if (mapOfApplicationToLeadKeys.containsKey(lead.Email)) {
                    for (hed__Application__c app : mapOfApplicationToLeadKeys.get(lead.Email)) {
                        app.Lead__c = saveResults.get(i).getId();
                        applicationToUpdate.add(app);
                    }
                }
            } else if (!saveResults.get(i).isSuccess()) {
                // Operation failed, so get all errors
                Database.Error dbError = saveResults.get(i).getErrors().get(0);
                if (mapOfApplicationToLeadKeys.containsKey(lead.Email)) {
                    for (hed__Application__c app : mapOfApplicationToLeadKeys.get(lead.Email)) {
                        // Log error message
                        Logger.error(dbError.getStatusCode() + ': ' + dbError.getMessage(), app.Id);
                    }
                }
            }
        }

        if (!applicationToUpdate.isEmpty()) {
            ApplicationsDAO.newInstance()
                .updateRecords(applicationToUpdate, false, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * @description: mapping of Contact Matching Attribute fields
     *
     * @param hed__Application__c   hed__Application__c objects.
     * @return ContactMatchingService.MatchingAttributes
     */
    private static ContactMatchingService.MatchingAttributes getMatchingAttributes(
        hed__Application__c app
    ) {
        Map<String, String> attributesMap = new Map<String, String>{
            'firstName' => String.isNotBlank(app.FirstName__c) ? app.FirstName__c : '',
            'lastName' => String.isNotBlank(app.LastName__c) ? app.LastName__c : '',
            'birthDate' => String.isNotBlank(String.valueOf(app.BirthDate__c))
                ? String.valueOf(app.BirthDate__c)
                : '',
            'mobilePhone' => String.isNotBlank(app.Mobile__c) ? String.valueOf(app.Mobile__c) : '',
            'email' => String.isNotBlank(app.Email__c) ? app.Email__c : '',
            'qutStudentId' => String.isNotBlank(app.QUT_Student_ID__c) ? app.QUT_Student_ID__c : '',
            'studyLinkApplicantId' => String.isNotBlank(app.StudyLink_ApplicantID__c)
                ? app.StudyLink_ApplicantID__c
                : '',
            'qtacApplicantId' => String.isNotBlank(app.QTAC_ApplicantID__c)
                ? app.QTAC_ApplicantID__c
                : '',
            'qutEmployeeId' => ''
        };
        return new ContactMatchingService.MatchingAttributes(attributesMap);
    }

    /**
     * @description: mapping of Contact attribute fields
     *
     * @param hed__Application__c   hed__Application__c objects.
     * @return ContactMatchingService.MatchingAttributes
     */
    private static ContactMatchingService.MatchingAttributes getApplicationMatchingAttributes(
        hed__Application__c app
    ) {
        Map<String, String> attributesMap = new Map<String, String>{
            'firstName' => String.isNotBlank(app.FirstName__c) ? app.FirstName__c : '',
            'lastName' => String.isNotBlank(app.LastName__c) ? app.LastName__c : '',
            'birthDate' => String.isNotBlank(String.valueOf(app.BirthDate__c))
                ? String.valueOf(app.BirthDate__c)
                : '',
            'mobilePhone' => String.isNotBlank(app.Mobile__c) ? String.valueOf(app.Mobile__c) : '',
            'email' => String.isNotBlank(app.Email__c) ? app.Email__c : ''
        };
        return new ContactMatchingService.MatchingAttributes(attributesMap);
    }

    /**
     * @description: mapping of application fields to contact
     *
     * @param hed__Application__c   hed__Application__c objects.
     * @return Contact contact mapping details
     */
    private static Contact createContactFromApplication(hed__Application__c application) {
        Contact contact = new Contact();
        contact.FirstName = application.FirstName__c;
        contact.MiddleName = application.MiddleName__c;
        contact.LastName = application.LastName__c;
        contact.Birthdate = application.BirthDate__c;
        contact.Email = application.Email__c;
        contact.Mobile_No_Locale__c = application.Mobile__c;
        contact.ATSI_Code__c = application.Indigenous_Status__c;
        contact.hed__Citizenship_Status__c = application.Citizenship_Status__c;
        contact.Citizenship_Country__c = application.Citizenship_Country__c;
        contact.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        if(application.Mobile__c != null){
            contact.ContactMobile_Locale__c = ContactsDAO.AU_LOCALE;
        }
        return contact;
    }

    /**
     * @description: map application details to lead fields
     *
     * @param hed__Application__cleads new application mapping
     * @return lead object
     */
    private static Lead createLeadFromApplication(hed__Application__c app) {
        Lead lead = new Lead();
        //Lead Fields as Key => Application fields as value
        Map<String, String> fieldMapping = new Map<String, String>{
            'FirstName' => 'FirstName__c',
            'LastName' => 'LastName__c',
            'Email' => 'Email__c',
            'Mobile_No_Locale__c' => 'Mobile__c'
        };

        //Lead Object fields is use as the key for the Application field
        for (String key : fieldMapping.keySet()) {
            //targetField is the contact object fields
            String targetField = fieldMapping.get(key);

            //only the application field that is not null will be updated into the contact object fields
            if (app.get(targetField) != null) {
                lead.put(key, app.get(targetField));
            }
        }

        lead.put('Company', 'Learner');
        lead.put('Lead_Type__c', 'Learner');

        if(app.get(Mobile__c) != null){
            lead.put('LeadMobile_Locale__c',LeadsDAO.AU_LOCALE);
        }

        return lead;
    }
}
