/**
 * @description Interface for ContactAlternateIds DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 06, 2024        | DEPP-7986              | Created file
 */
public interface IContactAlternateIdsDAO extends DmlInterface {
     List<Contact_Alternate_ID__c> getContactAlternateIdsBySystemKeyIdSet(Set<String> systemKeyIdsSet, AccessLevel accessLevel);
     List<Contact_Alternate_ID__c> getContactAlternateIdsByContactIdSet(Set<Id> contactIdSet, AccessLevel accessLevel);
     List<Contact_Alternate_ID__c> getContactAlternateIdsByContactIdSetAndStatus(
        Set<Id> contactIdSet,
        Set<String> alternateIdStatusSet,
        AccessLevel accessLevel
    );
     List<Contact_Alternate_ID__c> getStudentAlternateIdsByStudentIds(Set<String> qutStudentIds, AccessLevel accessLevel);
}
