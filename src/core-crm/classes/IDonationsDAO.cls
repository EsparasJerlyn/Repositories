/**
 * @description Interface for Donation DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
      | nicole.genon                   | March 29, 2024        | DEPP-8167              | Created file                                    |
      | kim.howard.capanas             | April 18, 2024        | DEPP-8499              | Added getDonationAssetsByDonationId method      |
      | kenneth.f.alsay                | April 23, 2024        | DEPP-8528              | Added getDonationsBySetRecordIds                |
      | kenneth.f.alsay                | April 24, 2024        | DEPP-8528              | Added queryLocatorGetDonationsForStageUpdate    |
      | neil.s.h.lesidan               | April 30, 2024        | DEPP-8610              | Add method getDonationsByParentIdRecordType     |
      |                                |                       | DEPP-8570              |                                                 |
      |                                |                       | DEPP-8682              |                                                 |
*/
public interface IDonationsDAO extends DmlInterface {
    Database.QueryLocator queryLocatorGetDonationsForStageUpdate();
    List<Donation__c> getDonationsByOpportunityIds(Set<Id> opportunityIds, AccessLevel accessLevel);
    List<Donation__c> getDonationAssetsByDonationId(Set<Id> donationIds, AccessLevel accessLevel);
    List<Donation__c> getDonationsBySetRecordIds(Set<Id> recordIds, AccessLevel accessLevel);
    List<Donation__c> getDonationsByParentIdRecordType(
        Set<Id> parentDonations,
        Id recordTypeId,
        AccessLevel accessLevel
    );
    List<Donation__c> getDonationsBySetDonationParentIds(Set<Id> donationParentIds, AccessLevel accessLevel);
    List<Donation__c> getDonationsBySetRecordTypeIds(Set<Id> recordTypeIds, AccessLevel accessLevel);
}