/**
 * @description Mock DAO Class for Donation Cause Code Auto Number custom setting. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 20, 2023        | DEPP-8200              | Created file                 |
 */
@isTest
public inherited sharing class DonationCauseCodeAutoNumbersDAOMock extends DmlBaseMock implements IDonationCauseCodeAutoNumbersDAO {
    public Map<Id, Donation_Cause_Code_Auto_Number__c> donationCauseAutoNumMap;

    public Schema.SObjectType getSObjectType() {
        return Donation_Cause_Code_Auto_Number__c.SObjectType;
    }

    public DonationCauseCodeAutoNumbersDAOMock() {
        super(new Map<Id, Donation_Cause_Code_Auto_Number__c>(), Schema.Donation_Cause_Code_Auto_Number__c.SObjectType);
        this.donationCauseAutoNumMap = (Map<Id, Donation_Cause_Code_Auto_Number__c>) super.records;
    }

    public Donation_Cause_Code_Auto_Number__c getOrganizationalDefaults() {
        if(donationCauseAutoNumMap.isEmpty()) {
            return new Donation_Cause_Code_Auto_Number__c();
        } else {
            return donationCauseAutoNumMap.values()[0];
        }
    }
}
