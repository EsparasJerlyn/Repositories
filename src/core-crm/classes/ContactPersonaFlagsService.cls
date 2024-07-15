/**
 * @description Service Class for ContactPersonaFlagsService class updating the Contact Object use in multiple trigger
 *
 * @see ContactPersonaFlagsService
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                       |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------------------------------------------------|
 *    | mark.j.mahilum                 | July 10,2023          | DEPP-5799	            | Created File                                                                         |
 *    | mark.j.mahilum                 | Aug 29.2023           | DEPP-6523              | Updated updateContactOnApplication to include removal of application link to contact |
 *    | mark.j.mahilum                 | Aug 31,2023           | DEPP-6455              | Updated multiple method name to describe the field in contact to be updated          |
 *    | mark.j.mahilum                 | June 06, 2024         | DEPP-9212              | Updated to removed redundant code in the updateContactPartnerFlag method             |
 */
public with sharing class ContactPersonaFlagsService {//NOPMD Service Class(Not methods) can have a high amount of complexity and public methods
    /**
     * @description: Checks existing application records of the contact
     *
     * @param Set<Id> contactIds to evaluate
     */
    public static void updateContactApplicantFlag(Set<Id> contactIds) {
        Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
        String newJourneyStatus = '';

        List<hed__Application__c> existingApplicationList = ApplicationsDAO.newInstance()
            .getApplicationsActiveApplicants(contactIds, 'SYSTEM_MODE');
        
        Set<Id> contactWithActiveApplications = new Set<Id>();

        for (hed__Application__c app : existingApplicationList) {

            //get all the contact with active applications
            contactWithActiveApplications.add(app.hed__Applicant__c);

            boolean isApplicant = true;
            
            //get new journey status
            //this will have a value if conditions are satisfied
            newJourneyStatus = FutureStudentJourneyStatusHelper.getNewJourneyStatus(
                new Contact(
                    QUT_Student__c = app.hed__Applicant__r.QUT_Student__c,
                    QUT_Applicant__c = isApplicant
                ),
                app,
                updateContactMap
            );

            //Skip update on contacts that is already an Applicant = TRUE
            //And Future Student Journey Status unchanged
            if( app.hed__Applicant__r.QUT_Applicant__c && 
                app.hed__Applicant__r.Future_Student_Journey_Status__c == newJourneyStatus ){
                continue;
            }

            

            //if new value is blank
            //make sure not to overwrite status of contact to be updated
            if (
                String.isBlank(newJourneyStatus) &&
                updateContactMap.containsKey(app.hed__Applicant__c)
            ) {
                newJourneyStatus = updateContactMap.get(app.hed__Applicant__c)
                    .Future_Student_Journey_Status__c;
            }


            //checks if contact is already for update
            //if no updates on QUT Applicant and Future Student Journey Status
            Boolean isContactAlreadyUpdated =
                updateContactMap.containsKey(app.hed__Applicant__c) &&
                updateContactMap.get(app.hed__Applicant__c).QUT_Applicant__c == isApplicant &&
                updateContactMap.get(app.hed__Applicant__c).Future_Student_Journey_Status__c ==
                newJourneyStatus;

            if (isContactAlreadyUpdated) {
                continue;
            }

            //finally add contact for update
            updateContactMap.put(
                app.hed__Applicant__c,
                new Contact(
                    Id = app.hed__Applicant__c,
                    QUT_Applicant__c = isApplicant,
                    Future_Student_Journey_Status__c = newJourneyStatus
                )
            );
        }

        Set<Id> contactIdsWithNoActiveApplication = new Set<Id>();
        //contact with no active application update QUT_Applicant flag to false
        for (Id contactId : contactIds) {
            if (!contactWithActiveApplications.contains(contactId)) {
                contactIdsWithNoActiveApplication.add(contactId);
            }
        }
        
        //get application link to contacts
        List<hed__Application__c> getApplicationFromContactIds = ApplicationsDAO.newInstance()
            .getApplicationsByContactIds(contactIdsWithNoActiveApplication, 'SYSTEM_MODE');
        
        for (hed__Application__c app : getApplicationFromContactIds) {         
            //update only the contact with Active QUT_Application to false
            if(app.hed__Applicant__r.QUT_Applicant__c){
                updateContactMap.put(
                    app.hed__Applicant__c,
                    new Contact(
                        Id = app.hed__Applicant__c, 
                        QUT_Applicant__c = false, 
                        //set to blank - will be reevaluated for 'Explore' in contact trigger
                        Future_Student_Journey_Status__c = ''
                    )
                );
            }          
        }

        if (!updateContactMap.values().isEmpty()) {
            updateContactRecord(updateContactMap.values());
        }
    }

    /**
     * @description: Checks existing program enrollment records linked to contact
     *
     * @param Set<Id> contactIds to evaluate
     * @return Map<Id,Contact> contact to be updated
     */
    private static void updateContactOnStudentFlag(Set<Id> contactIds) {
        Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
        Set<Id> contactIdsToReEvaluateApplication = new Set<Id>();
        List<hed__Program_Enrollment__c> programEnrollmentsList =  ProgramEnrollmentsDAO.newInstance().getProgramEnrollmentsByContactIds(contactIds,'SYSTEM_MODE'); 
        List<hed__Program_Enrollment__c> programEnrollmentsListByContacts =  ProgramEnrollmentsDAO.newInstance().getAllProgramEnrollmentsByContactId(contactIds, AccessLevel.SYSTEM_MODE);
        List<hed__Application__c> applicationListByContacts = ApplicationsDAO.newInstance().getApplicationsByContactIds(contactIds, 'SYSTEM_MODE');
        String newJourneyStatus = '';
        Map<Id, Contact> updateContactWithoutProgEnrollmentMap = new Map<Id, Contact>();
        Map<Id, hed__Program_Enrollment__c> mapContactIdProgramEnrollment = new Map<Id, hed__Program_Enrollment__c>();
        Map<Id, hed__Application__c> mapContactIdApplication = new Map<Id, hed__Application__c>();
        

        //collect all student for update that has no program enrollments
        for(hed__Program_Enrollment__c pe: programEnrollmentsListByContacts){
            mapContactIdProgramEnrollment.put(
                pe.hed__Contact__c, pe
            );
        }

        for(hed__Application__c ap: applicationListByContacts){
            mapContactIdApplication.put(
                ap.hed__Applicant__c, ap
            );
        }

        for (Id contactId : contactIds) {
            if(!mapContactIdProgramEnrollment.containsKey(contactId) && !mapContactIdApplication.containsKey(contactId)){
                updateContactWithoutProgEnrollmentMap.put(
                    contactId,
                    new Contact(
                        id = contactId,
                        QUT_Student__c = false
                    )
                );
            }
        }

        //collect all contact that is a student or withdrawn or passed
        for(hed__Program_Enrollment__c pe: programEnrollmentsList){
            if (pe.Enrollment_Status__c == ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED) {
                updateContactMap.put(
                    pe.hed__Contact__c,
                    new Contact(
                        id = pe.hed__Contact__c,
                        QUT_Student__c = true
                    )
                );
            } else if(
                (pe.Enrollment_Status__c == ProgramEnrollmentsDAO.ENROLLMENT_STAGE_WITHDRAWN 
                || pe.Enrollment_Status__c == ProgramEnrollmentsDAO.ENROLLMENT_STATUS_PASSED)
                && !mapContactIdApplication.containsKey(pe.hed__Contact__c)
            ) {
                updateContactMap.put(
                    pe.hed__Contact__c,
                    new Contact(
                        id = pe.hed__Contact__c,
                        QUT_Student__c = false
                    )
                );
            }
            
        }

        //collect all contact ids that is no longer a student
        for (Id contactId : contactIds) {
            if (!updateContactMap.containsKey(contactId)) {
                contactIdsToReEvaluateApplication.add(contactId);
            }
        }

        //loop thru all the applications related to the contacts
        for (
            hed__Application__c app : ApplicationsDAO.newInstance()
                .getApplicationsByContactIds(contactIdsToReEvaluateApplication, 'SYSTEM_MODE')
        ) {

            //get new journey status
            //this will have a value if conditions are satisfied
            newJourneyStatus = FutureStudentJourneyStatusHelper.getNewJourneyStatus(
                new Contact(
                    QUT_Student__c = false,
                    QUT_Applicant__c = app.hed__Applicant__r.QUT_Applicant__c
                ),
                app,
                updateContactMap
            );

            //if new value is blank
            //make sure not to overwrite status of contact to be updated
            if (
                String.isBlank(newJourneyStatus) &&
                updateContactMap.containsKey(app.hed__Applicant__c)
            ) {
                newJourneyStatus = updateContactMap.get(app.hed__Applicant__c)
                    .Future_Student_Journey_Status__c;
            }

            //checks if contact is already for update
            //no upates on QUT Applicant and Future Student Journey Status
            Boolean isContactAlreadyUpdated =
                updateContactMap.containsKey(app.hed__Applicant__c) &&
                updateContactMap.get(app.hed__Applicant__c).Future_Student_Journey_Status__c ==
                newJourneyStatus &&
                updateContactMap.get(app.hed__Applicant__c).QUT_Student__c == false;

            //skip this process and do not try to update contact with the same values
            if (isContactAlreadyUpdated) {
                continue;
            }

            //finally add contact for update
            updateContactMap.put(
                app.hed__Applicant__c,
                new Contact(
                    Id = app.hed__Applicant__c,
                    QUT_Student__c = false,
                    Future_Student_Journey_Status__c = newJourneyStatus
                )
            );
        }

        if (!updateContactMap.values().isEmpty()) {
            updateContactRecord(updateContactMap.values());
        }
        if (!updateContactWithoutProgEnrollmentMap.values().isEmpty()) {
            updateContactRecord(updateContactWithoutProgEnrollmentMap.values());
        }
    }

    /**
     * @description: Checks existing contextual role or opportunity contact role linked to 
     *               contact and update the Contact partner flag
     *
     * @param Set<Id> contactIds to evaluate
     * @return Map<Id,Contact> contact to be updated
     */
    private static void updateContactPartnerFlag(Set<Id> contactIds) {
        Map<Id,Contact> updateContactMap = new Map<Id,Contact>();         
        Set<String> recordTypeIds = new Set<String>{ContextualRolesDAO.ENGAGEMENT_ROLE_RECTYPE_ID,ContextualRolesDAO.OPPORTUNITY_ROLE_RECTYPE_ID};
        List<Contextual_Role__c> contextualRoleList = ContextualRolesDAO.newInstance().getActiveContextualRoleByContactIds(contactIds,recordTypeIds,'SYSTEM_MODE');  
               
        for(Contextual_Role__c cr: contextualRoleList){          
            updateContactMap.put(
                cr.Contact__c,
                new Contact(
                    id = cr.Contact__c,
                    QUT_Partner__c = true
                )
            );             
        }
        
        List<OpportunityContactRole> ocrList = OpportunityContactRolesDAO.newInstance().getOpportunityContactRoleByRoleContactIds(contactIds,new Set<String>{'Client Decision-Maker'},'SYSTEM_MODE');

        for (OpportunityContactRole ocr : ocrList){
            updateContactMap.put(
                ocr.ContactId,
                new Contact(
                    id = ocr.ContactId,
                    QUT_Partner__c = true
                )
            );
        }      
        
        for (Id contactId : contactIds) {
            if (!updateContactMap.containsKey(contactId)) {
                updateContactMap.put(
                    contactId,
                    new Contact(id = contactId, QUT_Partner__c = false)
                );
            }
        }

        if (!updateContactMap.values().isEmpty()) {
            updateContactRecord(updateContactMap.values());
        }
    }

    /**
     * @description Enqueues the contactIds to be check and updated
     *
     * @param Set<Id> contactIds contact Ids to be updated
     * @param String methodName the method name to execute
     */
    public static void processContactIds(Set<Id> contactIds, String methodName) {
        QueueableCall executeQueueable = new QueueableCall(contactIds, methodName);
        System.enqueueJob(executeQueueable);
    }

    /**
     * @description: Updating the contact record
     *
     * @param List<Contact> updateContactList
     */
    private static void updateContactRecord(List<Contact> updateContactList) {
        ContactsDAO.newInstance().updateRecords(updateContactList, false, AccessLevel.SYSTEM_MODE);
    }
    
    /**
     * @description: Queueable local apex class that execute method into queuable callout
     *
     * @param Set<Id> contactIds
     * @param String methodName
     */
    private class QueueableCall implements Queueable {
        private Set<Id> contactIds;
        private String methodNames;

        public QueueableCall(Set<Id> contactId, String methodName) {
            this.contactIds = contactId;
            this.methodNames = methodName;
        }
        public void execute(QueueableContext context) {
            if (methodNames == 'updateContactOnStudentFlag') {
                updateContactOnStudentFlag(contactIds);
            }
            if (methodNames == 'updateContactApplicantFlag') {
                updateContactApplicantFlag(contactIds);
            }
            if (methodNames == 'updateContactPartnerFlag') {
                updateContactPartnerFlag(contactIds);
            }
        }
    }
}