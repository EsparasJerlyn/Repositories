/**
 * @description Interface for Donation DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
      | nicole.genon                   | March 29, 2024        | DEPP-8167              | Created file                                    |
      | kenneth.f.alsay                | April 23, 2024        | DEPP-8528              | Added getDonationsBySetRecordIds                |
      | kenneth.f.alsay                | April 24, 2024        | DEPP-8528              | Added queryLocatorGetDonationsForStageUpdate    |
*/

public interface IDonationsDAO extends DmlInterface {
    Database.QueryLocator queryLocatorGetDonationsForStageUpdate();
    List<Donation__c> getDonationsByOpportunityIds(Set<Id> opportunityIds, AccessLevel accessLevel);
    List<Donation__c> getDonationsBySetRecordIds(Set<Id> recordIds, AccessLevel accessLevel);
    List<Donation__c> getDonationsBySetDonationParentIds(Set<Id> donationParentIds, AccessLevel accessLevel);
    List<Donation__c> getDonationsBySetRecordTypeIds(Set<Id> recordTypeIds, AccessLevel accessLevel);
}