/**
 * @description Interface for Donation DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
      | nicole.genon                   | March 29, 2024        | DEPP-8167              | Created file                                    |
      |  kim.howard.capanas            | April 18, 2024        | DEPP-8499              | added getDonationAssetsByDonationId method      |
*/

public interface IDonationsDAO extends DmlInterface {
    List<Donation__c> getDonationsByOpportunityIds(Set<Id> opportunityIds, AccessLevel accessLevel);
    List<Donation__c> getDonationAssetsByDonationId(Set<Id> donationIds, AccessLevel accessLevel);
}