/**
 * @description test class for Donation_Cause_Child_Product_Update Flow
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
      | roy.nino.s.regala              | March, 15, 2024       | DEPP-8210              | Created file                                    | 
      | eugene.andrew.abuan            | March 22, 2024        | DEPP-8200              | Added Donation Cause in Setup                   |
      | kenneth.f.alsay                | April 1, 2024         | DEPP-8209              | Added field values to pass new validation rules |

 */
@isTest
private class Donation_Cause_Child_Product_Update_Test {
    @testSetup
    static void setupData() {
        Test.startTest();
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
    private static void forAvailableOnCartTrueAndFalseTest() {
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            List<Donation_Cause__c> donationCauseList = TestDataFactory.createDonationCauseRecords(
                100
            );

            DonationCausesDAO.newInstance()
                .insertRecords(donationCauseList, false, AccessLevel.USER_MODE);

            List<Product2> productList = TestDataFactory.createTestProductRecords(100);

            Integer count = 0;

            for (Product2 prd : productList) {
                prd.Donation_Cause__c = donationCauseList[0].Id;
                prd.Description__c = 'Test Description';
                prd.Title_Image_URL__c = 'imageurl.com';
                count++;
            }

            ProductsDAO.newInstance().insertRecords(productList, false, AccessLevel.USER_MODE);

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

            for (Donation_Cause__c dc : donationCauseList) {
                dc.Stage__c = '';
            }

            DonationCausesDAO.newInstance()
                .updateRecords(donationCauseList, false, AccessLevel.USER_MODE);

            for (
                Product2 prd : ProductsDAO.newInstance()
                    .getProductById(
                        (new Map<Id, Product2>(productList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    false,
                    prd.Available_on_Cart__c,
                    'Available_on_Cart__c should be false'
                );
            }
        }
    }
}