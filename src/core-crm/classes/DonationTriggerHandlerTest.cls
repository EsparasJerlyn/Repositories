/**
 * @description Test Class for DonationTriggerHandler. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | nicole.genon                   | April 22, 2024        | DEPP-8498              | Created file                 |                                                     |
 */
@isTest
public with sharing class DonationTriggerHandlerTest {
    @testSetup
    static void setup() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Account> accountRecord = TestDataFactory.createTestAccountRecordsWithRecordType(1, AccountsDAO.ACCT_UNIV_DEP_ID);
            accountRecord[0].Organization_Unit_Level__c ='2';
            accountRecord[0].End_Date__c = null;
            AccountsDAO.newInstance().insertRecords(accountRecord, false, AccessLevel.SYSTEM_MODE);

            List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            newContacts[0].AccountId = accountRecord[0].Id;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

            List<Opportunity> individualOpportunityRecords = TestDataFactory.createTestOpportunityRecords(
                    1,'OppTest',OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID);

            individualOpportunityRecords[0].Description = 'Test';
            individualOpportunityRecords[0].ContactId = newContacts[0].Id;
            individualOpportunityRecords[0].Contact__c = newContacts[0].Id;
            individualOpportunityRecords[0].Donor_Linkage_Rank__c = 'Low Level of Connection';
            individualOpportunityRecords[0].Donor_Interest_Rank__c = 'Unknown or not assessed';
            individualOpportunityRecords[0].Donor_Ability_Rank__c = '$250K - $500K';
            individualOpportunityRecords[0].Probability_Of_Success__c = '60%';
            individualOpportunityRecords[0].Qualification_Summary__c = 'Test';
            individualOpportunityRecords[0].Is_Qualified__c = true;
            individualOpportunityRecords[0].Solicitation_Sub_Stage__c = 'Agreement';
            individualOpportunityRecords[0].Due_Diligence_Summary__c = 'Test';
            individualOpportunityRecords[0].Due_Diligence_Completed__c = true;
            individualOpportunityRecords[0].Is_Agreement_Signed__c = true;
            individualOpportunityRecords[0].StageName = OpportunitiesDAO.SOLICITATION_STAGE;

            OpportunitiesDAO.newInstance().insertRecords(individualOpportunityRecords, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    private static void testPlatformEventInsertAndUpdate() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Opportunity> oppRecords = OpportunitiesDAO.getOpportunityByRecordTypeIds(new Set<Id>{OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID},AccessLevel.USER_MODE);
            
            List<Donation_Asset__c> donationAssetRecords = TestDataFactory.createDonationAssetRecords(1);

            DonationAssetsDAO.newInstance()
                .insertRecords(donationAssetRecords, false, AccessLevel.USER_MODE);

            Test.startTest();

            List<Donation__c> donationRecords = TestDataFactory.createDonationRecordsWithOpportunity(
                1,oppRecords[0].Id);
            donationRecords[0].Donation_Comment__c = 'Test Donation';
            donationRecords[0].RecordTypeId = DonationsDAO.GIFT_IN_KIND_RECTYPE_ID;
            donationRecords[0].Donation_Asset__c = donationAssetRecords[0].Id;

            System.assert(
                DonationsDAO.newInstance()
                        .insertRecords(donationRecords, true, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Donation is not created'
            );

            donationRecords[0].Donation_Comment__c = 'test update title';

            System.assert(
                DonationsDAO.newInstance()
                        .updateRecords(donationRecords, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Donation is not updated'
            );
            Test.stopTest();
        }
    }
}