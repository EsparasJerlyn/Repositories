/**
 * @description course connection trigger helper class
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | created file                               |
 */
public without sharing class CourseConPricingValidationHelper {
    // set to without sharing because we could not set sharing access for Cart and Cartitems

    /**
     * @description: process the enrolment pricing validation
     *
     * @param List<hed__Course_Enrollment__c> newItems
     * @param Map<Id, hed__Course_Enrollment__c> oldItems
     */
    public static void processEnrolmentPricingValidation(
        List<hed__Course_Enrollment__c> newItems,
        Map<Id, hed__Course_Enrollment__c> oldItems
    ) {
        //cart item ids of the course enrollment for processing
        Set<String> cartItemIds = new Set<String>();
        //contact ids of the course enrollment for processing
        Set<String> contactIds = new Set<String>();
        //map where key is cart item id and value is the pricebookname
        Map<String, String> cartItemToPricingNameMap = new Map<String, String>();
        //map to store the related contact of the course enrolment
        Map<String, Contact> contactMap = new Map<String, Contact>();
        //map of contacts with other active enrolments
        Map<String, List<hed__Course_Enrollment__c>> contactToEnrolmentsMap = new Map<String, List<hed__Course_Enrollment__c>>();
        //map of contacts to be updated
        Map<String, Contact> contactToUpdateMap = new Map<String, Contact>();

        //contains the filtered course enrolment to be used in this method
        List<hed__Course_Enrollment__c> courseEnrollmentToProcess = new List<hed__Course_Enrollment__c>();

        for (hed__Course_Enrollment__c record : newItems) {
            //collect records to process

            //check if course enrolment is for pricing validation
            boolean isForPricingValidation = checkIfForPricingValidation(record, oldItems);

            //only when cart item and contact is populated on New
            //or cart item is updated or status is updated to not active
            //collect cart item, contact, and course enrollment records
            if (isForPricingValidation) {
                cartItemIds.add(record.Cart_Item__c);
                contactIds.add(record.hed__Contact__c);
                courseEnrollmentToProcess.add(record);
            }
        }

        //get course connection related records for processing
        getPricingNameMap(cartItemIds, cartItemToPricingNameMap);
        getContactMap(contactIds, contactMap, cartItemToPricingNameMap.keySet());
        getOtherEnrolmentsMap(contactIds, contactToEnrolmentsMap);

        //loop through the filtered course enrolments
        for (hed__Course_Enrollment__c record : courseEnrollmentToProcess) {
            //if pricing name is not found or there are no related contact
            // skip this course enrolment
            boolean isSkipCourseEnrolment =
                !cartItemToPricingNameMap.containsKey(record.Cart_Item__c) ||
                !contactMap.containsKey(record.hed__Contact__c);

            if (isSkipCourseEnrolment) {
                continue;
            }

            //get the selected pricing value e.g Alumni, Current Learner, Current Staff
            String selectedPricing = cartItemToPricingNameMap.get(record.Cart_Item__c);

            //the current contact related to the enrolment
            Contact currentContact = contactMap.get(record.hed__Contact__c);

            //set the pricing valudation this course enrolment to Unsuccessful or Successful
            record.Pricing_Validation__c = getPricingValidationResult(
                currentContact,
                selectedPricing
            );

            //update contact's validation field as per condition below
            //only do an update when value is changed

            boolean isUpdateCurrentLearnerVerification =
                selectedPricing == 'Current Learner' &&
                verifyLearnerContact(record, contactToEnrolmentsMap, currentContact) !=
                currentContact.Current_Learner_Verified__c;

            boolean isUpdateAlumniVerification =
                selectedPricing == 'Alumni' &&
                verifyAlumniContact(record, currentContact) != currentContact.Alumni_Verified__c;

            if (isUpdateCurrentLearnerVerification) {
                currentContact.Current_Learner_Verified__c = !currentContact.Current_Learner_Verified__c;
                contactToUpdateMap.put(currentContact.Id, currentContact);
            } else if (isUpdateAlumniVerification) {
                currentContact.Alumni_Verified__c = !currentContact.Alumni_Verified__c;
                contactToUpdateMap.put(currentContact.Id, currentContact);
            }
        }

        //finally update the contact records
        if (!contactToUpdateMap.keySet().isEmpty()) {
            ContactsDAO.newInstance()
                .updateRecords(contactToUpdateMap.values(), false, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * @description: checks if course enrolment is for pricing validation
     * @param hed__Course_Enrollment__c newRecord
     * @param Map<Id, hed__Course_Enrollment__c> oldRecord
     */
    private static boolean checkIfForPricingValidation(
        hed__Course_Enrollment__c newRecord,
        Map<Id, hed__Course_Enrollment__c> oldRecord
    ) {
        //check if insert or cart item is updated
        boolean isCartItemNew =
            oldRecord == null ||
            newRecord.Cart_Item__c != oldRecord.get(newRecord.Id).Cart_Item__c;

        //check if insert or status is updated
        boolean isStatusNew =
            oldRecord == null ||
            newRecord.hed__Status__c != oldRecord.get(newRecord.Id).hed__Status__c;

        //check if status is update to not active
        boolean isStatusNotActive = newRecord.hed__Status__c != 'Active';

        boolean hasContactAndCartItem =
            newRecord.hed__Contact__c != null &&
            newRecord.Cart_Item__c != null;

        return hasContactAndCartItem && (isCartItemNew || (isStatusNew && isStatusNotActive));
    }

    /**
     * @description: sets the pricing validation result
     *               it is expected that selected pricing is either of below
     *               Current Learner, Alumni, and Current Staff
     * @param Contact record
     * @param String selectedPricing
     * @return String Successful/Unsuccessful
     */
    private static String getPricingValidationResult(
        Contact contactRecord,
        String selectedPricing
    ) {
        if (contactRecord.Current_Learner_Verified__c && selectedPricing == 'Current Learner') {
            return 'Successful';
        } else if (contactRecord.Alumni_Verified__c && selectedPricing == 'Alumni') {
            return 'Successful';
        } else if (
            contactRecord.Staff_Verified__c &&
            contactRecord.IsStaff_Active__c &&
            selectedPricing == 'Current Staff'
        ) {
            return 'Successful';
        }
        return 'Unsuccessful';
    }

    /**
     * @description: verify if contact is learner
     * @param hed__Course_Enrollment__c enrolmentRecord
     * @param Map<String, List<hed__Course_Enrollment__c>> contactToEnrolmentsMap
     * @param Contact contactRecord
     */
    private static boolean verifyLearnerContact(
        hed__Course_Enrollment__c enrolmentRecord,
        Map<String, List<hed__Course_Enrollment__c>> contactToEnrolmentsMap,
        Contact contactRecord
    ) {
        //if status iupdated to not Active
        //and no other active enrolment is linked to the contact
        boolean isNoOtherEnrolment = !contactToEnrolmentsMap.containsKey(contactRecord.Id);
        boolean isCurrentRecordOnlyEnrolment =
            contactToEnrolmentsMap.containsKey(contactRecord.Id) &&
            contactToEnrolmentsMap.get(contactRecord.Id).size() == 1 &&
            contactToEnrolmentsMap.get(contactRecord.Id)[0].Id == enrolmentRecord.Id;

        if (
            enrolmentRecord.hed__Status__c != 'Active' &&
            (isNoOtherEnrolment || isCurrentRecordOnlyEnrolment)
        ) {
            return false;
        } else if (!contactRecord.Current_Learner_Verified__c) {
            return true;
        }
        return contactRecord.Current_Learner_Verified__c;
    }

    /**
     * @description: verify if contact is alumni
     * @param hed__Course_Enrollment__c enrolmentRecord
     * @param Contact contactRecord
     */
    private static boolean verifyAlumniContact(
        hed__Course_Enrollment__c enrolmentRecord,
        Contact contactRecord
    ) {
        //if status is set to completed
        if (enrolmentRecord.hed__Status__c == 'Completed') {
            return true;
        }

        return contactRecord.Alumni_Verified__c;
    }

    /**
     * @description: get pricing map
     *               where key is the cart item id
     *               and the value is the pricebookname
     * @param Set<String> cartItemIds
     * @param Map<String, String> cartItemToPricingNameMap
     */
    private static void getPricingNameMap(
        Set<String> cartItemIds,
        Map<String, String> cartItemToPricingNameMap
    ) {
        Map<String, String> cartItemToPricebookEntryMap = new Map<String, String>();
        Map<String, String> pricebookEntryToPricebookNameMap = new Map<String, String>();

        //make sure cartitemsids is not empty before running the soql
        //create a map where key is cart item id and value is the pricebookentry id
        if (!cartItemIds.isEmpty()) {
            for (
                CartItem record : CartItemsDAO.newInstance()
                    .getCartItemsWithPricebookEntryByRecordIds(cartItemIds, AccessLevel.SYSTEM_MODE)
            ) {
                cartItemToPricebookEntryMap.put(record.Id, record.Pricebook_Entry_ID__c);
            }
        }

        //make sure cartItemToPricebookEntryMap is not empty before running the soql
        //create a map where key is pricebook entry id and value is the pricebook name
        if (!cartItemToPricebookEntryMap.keySet().isEmpty()) {
            for (
                PricebookEntry record : PricebookEntriesDAO.newInstance()
                    .getPricebookEntriesByRecordIdsAndPricebookNames(
                        new Set<String>(cartItemToPricebookEntryMap.values()),
                        PricebooksDAO.PRICING_VALIDATION_NAMES,
                        AccessLevel.USER_MODE
                    )
            ) {
                pricebookEntryToPricebookNameMap.put(record.Id, record.Pricebook2.Name);
            }
        }

        //loop through the cartitems and map the pricebook entry to the pricebook name
        for (String cartItemId : cartItemToPricebookEntryMap.keySet()) {
            if (
                pricebookEntryToPricebookNameMap.containsKey(
                    cartItemToPricebookEntryMap.get(cartItemId)
                )
            ) {
                cartItemToPricingNameMap.put(
                    cartItemId,
                    pricebookEntryToPricebookNameMap.get(
                        cartItemToPricebookEntryMap.get(cartItemId)
                    )
                );
            }
        }
    }

    /**
     * @description: gets the contact records related to course enrolment
     * @param Set<String> contactIds
     * @param Map<String, Contact> contactsMap
     * @param Set<String> cartIdsWithPricing
     */
    private static void getContactMap(
        Set<String> contactIds,
        Map<String, Contact> contactsMap,
        Set<String> cartIdsWithPricing
    ) {
        boolean hasNoContactOrPricing = !contactIds.isEmpty() || !cartIdsWithPricing.isEmpty();

        if (hasNoContactOrPricing) {
            contactsMap.putAll(
                new Map<String, Contact>(
                    ContactsDAO.newInstance()
                        .getPersonContactsBySetIds(
                            new Set<Id>((List<Id>) new List<String>(contactIds)),
                            AccessLevel.SYSTEM_MODE
                        )
                )
            );
        }
    }

    /**
     * @description: gets the other active enrolment records related to contact
     * @param Set<String> contactIds
     * @param Map<String, Contact> contactsMap
     * @param Set<String> cartIdsWithPricing
     */
    private static void getOtherEnrolmentsMap(
        Set<String> contactIds,
        Map<String, List<hed__Course_Enrollment__c>> contactToEnrolmentsMap
    ) {
        if (!contactIds.isEmpty()) {
            for (
                hed__Course_Enrollment__c record : CourseConnectionsDAO.newInstance()
                    .getActiveCourseConnectionsBySetContactIds(contactIds, AccessLevel.SYSTEM_MODE)
            ) {
                if (!contactToEnrolmentsMap.containsKey(record.hed__Contact__c)) {
                    contactToEnrolmentsMap.put(
                        record.hed__Contact__c,
                        new List<hed__Course_Enrollment__c>()
                    );
                }
                contactToEnrolmentsMap.get(record.hed__Contact__c).add(record);
            }
        }
    }
}
