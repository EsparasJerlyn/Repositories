/**
 * @description test class for Donation_Cause_Stage_Update Flow
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | March, 15, 2024       | DEPP-8210              | Created file                 | 
 */
@isTest
private class Donation_Cause_Stage_Update_Test {
    @testSetup
    static void setupData() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Donor_Engagement_Manager' });
        Test.stopTest();
    }

    @isTest
    private static void forPublishedBatchTest() {
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                100
            );

            DonationCausesDAO.newInstance()
                .insertRecords(donationCauseList, false, AccessLevel.USER_MODE);

            for (Donation_Cause__c dc : donationCauseList) {
                dc.Ready_For_Publishing__c = true;
                dc.QUT_Giving_Publish_Start_Date__c = System.Today();
                dc.QUT_Giving_Publish_End_Date__c = System.Today() + 1;
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
}
