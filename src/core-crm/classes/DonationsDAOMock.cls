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
      | neil.s.h.lesidan               | April 30, 2024        | DEPP-8610              | Add method getDonationsByParentIdRecordType    |
      |                                |                       | DEPP-8570              |                                                |
      |                                |                       | DEPP-8682              |                                                |
      | nicole.genon                   | May 2, 2024           | DEPP-8673              | Added getDonationsBySetDonationParentIds,      |
      |                                |                       |                        | getDonationsBySetRecordTypeIds                 |
      | kenneth.f.alsay                | May 6, 2024           | DEPP-8499              | Added getDonationAssetsByDonationId            |
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

    public List<Donation__c> getDonationAssetsByDonationId(
        Set<Id> donationIds,
        AccessLevel accessLevel
    ){
        List<Donation__c> donationList = new List<Donation__c>();
        for (Donation__c record : donationsMap.values()) {
            if (donationIds.contains(record.Id)) {
                donationList.add(record);
            }
        }
        return donationList;
    }

    public List<Donation__c> getDonationsBySetDonationParentIds(
        Set<Id> donationParentIds,
        AccessLevel accessLevel
    ) {
        List<Donation__c> donationList = new List<Donation__c>();
        for (Donation__c record : donationsMap.values()) {
            if (donationParentIds.contains(record.Donation_Parent__c)) {
                donationList.add(record);
            }
        }
        return donationList;
    }

    public List<Donation__c> getDonationsBySetRecordTypeIds(
        Set<Id> recordTypeIds,
        AccessLevel accessLevel
    ) {
        List<Donation__c> donationList = new List<Donation__c>();
        for (Donation__c record : donationsMap.values()) {
            if (recordTypeIds.contains(record.RecordTypeId)) {
                donationList.add(record);
            }
        }
        return donationList;
    }

    public List<Donation__c> getDonationsByParentIdRecordType(
        Set<Id> parentDonations,
        Id recordTypeId,
        AccessLevel accessLevel
    ) {
        List<Donation__c> donationList = new List<Donation__c>();
        for (Donation__c record : donationsMap.values()) {
            if (parentDonations.contains(record.Donation_Parent__c) && record.RecordTypeId == recordTypeId) {
                donationList.add(record);
            }
        }
        return donationList;
    }
}
