/**
 * @description test class for Donation_Cause_Stage_Update Flow
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
      | roy.nino.s.regala              | March 15, 2024        | DEPP-8210              | Created file                                    |
      | eugene.andrew.abuan            | March 19, 2024        | DEPP-8211              | Added Active Stage                              | 
      | kenneth.f.alsay                | April 1, 2024         | DEPP-8209              | Added field values to pass new validation rules |

 */
@isTest
private class Donation_Cause_Stage_Update_Test {
    @testSetup
    static void setupData() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
        TestDataFactoryUser.generateUserDonorEngagementManager();

        Donation_Cause_Code_Auto_Number__c donationCauseCodeAutoNum = DonationCauseCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        donationCauseCodeAutoNum.Donation_Cause__c = 1;
        DonationCauseCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Donation_Cause_Code_Auto_Number__c>{donationCauseCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
            );
            
        Test.stopTest();
    }

    @isTest
    private static void forPublishedBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                100
            );

            DonationCausesDAO.newInstance()
                .insertRecords(donationCauseList, false, AccessLevel.USER_MODE);

            for (Donation_Cause__c dc : donationCauseList) {
                dc.Ready_For_Publishing__c = true;
                dc.QUT_Giving_Publish_Start_Date__c = System.Today();
                dc.QUT_Giving_Publish_End_Date__c = System.Today() + 1;
                dc.QA_Completed__c = true;
            }

            Test.startTest();
            DonationCausesDAO.newInstance()
                .updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Donation_Cause__c dc : DonationCausesDAO.newInstance()
                    .getDonationCausesBySetRecordIds(
                        (new Map<Id, Donation_Cause__c>(donationCauseList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    DonationCausesDAO.DC_PUBLISHED,
                    dc.Stage__c,
                    'Stage should be published'
                );
            }
        }
    }
    
    @isTest
    private static void forNotPublishedBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                100
            );

            DonationCausesDAO.newInstance()
                .insertRecords(donationCauseList, false, AccessLevel.USER_MODE);

            for (Donation_Cause__c dc : donationCauseList) {
                dc.Stage__c = DonationCausesDAO.DC_ARCHIVED;
                dc.Ready_For_Publishing__c = true;
                dc.QUT_Giving_Publish_Start_Date__c = System.Today();
                dc.QUT_Giving_Publish_End_Date__c = System.Today() + 1;
                dc.QA_Completed__c = true;
            }

            Test.startTest();
            DonationCausesDAO.newInstance()
                .updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Donation_Cause__c dc : DonationCausesDAO.newInstance()
                    .getDonationCausesBySetRecordIds(
                        (new Map<Id, Donation_Cause__c>(donationCauseList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertNotEquals(
                    DonationCausesDAO.DC_PUBLISHED,
                    dc.Stage__c,
                    'Stage should be published'
                );
            }
        }
    }

    @isTest
    private static void forActiveBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                100
            );

            DonationCausesDAO.newInstance()
                .insertRecords(donationCauseList, false, AccessLevel.USER_MODE);

            for (Donation_Cause__c dc : donationCauseList) {
                dc.Ready_For_Publishing__c = false;
                dc.Activation_End_Date__c = System.Today() + 1;
            }

            Test.startTest();
            DonationCausesDAO.newInstance()
                .updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Donation_Cause__c dc : DonationCausesDAO.newInstance()
                    .getDonationCausesBySetRecordIds(
                        (new Map<Id, Donation_Cause__c>(donationCauseList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    DonationCausesDAO.DC_ACTIVE,
                    dc.Stage__c,
                    'Stage should be Active'
                );
            }
        }
    }

    @isTest
    private static void forNotActiveBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                100
            );

            DonationCausesDAO.newInstance()
                .insertRecords(donationCauseList, false, AccessLevel.USER_MODE);

            for (Donation_Cause__c dc : donationCauseList) {
                dc.Stage__c = DonationCausesDAO.DC_ARCHIVED;
                dc.Ready_For_Publishing__c = false;
                dc.Activation_End_Date__c = System.Today() + 1;
            }

            Test.startTest();
            DonationCausesDAO.newInstance()
                .updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Donation_Cause__c dc : DonationCausesDAO.newInstance()
                    .getDonationCausesBySetRecordIds(
                        (new Map<Id, Donation_Cause__c>(donationCauseList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertNotEquals(
                    DonationCausesDAO.DC_ACTIVE,
                    dc.Stage__c,
                    'Stage should not be Active'
                );
            }
        }
    }

    @isTest
    private static void forArchivedBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                100
            );

            DonationCausesDAO.newInstance()
                .insertRecords(donationCauseList, false, AccessLevel.USER_MODE);

            for (Donation_Cause__c dc : donationCauseList) {
                dc.Archived_Date__c = System.Today();
                dc.Archived_Comment__c = 'Test Archived';
                dc.Archived_Reason__c = 'Other';
            }

            Test.startTest();
            DonationCausesDAO.newInstance()
                .updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Donation_Cause__c dc : DonationCausesDAO.newInstance()
                    .getDonationCausesBySetRecordIds(
                        (new Map<Id, Donation_Cause__c>(donationCauseList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    DonationCausesDAO.DC_ARCHIVED,
                    dc.Stage__c,
                    'Stage should be archived'
                );
            }
        }
    }
}