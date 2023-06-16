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
 */

public with sharing class ContactService {

    /**
     * @description Checks if the input work email in the flow exist across the organization.
     * @param emailInput -  the email that is needed to be check accross work email, email, qut staff, and qut learner 
     * @return Boolean value indicating if Email lready exists (true) or not (false).
     */
    @AuraEnabled
    public static Boolean getExistingContactEmailDuplicatesForWorkEmailInputFlow(String emailInput) {
        Boolean isEmailExist = false;

        try{
            List<Contact> isExistInContact = ContactsDAO.newInstance().checkWorkEmailFlowInputExist(emailInput);
            isEmailExist = !isExistInContact.isEmpty();
        }catch(Exception e){
            NebulaLoggerService.logExceptionDetails(
                'Exception caught in method getExistingContactEmailDuplicatesForWorkEmailInputFlow in class ContactCtrl.', e);
        }

        return isEmailExist;
    }
}