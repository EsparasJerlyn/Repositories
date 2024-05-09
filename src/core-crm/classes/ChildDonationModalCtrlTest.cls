/**
 * @description test class for ChildDonationModalCtrl.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | neil.s.h.lesidan               | April 30, 2024        | DEPP-8610              | Created file                                      |
      |                                |                       | DEPP-8570              |                                                   |
      |                                |                       | DEPP-8682              |                                                   |
 */
@isTest
private class ChildDonationModalCtrlTest {
    @testSetup
    static void setupData() {
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Advancement_Manager'});
        System.runAs(TestDataFactory.getAdvancementManager()) {
            List<Designation__c> designationRecords = TestDataFactory.createDesignationRecords(1, DesignationsDAO.ENDOWNMENT_RECTYPE_ID);
            designationRecords[0].Endowment_Account_Type__c = DesignationsDAO.ENDOWMENT_ACCOUNT_TYPE_PERPETUAL;
            DesignationsDAO.newInstance().insertRecords(designationRecords, false, AccessLevel.USER_MODE);

            List<Opportunity> opportunityRecords = TestDataFactory.createOpportunityRecords(1, 'test', OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID);
            OpportunitiesDAO.newInstance().insertRecords(opportunityRecords, false, AccessLevel.USER_MODE);

            List<Donation__c> donationParentRecords = TestDataFactory.createDonationRecordsWithOpportunity(1, opportunityRecords[0].Id);
            donationParentRecords[0].RecordTypeId = DonationsDAO.ENDOWMENT_RECTYPE_ID;
            donationParentRecords[0].Donation_Comment__c = 'test';
            donationParentRecords[0].Payment_Type__c = DonationsDAO.PAYMENT_PLAN_PAYMENT_TYPE;
            donationParentRecords[0].To_Designation__c = designationRecords[0].Id;
            donationParentRecords[0].Total_Amount__c = 100;
            donationParentRecords[0].Stage__c = DonationsDAO.ACCEPTED_STAGE;
            DonationsDAO.newInstance().insertRecords(donationParentRecords, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    private static void getDonationsEndowmentInstalmentTest(){
        System.runAs(TestDataFactory.getAdvancementManager()) {
            Donation__c donationParentRecord = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(
                new Set<Id>{DonationsDAO.ENDOWMENT_RECTYPE_ID}, AccessLevel.USER_MODE
            ).iterator().next();

            List<Donation__c> donationChildRecords = TestDataFactory.createDonationRecordsWithOpportunity(1, donationParentRecord.Opportunity__c);
            donationChildRecords[0].Donation_Parent__c = donationParentRecord.Id;
            donationChildRecords[0].RecordTypeId = DonationsDAO.ENDOWMENT_INSTALMENT_RECTYPE_ID;
            donationChildRecords[0].Stage__c = donationParentRecord.Stage__c;
            List<Database.SaveResult> testDo = DonationsDAO.newInstance().insertRecords(donationChildRecords, false, AccessLevel.USER_MODE);

            Test.startTest();
                List<Donation__c> donationList = ChildDonationModalCtrl.getDonationsEndowmentInstalment(donationParentRecord.Id);
            Test.stopTest();

            System.assert(!donationList.isEmpty(), 'No Donation record found');
        }
    }

    @isTest
    private static void upsertDonationChildEndownmentInstalmentTest(){
        System.runAs(TestDataFactory.getAdvancementManager()) {
            Donation__c donationParentRecord = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(
                new Set<Id>{DonationsDAO.ENDOWMENT_RECTYPE_ID}, AccessLevel.USER_MODE
            ).iterator().next();

            List<Donation__c> donationChildRecords = TestDataFactory.createDonationRecordsWithOpportunity(1, donationParentRecord.Opportunity__c);
            donationChildRecords[0].Donation_Parent__c = donationParentRecord.Id;
            donationChildRecords[0].RecordTypeId = DonationsDAO.ENDOWMENT_INSTALMENT_RECTYPE_ID;
            donationChildRecords[0].Stage__c = donationParentRecord.Stage__c;

            Test.startTest();
                List<Donation__c> upsertRecord = ChildDonationModalCtrl.upsertDonationChildEndownmentInstalment(donationChildRecords);
            Test.stopTest();

            System.assert(!upsertRecord.isEmpty(), 'No Donation record found');
        }
    }
}