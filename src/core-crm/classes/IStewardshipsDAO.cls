/**
 * @description Interface for Stewardship DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | nicole.genon                   | March 6, 2024         | DEPP-7922              | Created file
 */
public interface IStewardshipsDAO  extends DmlInterface {
    List<Stewardship__c> getStewardshipByRecordTypeIds(Set<Id> recordTypeIds, AccessLevel accessLevel);
    List<Stewardship__c> getStewardshipBySetIds(Set<Id> stewardshipIds, AccessLevel accessLevel);
}