/**
 * @description test class for DonationCauseStageUpdateBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | March 15, 2024        | DEPP-8210              | Created file                 |
      | eugene.andrew.abuan            | March 18, 2024        | DEPP-8211              | Added Active Stage           |         

 */
@isTest
private class DonationCauseStageUpdateBatchTest {
    @testSetup
    static void setupDate() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Sys_Admin','QUT_IE_Partnership_Manager' });
        Test.stopTest();
    }

    @isTest
    private static void forPublishedBatchTest() {
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                1
            );

            donationCauseList[0].Ready_For_Publishing__c = true;
            donationCauseList[0].QUT_Giving_Publish_Start_Date__c = System.Today();
            donationCauseList[0].QUT_Giving_Publish_End_Date__c = System.Today() + 1;

            DonationCausesDAO.newInstance()
                .insertRecords(donationCauseList, false, AccessLevel.USER_MODE);

            Test.startTest();
            DonationCauseStageUpdateBatch batch = new DonationCauseStageUpdateBatch();
            Database.executeBatch(batch);
            Test.stopTest();

            System.assertEquals(
                DonationCausesDAO.DC_PUBLISHED,
                DonationCausesDAO.newInstance()
                        .getDonationCausesBySetRecordIds(new Set<Id>{ donationCauseList[0].Id }, AccessLevel.SYSTEM_MODE)[0]
                    .Stage__c,
                'Stage should be published'
            );
        }
    }

    @isTest
    private static void forActiveBatchTest() {
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                1
            );
            donationCauseList[0].QUT_Giving_Publish_Start_Date__c = System.Today() + 1;
            donationCauseList[0].Ready_For_Publishing__c = true;
            donationCauseList[0].QUT_Giving_Publish_End_Date__c = System.Today();
            donationCauseList[0].Activation_End_Date__c = System.Today() + 1;

            DonationCausesDAO.newInstance()
                .insertRecords(donationCauseList, false, AccessLevel.USER_MODE);

            Test.startTest();
            DonationCauseStageUpdateBatch batch = new DonationCauseStageUpdateBatch();
            Database.executeBatch(batch);
            Test.stopTest();

            System.assertEquals(
                DonationCausesDAO.DC_ACTIVE,
                DonationCausesDAO.newInstance()
                        .getDonationCausesBySetRecordIds(new Set<Id>{ donationCauseList[0].Id }, AccessLevel.SYSTEM_MODE)[0]
                    .Stage__c,
                'Stage should be Active'
            );
        }
    }

}