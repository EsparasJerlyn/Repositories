/**
 * @description Mock DAO Class for Donation Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | nicole.genon                   | March 29, 2024        | DEPP-8167              | Created file                                   |
      | kenneth.f.alsay                | April 23, 2024        | DEPP-8528              | Added getDonationsBySetRecordIds               |
      | kenneth.f.alsay                | April 24, 2024        | DEPP-8528              | Added queryLocatorGetDonationsForStageUpdate   |
*/
@isTest
public inherited sharing class DonationsDAOMock extends DmlBaseMock implements IDonationsDAO {
    public Map<Id, Donation__c> donationsMap ;

    public Schema.SObjectType getSObjectType() {
        return Donation__c.SObjectType;
    }

    public DonationsDAOMock() {
        super(new Map<Id, Donation__c>(), Schema.Donation__c.SObjectType);
        this.donationsMap = (Map<Id, Donation__c>) super.records;
    }

    public Database.QueryLocator queryLocatorGetDonationsForStageUpdate() {
        return null;
    }

    public List<Donation__c> getDonationsByOpportunityIds(
        Set<Id> opportunityIds,
        AccessLevel accessLevel
    ) {
        List<Donation__c> donationList = new List<Donation__c>();
        for (Donation__c record : donationsMap.values()) {
            if (opportunityIds.contains(record.Opportunity__c)) {
                donationList.add(record);
            }
        }
        return donationList;
    }

    public List<Donation__c> getDonationsBySetRecordIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        List<Donation__c> donationList = new List<Donation__c>();
        for (Donation__c record : donationsMap.values()) {
            if (recordIds.contains(record.Id)) {
                donationList.add(record);
            }
        }
        return donationList;
    }
}