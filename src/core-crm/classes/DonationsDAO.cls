/**
 * @description DAO Class for Donation Object.
 * @author Accenture
 *
 * @history
 *
 *    |  Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |---------------------------------|-----------------------|------------------------|------------------------------------------------|
      |  nicole.genon                   | March 29, 2024        | DEPP-8167              | Created file                                   |
      |  kim.howard.capanas             | April 18, 2024        | DEPP-8499              | added getDonationAssetsByDonationId method     |
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

    public List<Donation__c> getDonationAssetsByDonationId(
        Set<Id> donationIds,
        AccessLevel accessLevel
    ){
        if(donationIds.isEmpty()){
            return new List<Donation__c>();
        }
        return Database.query(
            'SELECT Id, Donation_Asset__c ' +
            'FROM Donation__c ' +
            'WHERE Id IN :donationIds ',
            accessLevel
        );
    }    

}
