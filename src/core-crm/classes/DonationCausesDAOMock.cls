/**
 * @description Mock DAO Class for Donation Cause Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | March 14, 2024        | DEPP-8210              | Created file                                   |
*/
@isTest
public inherited sharing class DonationCausesDAOMock extends DmlBaseMock implements IDonationCausesDAO {
    public Map<Id, Donation_Cause__c> donationCausesMap;

    public Schema.SObjectType getSObjectType() {
        return Donation_Cause__c.SObjectType;
    }

    public DonationCausesDAOMock() {
        super(new Map<Id, Donation_Cause__c>(), Schema.Donation_Cause__c.SObjectType);
        this.donationCausesMap = (Map<Id, Donation_Cause__c>) super.records;
    }

    public Database.QueryLocator queryLocatorGetDonatioCausesForStageUpdate() {
        return null;
    }
}
