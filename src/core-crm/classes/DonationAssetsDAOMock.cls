/**
 * @description Mock DAO Class for Donation Asset Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | nicole.genon                   | April 22, 2024        | DEPP-8498              | Created file                                   |
*/
@isTest
public inherited sharing class DonationAssetsDAOMock extends DmlBaseMock implements IDonationAssetsDAO {
    public Map<Id, Donation_Asset__c> donationAssetsMap ;

    public Schema.SObjectType getSObjectType() {
        return Donation_Asset__c.SObjectType;
    }

    public DonationAssetsDAOMock() {
        super(new Map<Id, Donation_Asset__c>(), Schema.Donation_Asset__c.SObjectType);
        this.donationAssetsMap = (Map<Id, Donation_Asset__c>) super.records;
    }
}