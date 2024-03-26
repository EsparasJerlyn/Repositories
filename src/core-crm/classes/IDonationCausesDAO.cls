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

 public interface IDonationCausesDAO extends DmlInterface {
      Database.QueryLocator queryLocatorGetDonatioCausesForStageUpdate();
      List<Donation_Cause__c> getDonationCausesBySetRecordIds(Set<Id> recordIds, AccessLevel accessLevel);
 }