/**
 * @description Interface for Donation DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
      | nicole.genon                   | March 29, 2024        | DEPP-8167              | Created file                                    |
*/

public interface IDonationsDAO extends DmlInterface {
    List<Donation__c> getDonationsByOpportunityIds(Set<Id> opportunityIds, AccessLevel accessLevel);
}