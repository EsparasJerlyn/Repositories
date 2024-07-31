/**
 * @description test class for ChildDonationModalCtrl.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                  |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------------------------|
      | neil.s.h.lesidan               | April 30, 2024        | DEPP-8610              | Created file                                                    |
      |                                |                       | DEPP-8570              |                                                                 |
      |                                |                       | DEPP-8682              |                                                                 |
      | neil.s.h.lesidan               | April 30, 2024        | DEPP-8595              | Add method getDonationsByRecordTypePledgeParentIdTest           |
      |                                |                       | DEPP-8632, DEPP-8720   | Add method upsertDonationChildPledgeTest                        |
      |                                |                       | DEPP-8596              | Add method getDonationsByRecordTypePledgeInstalmentParentIdTest |
      |                                |                       | DEPP-8621, DEPP-8721   | Add method upsertDonationChildPledgeInstalmentTest              |
      |                                |                       |                        |                                                                 |
 */
@isTest
private class ChildDonationModalCtrlTest {
    @testSetup
    static void setupData() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationRecords = TestDataFactory.createDesignationRecords(1, DesignationsDAO.ENDOWNMENT_RECTYPE_ID);
            designationRecords[0].Endowment_Account_Type__c = DesignationsDAO.ENDOWMENT_ACCOUNT_TYPE_PERPETUAL;
            DesignationsDAO.newInstance().insertRecords(designationRecords, false, AccessLevel.USER_MODE);

            List<Opportunity> opportunityRecords = TestDataFactory.createOpportunityRecords(1, 'test', OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID);
            OpportunitiesDAO.newInstance().insertRecords(opportunityRecords, false, AccessLevel.USER_MODE);

            List<Donation__c> donationParentRecords = TestDataFactory.createDonationRecordsWithOpportunity(3, opportunityRecords[0].Id);
            donationParentRecords[0].RecordTypeId = DonationsDAO.ENDOWMENT_RECTYPE_ID;
            donationParentRecords[0].Donation_Comment__c = 'test';
            donationParentRecords[0].Payment_Type__c = DonationsDAO.PAYMENT_PLAN_PAYMENT_TYPE;
            donationParentRecords[0].To_Designation__c = designationRecords[0].Id;
            donationParentRecords[0].Total_Amount__c = 100;
            donationParentRecords[0].Stage__c = DonationsDAO.ACCEPTED_STAGE;
            donationParentRecords[1].RecordTypeId = DonationsDAO.PLEDGE_RECTYPE_ID;
            donationParentRecords[1].Donation_Comment__c = 'test';
            donationParentRecords[1].Payment_Type__c = DonationsDAO.PAYMENT_PLAN_PAYMENT_TYPE;
            donationParentRecords[2].Total_Amount__c = 100;
            donationParentRecords[2].Stage__c = DonationsDAO.ACCEPTED_STAGE;
            donationParentRecords[2].RecordTypeId = DonationsDAO.PLEDGE_RECTYPE_ID;
            donationParentRecords[2].Donation_Comment__c = 'test';
            donationParentRecords[2].Payment_Type__c = DonationsDAO.PAYMENT_PLAN_PAYMENT_TYPE;
            donationParentRecords[2].Total_Amount__c = 100;
            donationParentRecords[2].Stage__c = DonationsDAO.ACCEPTED_STAGE;
            DonationsDAO.newInstance().insertRecords(donationParentRecords, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    private static void getDonationsByRecordTypeEndowmentInstalmentParentIdTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            Donation__c donationParentRecord = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(
                new Set<Id>{DonationsDAO.ENDOWMENT_RECTYPE_ID}, AccessLevel.USER_MODE
            ).iterator().next();

            List<Donation__c> donationChildRecords = TestDataFactory.createDonationRecordsWithOpportunity(1, donationParentRecord.Opportunity__c);
            donationChildRecords[0].Donation_Parent__c = donationParentRecord.Id;
            donationChildRecords[0].RecordTypeId = DonationsDAO.ENDOWMENT_INSTALMENT_RECTYPE_ID;
            donationChildRecords[0].Stage__c = donationParentRecord.Stage__c;
            DonationsDAO.newInstance().insertRecords(donationChildRecords, false, AccessLevel.USER_MODE);

            Test.startTest();
                List<Donation__c> donationList = ChildDonationModalCtrl.getDonationsByRecordTypeParentId(donationParentRecord.Id, DonationsDAO.ENDOWMENT_INSTALMENT_RECTYPE_NAME);
            Test.stopTest();

            System.assert(!donationList.isEmpty(), 'No Donation record found');
        }
    }

    @isTest
    private static void getDonationsByRecordTypePledgeInstalmentParentIdTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Donation__c> donationParentRecords = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(
                new Set<Id>{DonationsDAO.PLEDGE_RECTYPE_ID}, AccessLevel.USER_MODE
            );

            Donation__c donationParent = new Donation__c();

            for (Donation__c result : donationParentRecords) {
                if (result.Payment_Type__c ==  'One-Off Payment') {
                    donationParent = result;
                }
            }

            List<Donation__c> donationChildRecords = TestDataFactory.createDonationRecordsWithOpportunity(1, donationParent.Opportunity__c);
            donationChildRecords[0].Donation_Parent__c = donationParent.Id;
            donationChildRecords[0].RecordTypeId = DonationsDAO.PLEDGE_INSTALMENT_RECTYPE_ID;
            donationChildRecords[0].Donation_Comment__c = donationParent.Donation_Comment__c;
            donationChildRecords[0].Payment_Type__c = DonationsDAO.PAYMENT_PLAN_PAYMENT_TYPE;
            donationChildRecords[0].Total_Amount__c = 100;
            donationChildRecords[0].Stage__c = DonationsDAO.ACCEPTED_STAGE;
            DonationsDAO.newInstance().insertRecords(donationChildRecords, false, AccessLevel.USER_MODE);

            Test.startTest();
                List<Donation__c> donationList = ChildDonationModalCtrl.getDonationsByRecordTypeParentId(donationParent.Id, DonationsDAO.PLEDGE_INSTALMENT_RECTYPE_NAME);
            Test.stopTest();

            System.assert(!donationList.isEmpty(), 'No Donation record found');
        }
    }

    @isTest
    private static void getDonationsByRecordTypePledgeParentIdTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Donation__c> donationParentRecords = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(
                new Set<Id>{DonationsDAO.PLEDGE_RECTYPE_ID}, AccessLevel.USER_MODE
            );

            Donation__c donationParent = new Donation__c();

            for (Donation__c result : donationParentRecords) {
                if (result.Payment_Type__c ==  'Payment Plan') {
                    donationParent = result;
                }
            }

            List<Donation__c> donationChildRecords = TestDataFactory.createDonationRecordsWithOpportunity(1, donationParent.Opportunity__c);
            donationChildRecords[0].Donation_Parent__c = donationParent.Id;
            donationChildRecords[0].RecordTypeId = DonationsDAO.PLEDGE_DESIGNATION_SPLIT_RECTYPE_ID;
            donationChildRecords[0].Donation_Comment__c = donationParent.Donation_Comment__c;
            donationChildRecords[0].Payment_Type__c = DonationsDAO.PAYMENT_PLAN_PAYMENT_TYPE;
            donationChildRecords[0].Total_Amount__c = 100;
            donationChildRecords[0].Stage__c = DonationsDAO.ACCEPTED_STAGE;
            DonationsDAO.newInstance().insertRecords(donationChildRecords, false, AccessLevel.USER_MODE);

            Test.startTest();
                List<Donation__c> donationList = ChildDonationModalCtrl.getDonationsByRecordTypeParentId(donationParent.Id, DonationsDAO.PLEDGE_DESIGNATION_SPLIT_RECTYPE_NAME);
            Test.stopTest();

            System.assert(!donationList.isEmpty(), 'No Donation record found');
        }
    }

    @isTest
    private static void upsertDonationChildEndowmentInstalmentTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            Donation__c donationParentRecord = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(
                new Set<Id>{DonationsDAO.ENDOWMENT_RECTYPE_ID}, AccessLevel.USER_MODE
            ).iterator().next();

            List<Donation__c> donationChildRecords = TestDataFactory.createDonationRecordsWithOpportunity(1, donationParentRecord.Opportunity__c);
            donationChildRecords[0].Donation_Parent__c = donationParentRecord.Id;
            donationChildRecords[0].Stage__c = DonationsDAO.ACCEPTED_STAGE;

            Test.startTest();
                List<Donation__c> upsertRecord = ChildDonationModalCtrl.upsertDonationChild(donationChildRecords, DonationsDAO.ENDOWMENT_INSTALMENT_RECTYPE_NAME);
            Test.stopTest();

            System.assert(!upsertRecord.isEmpty(), 'No Donation record found');
        }
    }

    @isTest
    private static void upsertDonationChildPledgeInstalmentTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Donation__c> donationParentRecords = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(
                new Set<Id>{DonationsDAO.PLEDGE_RECTYPE_ID}, AccessLevel.USER_MODE
            );

            Donation__c donationParent = new Donation__c();

            for (Donation__c result : donationParentRecords) {
                if (result.Payment_Type__c ==  'One-Off Payment') {
                    donationParent = result;
                }
            }

            List<Donation__c> donationChildRecords = TestDataFactory.createDonationRecordsWithOpportunity(1, donationParent.Opportunity__c);
            donationChildRecords[0].Donation_Parent__c = donationParent.Id;
            donationChildRecords[0].Donation_Comment__c = donationParent.Donation_Comment__c;
            donationChildRecords[0].Payment_Type__c = DonationsDAO.PAYMENT_PLAN_PAYMENT_TYPE;
            donationChildRecords[0].Total_Amount__c = 100;
            donationChildRecords[0].Stage__c = DonationsDAO.ACCEPTED_STAGE;

            Test.startTest();
                List<Donation__c> upsertRecord = ChildDonationModalCtrl.upsertDonationChild(donationChildRecords, DonationsDAO.PLEDGE_INSTALMENT_RECTYPE_NAME);
            Test.stopTest();

            System.assert(!upsertRecord.isEmpty(), 'No Donation record found');
        }
    }

    @isTest
    private static void upsertDonationChildPledgeTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Donation__c> donationParentRecords = DonationsDAO.newInstance().getDonationsBySetRecordTypeIds(
                new Set<Id>{DonationsDAO.PLEDGE_RECTYPE_ID}, AccessLevel.USER_MODE
            );

            Donation__c donationParent = new Donation__c();

            for (Donation__c result : donationParentRecords) {
                if (result.Payment_Type__c ==  'Payment Plan') {
                    donationParent = result;
                }
            }

            List<Donation__c> donationChildRecords = TestDataFactory.createDonationRecordsWithOpportunity(1, donationParent.Opportunity__c);
            donationChildRecords[0].Donation_Parent__c = donationParent.Id;
            donationChildRecords[0].Donation_Comment__c = donationParent.Donation_Comment__c;
            donationChildRecords[0].Payment_Type__c = DonationsDAO.PAYMENT_PLAN_PAYMENT_TYPE;
            donationChildRecords[0].Total_Amount__c = 100;
            donationChildRecords[0].Stage__c = DonationsDAO.ACCEPTED_STAGE;

            Test.startTest();
                List<Donation__c> upsertRecord = ChildDonationModalCtrl.upsertDonationChild(donationChildRecords, DonationsDAO.PLEDGE_DESIGNATION_SPLIT_RECTYPE_NAME);
            Test.stopTest();

            System.assert(!upsertRecord.isEmpty(), 'No Donation record found');
        }
    }
}