/**
 * @description test class for Donation_Cause_Child_Product_Update Flow
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
private class Donation_Cause_Child_Product_Update_Test {
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

            List<Product2> productList = TestDataFactory.createTestProductRecords(100);

            Integer count = 0;

            for (Product2 prd : productList) {
                prd.Donation_Cause__c = donationCauseList[0].Id;
                count++;
            }

            ProductsDAO.newInstance().insertRecords(productList, false, AccessLevel.USER_MODE);

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
                Product2 prd : ProductsDAO.newInstance()
                    .getProductById(
                        (new Map<Id, Product2>(productList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    true,
                    prd.Available_on_Cart__c,
                    'Available_on_Cart__c should be true'
                );
            }
        }
    }
}
