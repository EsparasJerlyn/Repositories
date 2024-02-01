/** 
 * @description Controller Class for Contact
 * @see ../lwc/flowWorkEmailField
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | June 08, 2023         | DEPP-5414              | Created file                 | 
      | julie.jane.alegre              | Sept 21, 2023         | DEPP-6667              | Add methods to check related | 
      |                                |                       |                        | records to contact           | 
 */

public inherited sharing class ContactService {
    /**
     * @description Checks if the input work email in the flow exist across the organization.
     * @param emailInput -  the email that is needed to be check accross work email, email, qut staff, and qut learner
     * @return Boolean value indicating if Email lready exists (true) or not (false).
     */
    @AuraEnabled
    public static Boolean getExistingContactEmailDuplicatesForWorkEmailInputFlow(
        String emailInput
    ) {
        Boolean isEmailExist = false;

        try {
            List<Contact> isExistInContact = ContactsDAO.newInstance()
                .checkWorkEmailFlowInputExist(emailInput);
            isEmailExist = !isExistInContact.isEmpty();
        } catch (Exception e) {
            NebulaLoggerService.logExceptionDetails(
                'Exception caught in method getExistingContactEmailDuplicatesForWorkEmailInputFlow in class ContactCtrl.',
                e
            );
        }

        return isEmailExist;
    }
    /**
     * @description Check if contact to it's existing marketing interaction records
     * @param applicantIds
     */
    public static Map<Id, List<Marketing_Interaction__c>> mapExistingMarketingInteractionToContact(
        Set<Id> applicantIds,
        AccessLevel accessLevel
    ) {
        Map<Id, List<Marketing_Interaction__c>> marketingInteractionMap = new Map<Id, List<Marketing_Interaction__c>>();
        List<Marketing_Interaction__c> marketingInteractionList = MarketingInteractionsDAO.newInstance()
            .getMarketingInteractionByApplicantIds(applicantIds, accessLevel);
        for (Marketing_Interaction__c marketingInteractions : marketingInteractionList) {
            if (!marketingInteractionMap.containsKey(marketingInteractions.Contact__c)) {
                marketingInteractionMap.put(
                    marketingInteractions.Contact__c,
                    new List<Marketing_Interaction__c>()
                );
            }
            marketingInteractionMap.get(marketingInteractions.Contact__c)
                .add(marketingInteractions);
        }
        return marketingInteractionMap;
    }
    /**
     * @description Check map contact to it's existing case records
     * @param applicantIds
     */
    public static Map<Id, List<Case>> mapExistingCasesToContact(
        Set<Id> applicantIds,
        AccessLevel accessLevel
    ) {
        Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();
        List<Case> caseList = CasesDAO.newInstance()
            .getCasesByContactIds(applicantIds, accessLevel);
        for (Case cases : caseList) {
            if (!caseMap.containsKey(cases.ContactId)) {
                caseMap.put(cases.ContactId, new List<Case>());
            }
            caseMap.get(cases.ContactId).add(cases);
        }
        return caseMap;
    }
    /**
     * @description map  contact to it's application records
     * @param applicantIds
     */
    public static Map<Id, List<hed__Application__c>> mapExisitngApplicationsToContact(
        Set<Id> applicantIds,
        AccessLevel accessLevel
    ) {
        Map<Id, List<hed__Application__c>> applicationMap = new Map<Id, List<hed__Application__c>>();
        List<hed__Application__c> applicationList = ApplicationsDAO.newInstance()
            .getApplicationsByContactIds(applicantIds, 'SYSTEM_MODE');

        for (hed__Application__c applications : applicationList) {

            //do not include in active QTAC applications as existing active applications related to the contact
            if(applications.RecordTypeId == ApplicationsDAO.QTAC_RECTYPE_ID && applications.Is_Active__c == false){
                continue;
            }

            if (!applicationMap.containsKey(applications.hed__Applicant__c)) {
                applicationMap.put(applications.hed__Applicant__c, new List<hed__Application__c>());
            }
            applicationMap.get(applications.hed__Applicant__c).add(applications);
        }
        return applicationMap;
    }

    /**
     * @description checks if id is a contact id
     * @param Id
     * return boolean true if id is contact
     */
    public static Boolean isContact(Id id) {
        String idString = (String) id;
        return idString.startsWith(ContactsDAO.ID_PREFIX);
    }    
}
