/**
 * @description DAO Class for Donation Object.
 * @author Accenture
 *
 * @history
 *
 *    |  Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |---------------------------------|-----------------------|------------------------|------------------------------------------------|
      |  nicole.genon                   | March 29, 2024        | DEPP-8167              | Created file                                   |
*/
public inherited sharing class DonationsDAO extends DmlBase implements IDonationsDAO {

    public Schema.SObjectType getSObjectType() {
        return Donation__c.SObjectType;
    }

    public static IDonationsDAO newInstance() {
        return (IDonationsDAO) ImplementationSelector.DAO.newInstance(
            Donation__c.SObjectType
        );
    }

    public static List<Donation__c> getDonationsByOpportunityIds(
        Set<Id> opportunityIds,
        AccessLevel accessLevel
    ) {
        if (!opportunityIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Stage__c, Opportunity__c ' + 
                'FROM Donation__c WHERE Opportunity__c IN :opportunityIds',
                accessLevel
            );
        } else {
            return new List<Donation__c>();
        }
    }

}
