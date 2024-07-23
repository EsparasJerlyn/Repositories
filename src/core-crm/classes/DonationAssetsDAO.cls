/**
 * @description DAO Class for Donation Asset Object.
 * @author Accenture
 *
 * @history
 *
 *    |  Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |---------------------------------|-----------------------|------------------------|------------------------------------------------|
      |  nicole.genon                   | April 22, 2024        | DEPP-8498              | Created file                                   |
*/
public inherited sharing class DonationAssetsDAO extends DmlBase implements IDonationAssetsDAO {

    public Schema.SObjectType getSObjectType() {
        return Donation_Asset__c.SObjectType;
    }

    public static IDonationAssetsDAO newInstance() {
        return (IDonationAssetsDAO) ImplementationSelector.DAO.newInstance(
            Donation_Asset__c.SObjectType
        );
    }

}