/** 
 * @description Controller Class for Contact
 * @see ../lwc/flowWorkEmailField
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                   |
      |--------------------------------|-----------------------|------------------------|----------------------------------|
      | eugene.andrew.abuan            | June 08, 2023         | DEPP-5414              | Created file                     | 
      | julie.jane.alegre              | Sept 21, 2023         | DEPP-6667              | Add methods to check related     | 
      |                                |                       |                        | records to contact               | 
      | sebastianne.k.trias            | June 1, 2024          | DEPP-8474              | Removed Modify Opt in/out fields |
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
     * @description checks if id is a contact id
     * @param Id
     * return boolean true if id is contact
     */
    public static Boolean isContact(Id id) {
        String idString = (String) id;
        return idString.startsWith(ContactsDAO.ID_PREFIX);
    }    
}