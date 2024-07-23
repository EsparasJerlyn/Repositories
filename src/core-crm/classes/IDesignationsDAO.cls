/**
 * @description Interface for Donation Cause DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | March 14, 2024        | DEPP-8210              | Created file                                   |
      | kenneth.f.alsay                | April 05, 2024        | DEPP-8399              | Added getDesignationsByNameStart               |
*/

public interface IDesignationsDAO extends DmlInterface {
    Database.QueryLocator queryLocatorGetDesignationsForStageUpdate();
    List<Designation__c> getDesignationsBySetRecordIds(Set<Id> recordIds, AccessLevel accessLevel);
    List<Designation__c> getDesignationsByNameStart(String nameStart, AccessLevel accessLevel);
    
}