/**
 * @description Helper Class for ContactTriggerHandler,ContactPersonaFlagsService
 * @see ../classes/ContactTriggerHandler
 * @see ../classes/ContactPersonaFlagsService
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | roy.ninos.s.regala             | Aug 21, 2023          | DEPP-5704              | Created file                   |
 */
public with sharing class FutureStudentJourneyStatusHelper { 
    
    /**
     * sets the future journey status of the contact based on contact and application fields
     *
     * @param newItems   trigger.new contacts
     * @param oldMap   trigger.old contacts
     */
    public static void setFutureStudentJourneyStatus(
        List<Contact> newItems,
        Map<Id, Contact> oldMap
    ) {
        for (Contact record : newItems) {
            //in this scenario, the contact has an ongoing program
            if (record.QUT_Student__c) {
                record.Future_Student_Journey_Status__c = ContactsDAO.STUDY_JOURNEY_STATUS; //set journey status to study
            }else if(isSetJourneyStatusToExplore(record)){
                 //in this scenario, the contact is newly created or the status is cleared(withdrawn/passed a program)
                record.Future_Student_Journey_Status__c = ContactsDAO.EXPLORE_JOURNEY_STATUS; //set journey status to explore
            }else if(isSetJourneyStatusToBlank(record)){
                record.Future_Student_Journey_Status__c = '';
            }
        }
    }

    /**
     * evaluates the application and contact records to set a new journey status
     *
     * @param newContact   the latest data of the contact record to be checked
     * @param app   the application records to be checked
     * @param updateContactMap the contacts to be updated
     * @return - String value of the new journey status
     */
    public static String getNewJourneyStatus(
        Contact newContact,
        hed__Application__c app,
        Map<Id, Contact> updateContactMap
    ) {
        String newStatus = '';

        //do not evaluate applications if calculated intake date is not valid
        //and contact is in a program
        if (
            app.Calculated_Intake_Date__c == null ||
            app.Calculated_Intake_Date__c < System.Today() ||
            newContact.QUT_Student__c
        ) {
            return newStatus;
        }

        //
        if (isSetJourneyStatusToAcceptAdmit(app, updateContactMap)) {
            //evaluate application to set status to accept
            newStatus = ContactsDAO.ACCEPT_ADMIT_JOURNEY_STATUS;
        } else if (isSetJourneyStatusToOffer(app, updateContactMap)) {
            //evaluate application to set status to offer
            newStatus = ContactsDAO.OFFER_JOURNEY_STATUS;
        } else if (
            newContact.QUT_Applicant__c &&
            isSetJourneyStatusToApply(app, updateContactMap) //evaluate application to set status to apply
        ) {
            newStatus = ContactsDAO.APPLY_JOURNEY_STATUS;
        }

        return newStatus;
    }

    /**
     * evaluates the  contact record to check if journey status should be explore
     *
     * @param record   the contact record to be checked
     * @return - boolean result of the evaluation
     */
    private static boolean isSetJourneyStatusToExplore(Contact record) {
        //check if contact is candidate for explore
        //only perform when journey status is empty
        //we don't want to overwrite Offer and Accept-Admit Status
        //it has the same contact field conditions
        return record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
            record.QUT_Student__c == false &&
            record.QUT_Applicant__c == false &&
            record.QUT_Lead__c &&
            String.isBlank(record.Future_Student_Journey_Status__c);
    }

    /**
     * evaluates the  contact record to check if journey status should be empty from explore
     *
     * @param record   the contact record to be checked
     * @return - boolean result of the evaluation
     */
    private static boolean isSetJourneyStatusToBlank(Contact record) {
        //check if contact is candidate for blank
        return record.RecordTypeId == ContactsDAO.PERSON_RECORDTYPE_ID &&
            !record.QUT_Lead__c &&
            record.Future_Student_Journey_Status__c == ContactsDAO.EXPLORE_JOURNEY_STATUS;
    }

    /**
     * evaluates the application and contact records to check if journey status should be accept - admit
     *
     * @param app   the application records to be checked
     * @param updateContactMap the contacts to be updated
     * @return - boolean result of the evaluation
     */
    private static boolean isSetJourneyStatusToAcceptAdmit(
        hed__Application__c app,
        Map<Id, Contact> updateContactMap
    ) {
        //checks if the contact is already Accept Admit or  beyond Accept Admit Status
        Boolean isAlreadyAcceptAdmitStatus =
            updateContactMap.containsKey(app.hed__Applicant__c) &&
            ContactsDAO.CONTACT_HAS_ACCEPTED_STATUSES.contains(
                updateContactMap.get(app.hed__Applicant__c).Future_Student_Journey_Status__c
            );

        //skip this process
        if (isAlreadyAcceptAdmitStatus) {
            return false;
        }

        //evaluate application if its contact should have Accept - Admit Status
        return hasAcceptedOfferForStudyLink(app) ||
            hasAcceptedOfferForSAMS(app) ||
            hasAcceptedOfferForQTAC(app);
    }

    /**
     * evaluates the application and contact records to check if journey status should be offer
     *
     * @param app   the application records to be checked
     * @param updateContactMap the contacts to be updated
     * @return - boolean result of the evaluation
     */
    private static boolean isSetJourneyStatusToOffer(
        hed__Application__c app,
        Map<Id, Contact> updateContactMap
    ) {
        //checks if the contact is already Offer or beyond Offer Status
        Boolean isAlreadyOfferStatus =
            updateContactMap.containsKey(app.hed__Applicant__c) &&
            ContactsDAO.CONTACT_HAS_OFFERED_STATUSES.contains(
                updateContactMap.get(app.hed__Applicant__c).Future_Student_Journey_Status__c
            );

        //skip this process
        if (isAlreadyOfferStatus) {
            return false;
        }

        //evaluate application if its contact should have Offer Status
        return hasRecievedOrDeclinedOfferForStudyLink(app) ||
            hasRecievedOrDeclinedOfferForSAMS(app) ||
            hasRecievedOrDeclinedOfferForQTAC(app) ||
            ApplicationsDAO.OFFER_BY_OFFER_STATUSES.contains(app.Offer_Status__c);
    }

    /**
     * evaluates the application and contact records to check if journey status should be apply
     *
     * @param app   the application records to be checked
     * @param updateContactMap the contacts to be updated
     * @return - boolean result of the evaluation
     */
    private static boolean isSetJourneyStatusToApply(
        hed__Application__c app,
        Map<Id, Contact> updateContactMap
    ) {
        //checks if the contact is already Apply or beyond Apply Status
        Boolean isAlreadyApplyStatus =
            updateContactMap.containsKey(app.hed__Applicant__c) &&
            ContactsDAO.CONTACT_HAS_APPLIED_STATUSES.contains(
                updateContactMap.get(app.hed__Applicant__c).Future_Student_Journey_Status__c
            );

        //skip this process
        if (isAlreadyApplyStatus) {
            return false;
        }

        //evaluate application if its contact should have Apply Status
        return hasAppliedForStudyLink(app) || hasAppliedForSAMS(app) || hasAppliedForQTAC(app);
    }

    /**
     * evaluates the application to check if it is a study link application for Apply status
     *
     * @param app   the application records to be checked
     * @return - boolean result of the evaluation
     */
    private static boolean hasAppliedForStudyLink(hed__Application__c app) {
        boolean isStudylinkRecType = app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
        return (isStudylinkRecType &&
        !ApplicationsDAO.OFFER_BY_APPLICATION_STATUSES_FOR_STUDYLINK.contains(
            app.Application_Status__c
        ));
    }

    /**
     * evaluates the application to check if it is a sams application for Apply status
     *
     * @param app   the application records to be checked
     * @return - boolean result of the evaluation
     */
    private static boolean hasAppliedForSAMS(hed__Application__c app) {
        boolean isSAMSRecType = (app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID ||
        app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
        return (isSAMSRecType &&
        !ApplicationsDAO.OFFER_BY_APPLICATION_STATUSES_FOR_SAMS.contains(
            app.Application_Status__c
        ) &&
        !ApplicationsDAO.OFFER_BY_OFFER_STATUSES_FOR_SAMS.contains(app.Offer_Status__c));
    }

    /**
     * evaluates the application to check if it is a qtac application for Apply status
     *
     * @param app   the application records to be checked
     * @return - boolean result of the evaluation
     */
    private static boolean hasAppliedForQTAC(hed__Application__c app) {
        boolean isQTACRecType = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
        return (isQTACRecType &&
        String.isBlank(app.Offer_Status__c) &&
        app.Offer_Status_Date__c == null);
    }

    /**
     * evaluates the application to check if it is a study link application for Offer status
     *
     * @param app   the application records to be checked
     * @return - boolean result of the evaluation
     */
    private static boolean hasRecievedOrDeclinedOfferForStudyLink(hed__Application__c app) {
        boolean isStudylinkRecType = app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
        return (isStudylinkRecType &&
        (ApplicationsDAO.OFFER_BY_APPLICATION_STATUSES_FOR_STUDYLINK.contains(
            app.Application_Status__c
        ) ||
        ApplicationsDAO.DECLINED_OFFER_BY_APPLICATION_STATUSES_FOR_STUDYLINK.contains(
            app.Application_Status__c
        )));
    }

    /**
     * evaluates the application to check if it is a sams application for Offer status
     *
     * @param app   the application records to be checked
     * @return - boolean result of the evaluation
     */
    private static boolean hasRecievedOrDeclinedOfferForSAMS(hed__Application__c app) {
        boolean isSAMSRecType = (app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID ||
        app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
        return (isSAMSRecType &&
        ((ApplicationsDAO.OFFER_BY_APPLICATION_STATUSES_FOR_SAMS.contains(
            app.Application_Status__c
        ) && ApplicationsDAO.OFFER_BY_OFFER_STATUSES_FOR_SAMS.contains(app.Offer_Status__c)) ||
        ApplicationsDAO.DECLINED_OFFER_BY_OFFER_STATUSES_FOR_SAMS.contains(app.Offer_Status__c)));
    }

    /**
     * evaluates the application to check if it is a qtac application for Offer status
     *
     * @param app   the application records to be checked
     * @return - boolean result of the evaluation
     */
    private static boolean hasRecievedOrDeclinedOfferForQTAC(hed__Application__c app) {
        boolean isQTACRecType = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
        return (isQTACRecType &&
        (app.Offer_Status_Date__c != null ||
        ApplicationsDAO.DECLINED_OFFER_BY_OFFER_STATUSES_FOR_QTAC.contains(app.Offer_Status__c)));
    }

    /**
     * evaluates the application to check if it is a study link application for Accept - Admit status
     *
     * @param app   the application records to be checked
     * @return - boolean result of the evaluation
     */
    private static boolean hasAcceptedOfferForStudyLink(hed__Application__c app) {
        boolean isStudylinkRecType = app.RecordTypeId == ApplicationsDAO.STUDYLINK_RECTYPE_ID;
        return (isStudylinkRecType &&
        ApplicationsDAO.ACCEPTED_OFFER_BY_APPLICATION_STATUSES_FOR_STUDYLINK.contains(
            app.Application_Status__c
        ));
    }

    /**
     * evaluates the application to check if it is a sams application for Accept - Admit status
     *
     * @param app   the application records to be checked
     * @return - boolean result of the evaluation
     */
    private static boolean hasAcceptedOfferForSAMS(hed__Application__c app) {
        boolean isSAMSRecType = (app.RecordTypeId == ApplicationsDAO.SAMS_LEGACY_RECTYPE_ID ||
        app.RecordTypeId == ApplicationsDAO.SAMS_CIANYWHERE_RECTYPE_ID);
        return (isSAMSRecType &&
        ApplicationsDAO.OFFER_BY_APPLICATION_STATUSES_FOR_SAMS.contains(
            app.Application_Status__c
        ) &&
        ApplicationsDAO.ACCEPTED_OFFER_BY_OFFER_STATUSES_FOR_SAMS.contains(app.Offer_Status__c));
    }

    /**
     * evaluates the application to check if it is a qtac application for Accept - Admit status
     *
     * @param app   the application records to be checked
     * @return - boolean result of the evaluation
     */
    private static boolean hasAcceptedOfferForQTAC(hed__Application__c app) {
        boolean isQTACRecType = app.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID;
        return (isQTACRecType &&
        (ApplicationsDAO.ACCEPTED_OFFER_BY_OFFER_STATUSES_FOR_QTAC.contains(app.Offer_Status__c)));
    }
}
