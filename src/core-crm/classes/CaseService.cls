/**
 * @description Service Class for CaseService class getting case related record
 * 
 * @see CaseService
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------|
 *    | arsenio.jr.dayrit              | September 27,2023     | DEPP-6720	            | Created File                  | 
 */
public with sharing class CaseService {

    /**
     * @description Check map contact to it's existing case records
     * @param caseSuppliedPhone
     */
    public static Map<String, List<Contact>> mapExistingContactMatchToCase(Set<String> caseSuppliedPhone) {
        Map<String,List<Contact>> contactsMatchFromCaseMobileMap = new Map<String, List<Contact>>();
        List<Contact> contactList = ContactsDAO.newInstance().getContactByCaseMobile(caseSuppliedPhone, AccessLevel.SYSTEM_MODE);
        for(Contact contact: contactList){
            if(!contactsMatchFromCaseMobileMap.containsKey(contact.MobilePhone) && contact.MobilePhone != null){
                contactsMatchFromCaseMobileMap.put(contact.MobilePhone, new List<Contact>());
            }
            contactsMatchFromCaseMobileMap.get(contact.MobilePhone).add(contact);
        }
        return contactsMatchFromCaseMobileMap;
    }

    /**
     * @description Check map lead to it's existing case records
     * @param caseSuppliedPhone
     */
    public static Map<String, List<Lead>> mapExistingLeadMatchToCase(Set<String> caseSuppliedPhone) {
        Map<String,List<Lead>> leadMatchFromCaseMobileMap = new Map<String, List<Lead>>();
        List<Lead> leadList = leadsDAO.newInstance().getLeadsByCaseMobile(caseSuppliedPhone, AccessLevel.USER_MODE);
        for(Lead lead : leadList){
            if(!leadMatchFromCaseMobileMap.containsKey(lead.MobilePhone) && lead.MobilePhone != null){
                leadMatchFromCaseMobileMap.put(lead.MobilePhone, new List<Lead>());
            }
            leadMatchFromCaseMobileMap.get(lead.MobilePhone).add(lead);
        }
        return leadMatchFromCaseMobileMap;
    }
}