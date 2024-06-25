/**
 * Handles the processing of duplicate student sanctions, including calling an external service to handle duplicates,
 * updating related records, and logging any errors encountered during the process.
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                                        								|
 *    |---------------------------|-----------------------|--------------|------------------------------------------------------------------------------------------------------|
 *    | roy.nino.s.regala         | April 16, 2024        | DEPP-7984    | Created File
*/ 
public inherited sharing class DuplicateSanctionManager {

    // Endpoint for calling the external service to refresh student data
    private static final String ENDPOINT_ESB_SAMS_REFRESH_STUDENT = System.Label.ESBSAMSRefreshStudent;
    // Error message for missing QUT student ID
    private static final String MISSING_STUDENT_ID = 'Missing QUT student Id';
    // Error message for missing student sanction
    private static final String MISSING_STUDENT_SANCTION = 'Sanction Student Not Found';

    /**
     * Processes the given list of student sanctions by calling an external service to handle duplicates.
     * Updates related records and logs any errors encountered during the process.
     *
     * @param studentSanctions The list of student sanctions to be processed.
     */
    public static void callOutESBSAMSRefreshStudent(List<Student_Sanction__c> studentSanctions) {
        // Set to store QUT student IDs from student sanctions
        Set<String> qutStudentIds = new Set<String>();
        // Lists to store records to be updated
        List<Contact_Alternate_Id__c> conAltIdToUpdate = new List<Contact_Alternate_ID__c>();
        List<Contact> contactsToUpdate = new List<Contact>();
        // List to store request body for callout
        List<RequestBody> requestList = new List<RequestBody>();
        // Sets to store lone QUT student IDs and all QUT student IDs in DEP
        Set<String> loneQUTStudentIds = new Set<String>();
        Set<String> allQUTSudentIdsInDEP = new Set<String>();
        // Map of latest suprseded alternate id related to a contact
        Map<Id, Contact_Alternate_Id__c> alternateIdByContactMap = new Map<Id, Contact_Alternate_Id__c>();
        Contact_Alternate_Id__c supersededAltId;

        // Extract QUT student IDs from student sanctions
        for (Student_Sanction__c studentSanction : studentSanctions) {
            qutStudentIds.add(studentSanction.QUT_Student_ID__c);
            // Mark the student sanction as processed
            studentSanction.Batch_Process__c = StudentSanctionsDAO.PROCESSED;
        }

        try {
            // Retrieve student alternate IDs
            List<Contact_Alternate_Id__c> conAltIdRecords = ContactAlternateIdsDAO.newInstance()
                .getStudentAlternateIdsByStudentIds(qutStudentIds, AccessLevel.USER_MODE);

            // get the latest superseded alternate id related to the contact sorted by createddate
            getLatestSupersededAlternateIds(alternateIdByContactMap, conAltIdRecords);

            // Process retrieved alternate IDs
            for (Contact_Alternate_ID__c conAltId : conAltIdRecords) {
                // collect alternate ids
                allQUTSudentIdsInDEP.add(conAltId.Contact_Alternate_Id__c);

                // current alternate id in the loop is an Active Contact Alternate Id
                if (conAltId.Alternate_Id_Status__c == ContactAlternateIdsDAO.ACTIVE_STATUS) {
                    //if there are no superseded alternate ids
                    if (!alternateIdByContactMap.containsKey(conAltId.Contact__c)) {
                        // collect active alternate ids without superseded ids
                        loneQUTStudentIds.add(conAltId.Contact_Alternate_Id__c);
                        continue;
                    }

                    // get the latest superseded contact alternate id
                    supersededAltId = alternateIdByContactMap.get(conAltId.Contact__c);

                    // Update status to 'Duplicate Sanction' for current active contact alternate ID
                    conAltIdToUpdate.add(
                        new Contact_Alternate_ID__c(
                            Id = conAltId.Id,
                            Alternate_Id_Status__c = ContactAlternateIdsDAO.DUPLICATE_SANCTION_STATUS,
                            End_Date__c = System.today()
                        )
                    );

                    // Update the superseded alternate ID to 'Active' and nullify the end date
                    conAltIdToUpdate.add(
                        new Contact_Alternate_ID__c(
                            Id = supersededAltId.Id,
                            Alternate_Id_Status__c = ContactAlternateIdsDAO.ACTIVE_STATUS,
                            End_Date__c = null
                        )
                    );

                    // Update the related contact's QUT student ID
                    contactsToUpdate.add(
                        new Contact(
                            Id = conAltId.Contact__c,
                            QUT_Student_ID__c = supersededAltId.Contact_Alternate_ID__c
                        )
                    );

                    // Add request body for callout
                    requestList.add(
                        new RequestBody(conAltId.Contact__c, conAltId.Contact_Alternate_ID__c)
                    );
                } else if(conAltId.Alternate_Id_Status__c == ContactAlternateIdsDAO.SUPERSEDED_STATUS){
                    // Update status to 'Duplicate Sanction' for current superseded alternate id
                    conAltIdToUpdate.add(
                        new Contact_Alternate_ID__c(
                            Id = conAltId.Id,
                            Alternate_Id_Status__c = ContactAlternateIdsDAO.DUPLICATE_SANCTION_STATUS
                        )
                    );
                }
            }

            // Validate student sanctions
            validateStudentSanctions(studentSanctions, loneQUTStudentIds, allQUTSudentIdsInDEP);
            // Perform callout
            doCallout(requestList);
            // Update records
            updateRecords(conAltIdToUpdate, contactsToUpdate);
        } catch (Exception e) {
            // Log any exceptions encountered during the process
            Logger.error(
                    'Exception caught in method execute in class DuplicateSanctionManager method callOutESBSAMSRefreshStudent.'
                )
                .setExceptionDetails(e);
        } finally {
            // Update student sanctions and save log if necessary
            if (!studentSanctions.isEmpty()) {
                StudentSanctionsDAO.newInstance()
                    .updateRecords(studentSanctions, false, AccessLevel.USER_MODE);
            }

            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    /**
     * Retrieves the latest superseded alternate IDs for a list of contacts and maps them by contact ID.
     *
     * @param alternateIdByContactMap A map to store the latest superseded alternate IDs by contact ID.
     * @param conAltIdRecords The list of Contact_Alternate_ID__c records to be processed.
     */
    private static void getLatestSupersededAlternateIds(
        Map<Id, Contact_Alternate_ID__c> alternateIdByContactMap,
        List<Contact_Alternate_ID__c> conAltIdRecords
    ) {
        Set<Id> contactIds = new Set<Id>();
        // collect contact ids
        for (Contact_Alternate_Id__c conAltId : conAltIdRecords) {
            contactIds.add(conAltId.Contact__c);
        }

        // retrieve all superseded contact alternate ids related to the contact
        List<Contact_Alternate_ID__c> supersededAlternateIds = ContactAlternateIdsDAO.newInstance()
            .getContactAlternateIdsByContactIdSetAndStatus(
                contactIds,
                new Set<String>{ ContactAlternateIdsDAO.SUPERSEDED_STATUS },
                AccessLevel.SYSTEM_MODE
            );

        // collect the latest(ordered by CreateDate) superseded alternate id related to the contact
        for (Contact_Alternate_Id__c conAltId : supersededAlternateIds) {
            if (!alternateIdByContactMap.containsKey(conAltId.Contact__c)) {
                alternateIdByContactMap.put(conAltId.Contact__c, conAltId);
            }
        }
    }

    /**
     * Validates the student sanctions by checking for missing QUT student IDs or missing student sanctions.
     * 
     * @param studentSanctions The list of student sanctions to be validated.
     * @param loneQUTStudentIds The set of lone QUT student IDs.
     * @param allQUTSudentIdsInDEP The set of all QUT student IDs in DEP.
     */
    private static void validateStudentSanctions(List<Student_Sanction__c> studentSanctions, Set<String> loneQUTStudentIds, Set<String> allQUTSudentIdsInDEP){
        for(Student_Sanction__c studentSanction: studentSanctions){

            if(loneQUTStudentIds.contains(studentSanction.QUT_Student_ID__c)){
                // Log error for missing student sanction
                Logger.error('Sanction Student Not Found', studentSanction.Id);
            }

            if(!allQUTSudentIdsInDEP.contains(studentSanction.QUT_Student_ID__c)){
                // Log error for missing QUT student ID
                Logger.error('Missing QUT student Id', studentSanction.Id);
            }
        }
    }

    /**
     * Updates the records including contact alternate IDs and contacts.
     * 
     * @param conAltIdToUpdate The list of contact alternate IDs to update.
     * @param contactsToUpdate The list of contacts to update.
     */
    private static void updateRecords(List<Contact_Alternate_Id__c> conAltIdToUpdate, List<Contact> contactsToUpdate){

        if(!conAltIdToUpdate.isEmpty()){
            // Update contact alternate IDs
            ContactAlternateIdsDAO.newInstance().updateRecords(conAltIdToUpdate, false, AccessLevel.USER_MODE);
        }

        if(!contactsToUpdate.isEmpty()){
            // Update contacts
            ContactsDAO.newInstance().updateRecords(contactsToUpdate, false, AccessLevel.USER_MODE);
        }
    }

    /**
     * Performs the callout to the external service for refreshing student data.
     * 
     * @param requestList The list of request bodies for the callout.
     */
    private static void doCallout(List<RequestBody> requestList) {
        if(requestList.isEmpty()){
            return;
        }

        HTTPResponse httpResponse;

        try{
            // Perform callout to refresh student data
            String endpoint = 'callout:ESB' + ENDPOINT_ESB_SAMS_REFRESH_STUDENT;
            httpResponse = IntegrationCallOutCtrl.doCallout(endpoint, 'POST', JSON.serialize(requestList));
            if(httpResponse.getStatusCode() != 200){
                // Log error if callout fails
                Logger.error(httpResponse.getStatusCode() + ' status on Inserting Student Sanction').setHttpResponseDetails(httpResponse);
            }

        } catch(Exception e){
            // Log any callout exceptions
            Logger.error('Callout Exception on Inserting Student Sanction ').setExceptionDetails(e).setHttpResponseDetails(httpResponse);
        }
    }

    /**
     * Inner class representing the request body for the callout.
     */
    private class RequestBody{
        // Contact ID for the callout
        private String ContactID {get; set; }
        // Student ID for the callout
        private String StudentID {get; set; }

        /**
         * Constructor to initialize the request body with contact ID and student ID.
         * 
         * @param contactId The contact ID.
         * @param studentId The student ID.
         */
        private RequestBody(String contactId, String studentId) {
            this.ContactID = contactId;
            this.StudentID = studentId;   
        }
    }
}