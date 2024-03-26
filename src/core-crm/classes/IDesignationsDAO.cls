/**
 * @description Interface for Donation Cause DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | March 14, 2024        | DEPP-8210              | Created file                                   |
*/

 public interface IDesignationsDAO extends DmlInterface {
      Database.QueryLocator queryLocatorGetDesignationsForStageUpdate();
      List<Designation__c> getDesignationsBySetRecordIds(Set<Id> recordIds, AccessLevel accessLevel);
 }