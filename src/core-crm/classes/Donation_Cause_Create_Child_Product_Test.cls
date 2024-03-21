/**
 * @description test class for Donation_Cause_Create_Child_Product Flow
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kathleen.mae.caceres           | March, 20, 2024       | DEPP-8201              | Created file                 | 
 */
@isTest
private class Donation_Cause_Create_Child_Product_Test {
    public static final String DC_PUBLICGIVING = 'Yes';
    
    @testSetup
    static void setupData() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Donor_Engagement_Manager' });
        Test.stopTest();
    }

    @isTest
    private static void createDonCauseChildProd() {
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                100
            );

            DonationCausesDAO.newInstance()
                .insertRecords(donationCauseList, false, AccessLevel.USER_MODE);

            for (Donation_Cause__c dc : donationCauseList) {
                dc.Is_For_Public_Giving__c = DC_PUBLICGIVING;
            }

            Test.startTest();
            DonationCausesDAO.newInstance()
                .updateRecords(donationCauseList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Donation_Cause__c eachDonCause : DonationCausesDAO.newInstance()
                    .getDonationCausesBySetRecordIds(
                        (new Map <Id, Donation_Cause__c>(donationCauseList)).keySet(),
                         AccessLevel.USER_MODE
                )
             ) {
                system.assert(!eachDonCause.Products__r.isEmpty(), 'Products should be created');   
            }
        }
    }
    }