/**
 * @description Service Class for ContactPersonaFlagsService class updating the Contact Object use in multiple trigger
 *
 * @see ContactPersonaFlagsService
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------|
 *    | mark.j.mahilum                 | July 10,2023          | DEPP-5799	            | Created File                  |
 */
public with sharing class ContactPersonaFlagsService {//NOPMD Service Class(Not methods) can have a high amount of complexity and public methods
    /**
     * @description: Checks existing application records of the contact
     *
     * @param Set<Id> contactIds to evaluate
     */
    private static void updateContactOnApplication(Set<Id> contactIds) {
        Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
        String newJourneyStatus = '';

        List<hed__Application__c> existingApplicationList = ApplicationsDAO.newInstance()
            .getApplicationsByContactIds(contactIds, 'SYSTEM_MODE');

        for (hed__Application__c app : existingApplicationList) {
            //check if contact is applicant
            boolean isApplicant =
                (studyLinkApplicationChecking(app) ||
                qtacApplicationChecking(app) ||
                samsApplicationChecking(app));

            //do not overwrite QUT Applicant value if it is already upated to true
            isApplicant = updateContactMap.containsKey(app.hed__Applicant__c)
            ? updateContactMap.get(app.hed__Applicant__c).QUT_Applicant__c
            : isApplicant;

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
    private static void updateContactOnProgramEnrollment(Set<Id> contactIds) {
        Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
        Set<Id> contactIdsToReEvaluateApplication = new Set<Id>();
        List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
            .getCourseConnectionByPEContactIds(contactIds, 'SYSTEM_MODE');

        String newJourneyStatus = '';

        for (hed__Course_Enrollment__c ce : courseConnectionList) {
            Id contactId = ce.hed__Program_Enrollment__r.hed__Contact__c;
            updateContactMap.put(contactId, new Contact(id = contactId, QUT_Student__c = true));
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
    }

    /**
     * @description: Checks existing affilition records linked to contact
     *
     * @param Set<Id> contactIds to evaluate
     * @return Map<Id,Contact> contact to be updated
     */
    private static void updateContactOnAffiliation(Set<Id> contactIds) {
        Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
        List<hed__Affiliation__c> affiliationList = AffiliationsDAO.newInstance()
            .getAffiliationByContactIds(contactIds, 'Current', 'SYSTEM_MODE');
        Map<Id, List<hed__Affiliation__c>> accountAffiliationMap = new Map<Id, List<hed__Affiliation__c>>();

        for (hed__Affiliation__c af : affiliationList) {
            if (accountAffiliationMap.containsKey(af.hed__Account__c)) {
                accountAffiliationMap.get(af.hed__Account__c).add(af);
            } else {
                List<hed__Affiliation__c> afList = new List<hed__Affiliation__c>();
                afList.add(af);
                accountAffiliationMap.put(af.hed__Account__c, afList);
            }
        }

        List<Opportunity> oppList = OpportunitiesDAO.newInstance()
            .getOpportunityByAccountIds(accountAffiliationMap.keySet(), 'SYSTEM_MODE');

        for (Opportunity opp : oppList) {
            if (accountAffiliationMap.containsKey(opp.AccountId)) {
                for (hed__Affiliation__c af : accountAffiliationMap.get(opp.AccountId)) {
                    updateContactMap.put(
                        af.hed__Contact__c,
                        new Contact(id = af.hed__Contact__c, QUT_Partner__c = true)
                    );
                }
            }
        }

        for (Id contactId : contactIds) {
            if (!updateContactMap.containsKey(contactId)) {
                updateContactMap.put(
                    contactId,
                    new Contact(id = contactId, QUT_Student__c = false)
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
    private static void updateContactOnContextualRole(Set<Id> contactIds) {
        Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
        Set<Id> contactIdsActiveRole = new Set<Id>();

        List<Contextual_Role__c> contextualRoleList = ContextualRolesDAO.newInstance()
            .getActiveContextualRoleByContactIds(contactIds, 'Opportunity_Role', 'SYSTEM_MODE');

        for (Contextual_Role__c cr : contextualRoleList) {
            if (cr.Account__r.RecordType.DeveloperName == AccountsDAO.ACCT_BUSINESS_ORG) {
                updateContactMap.put(
                    cr.Contact__c,
                    new Contact(id = cr.Contact__c, QUT_Partner__c = true)
                );
            } else {
                contactIdsActiveRole.add(cr.Contact__c);
            }
        }

        List<hed__Affiliation__c> affiliationList = AffiliationsDAO.newInstance()
            .getAffiliationByContactIds(contactIds, 'Current', 'SYSTEM_MODE');

        for (hed__Affiliation__c af : affiliationList) {
            updateContactMap.put(
                af.hed__Contact__c,
                new Contact(id = af.hed__Contact__c, QUT_Partner__c = true)
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
     * @description: Checks if the given application is a new StudyLink application based on specified conditions.
     *
     * @param hed__Application__c record to evaluate
     * @return boolean True or False
     */
    private static boolean studyLinkApplicationChecking(hed__Application__c app) {
        boolean isStudylinkRecType = app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
        return (isStudylinkRecType &&
        !ApplicationsDAO.studyLinkStatuses.contains(app.Application_Status__c));
    }

    /**
     * @description: Check if a QTAC Application exists for offer rounds in the future time period
     *
     * @param hed__Application__c record to evaluate
     * @return boolean True or False
     */
    private static boolean qtacApplicationChecking(hed__Application__c app) {
        boolean isQTACRecType = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
        return (isQTACRecType &&
        app.Applied_Intake_Study_Period__c != null &&
        app.Applied_Intake_Study_Period__r.hed__Start_Date__c > SYSTEM.today());
    }

    /**
     * @description: Check if a SAMS Application exists with statuses other than the excluded ones
     *
     * @param hed__Application__c record to evaluate
     * @return boolean True or False
     */
    private static boolean samsApplicationChecking(hed__Application__c app) {
        boolean isSAMSRecType = (app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID ||
        app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
        return (isSAMSRecType && !ApplicationsDAO.samsStatuses.contains(app.Application_Status__c));
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
            if (methodNames == 'updateContactOnProgramEnrollment') {
                updateContactOnProgramEnrollment(contactIds);
            }
            if (methodNames == 'updateContactOnApplication') {
                updateContactOnApplication(contactIds);
            }
            if (methodNames == 'updateContactOnAffiliation') {
                updateContactOnAffiliation(contactIds);
            }
            if (methodNames == 'updateContactOnContextualRole') {
                updateContactOnContextualRole(contactIds);
            }
        }
    }
}
