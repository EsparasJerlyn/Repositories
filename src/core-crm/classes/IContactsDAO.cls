/**
 * @description Interface for Contact DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                         |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------|
 *    | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                           |
 *    | eugene.andrew.abuan            | June 08, 2023         | DEPP-5414              | Added checkWorkEmailFlowInputExist     |
 *    | mark.j.mahilum                 | June 26, 2023         | DEPP-5846              | Added new list for 5846 Methods        |
 *    | roy.nino.s.regala              | July 20, 2023         | DEPP-5677              | Added new list                         |
 *    | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added new list                         |
 *    | julie.jane.alegre              | Sept 05, 2023         | DEPP-5965              | Added getContactsFromConvertedLead     |
 *    | roy.nino.s.regala              | Sept 20, 2023         | DEPP-6714              | method getPersonContactsBySetIds       |
 *    | alexander.cadalin              | Sep 22, 2023          | DEPP-6652              | method getContactsForQTACAddressUpdate |
 *    | neil.s.h.lesidan               | Sep 20, 2023          | DEPP-6478              | Added getPersonContactsByEmailOrName   |
 *    | arsenio.jr.dayrit              | Sept 22,2023          | DEPP-6720              | added getContactByCaseMobile           |
 *    | julie.jane.alegre              | Nov 07, 2023          | DEPP-7152              | Added method getExistingMCPersonaContactsBySetIds|
 *    | sebastianne.k.trias            | Feb 19, 2024          | DEPP-7750              | added getPersonContactsByNameUsingSOSL |
 *    | julie.jane.alegre              | May 13, 2024          | DEPP-8490              | Update method getQueryLocatorBySubQueryTest|
 *    | eugene.andrew.abuan            | May 14, 2024          | DEPP-8485              | Added getContactsByStudentId           |
 *    | eccarius.munoz                 | August 12, 2024       | DEPP-10490             | Added queryLocatorGetMDMStudentsByIds  |
 */
public interface IContactsDAO extends DmlInterface {
    List<Contact> getExistingPersonContactsWithMatchingEmails(
        Set<String> allEmailsToMatch,
        Set<Id> newContactIds,
        String accessLevel
    );
    List<Contact> getPersonContactsWithLimit(Integer recordsCount);
    List<Contact> checkWorkEmailFlowInputExist(String emailInput);   
    List<Contact> getContactsWithMatchingApplicationDetails(
        ContactsDAO.QueryParamWrapper queryParam,
        String accessLevel
    );
    List<Contact> getContactsWithMatchingEmails(
        Set<String> applicationEmailsToMatch,
        String accessLevel
    );
    List<Contact> getContactsWithMatchingSamsApplications(
        ContactsDAO.QueryParamWrapper queryParam,
        String accessLevel
    );  

    List<Contact> getContactsByMatchingAttributes(
        Map<String,Set<String>> fieldSetMap,
        Set<Date> birthDateSet,
        AccessLevel accessLevel
    );

    List<Contact> getPersonContactsByCalculatedCadences(
        Set<String> calculatedCadences
    );
    List<Contact> getContactCalculatedCadenceByIds(
        Set<String> recordIds,
        String accessLevel
    );
    List<Contact> getContactsFromConvertedLead(
        Set<Id> recordIds,
        String accessLevel
    );
    List<Contact> getPersonContactsByEmailOrName(
        ContactsDAO.QueryParamWrapperEmailOrName queryParam,
        AccessLevel accessLevel
    ); 
    List<Contact> getPersonContactsBySetIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    );
    List<Contact> getContactByCaseMobile(
        Set<String> caseMobile,
        AccessLevel accessLevel
    );

    List<Contact> getContactsForQTACAddressUpdate(
        Set<Id> qtacApplicantIdSet,
        AccessLevel accessLevel
    );
    List<Contact> getContactMobilePhoneByRecordIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ); 
    
    Database.QueryLocator queryLocatorGetContactsByIds(
        Set<Id> recordIds
    );
     
    List<Contact> getExistingMCPersonaContactsBySetIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ); 

    List<Contact> getContactsByParentPersonLeadIds(
        Set<Id> leadIds,
        AccessLevel accessLevel
    );

    List<Contact> getContactsNoParentPersonContactByIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    );

    List<Contact> getMCPersonaContactsByParentPersonContactIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    );

    List<Contact> getContactsWithParentPersonContactByIds(
        Set<Id> recordsIds,
        AccessLevel accessLevel
    );

    List<Contact> getMCPersonaContactsByParentPersonLeadIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    );

    List<Contact> getPersonContactsByNameUsingSOSL(
        String filterName
    );

    String getWhereClauseByCriteria(
        ContactsDAO.Criteria contactCriteria
    );

    Database.QueryLocator getQueryLocatorByCriteria(
        ContactsDAO.Criteria criteria
    ); 

    Database.QueryLocator getQueryLocatorBySubQuery(
        String subQueryString
    );

    List<Contact> findByCriteria(
        ContactsDAO.Criteria Criteria, 
        AccessLevel accessLevel
    );

    List<Contact> getContactByStudentId (        
        List<String> studentIdList,
        AccessLevel accessLevel
    );

    Database.QueryLocator getQueryLocatorContactByStudentId(
        List<String> studentIdList,
        AccessLevel accessLevel
    );

    Database.QueryLocator queryLocatorGetMDMStudentsByIds(
        Set<Id> studentIds,
        AccessLevel accessLevel
    );
}