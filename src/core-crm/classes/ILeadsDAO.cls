/**
 * @description Interface for Lead DAO 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                                     |
      | mark.j.mahilum                 | June 26, 2023         | DEPP-5846              | Added new list                                   |
      | roy.nino.s.regala              | July 20, 2023         | DEPP-5677              | Added new list                                   |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added new list                                   |
      | arsenio.jr.dayrit              | Sept 22,2023          | DEPP-6720              | added new list getLeadsByCaseMobile              |
      | neil.s.h.lesidan               | September 20, 2023    | DEPP-6478              | Added getLeadById                                |
      | neil.s.h.lesidan               | September 20, 2023    | DEPP-6478              | Added getLeadByEmailOrName                       |
      | alexander.cadalin              | November 9, 2023      | DEPP-7212              | Added excludeConverted to getLeadByEmailOrName   |
 */
public interface ILeadsDAO extends DmlInterface {
    List<Lead> getExistingUnconvertedLeadsByEmail(
        Set<String> emailsToMatch,
        Set<Id> excludedLeadsRecordsSet,
        String accessLevel
    ); 
    List<Lead> getLeadsWithLimit(Integer recordsCount);
    List<Lead> getExistingUnconvertedLeads(
        Set<String> emailsToMatch,
        String accessLevel
    );
    List<Lead> getLearnerLeadsByCalculatedCadences(
        Set<String> calculatedCadences
    );
    List<Lead> getLeadsCalculatedCadenceByIds(
        Set<String> recordIds,
        String accessLevel
    );
    List<Lead> getLeadByEmailOrName(
        LeadsDAO.QueryParamWrapperEmailOrName queryParam,
        Boolean excludeConverted,
        AccessLevel accessLevel
    );
    List<Lead> getLeadsByCaseMobile(
        Set<String> caseMobile,
        AccessLevel accessLevel
    ); 
    List<Lead> getLeadsByIdSet(
        Set<Id> recordIdSet,
        AccessLevel accessLevel
    );
    List<Lead> getLeadsByIdSetAndType(
        Set<Id> recordIdSet,
        String leadType,
        AccessLevel accessLevel
    );
    List<Lead> getLeadMobilePhoneByRecordIds(
        Set<Id> recordIdSet,
        AccessLevel accessLevel
    ); 
    Database.QueryLocator queryLocatorGetLeadsByIds(
        Set<Id> recordIds,
        String leadType
    );
    List<Lead> getLearnerLeadsByEmailOrWorkEmail(
        Set<String> emails,
        AccessLevel accessLevel
    );
    List<Lead> getLearnerLeadsByEmailOrWorkEmail(
        Set<String> emails,
        Set<String> workEmails,
        AccessLevel accessLevel
    );
    List<Lead> getUnconvertedLeadsByIdSet(
        Set<Id> recordIdSet,
        AccessLevel accessLevel
    );
} 