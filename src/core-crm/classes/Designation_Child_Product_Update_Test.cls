/**
 * @description test class for Designation_Child_Product_Update Flow
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
private class Designation_Child_Product_Update_Test {
    @testSetup
    static void setupData() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Donor_Engagement_Manager' });
        Test.stopTest();
    }

    @isTest
    private static void forAvailableOnCartTrueAndFalseTest() {
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100
            );

            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);

            List<Product2> productList = TestDataFactory.createTestProductRecords(100);

            Integer count = 0;

            for (Product2 prd : productList) {
                prd.Designation__c = designationList[0].Id;
                prd.Description__c = 'Test Description';
                prd.Title_Image_URL__c = 'imageurl.com';
                count++;
            }

            ProductsDAO.newInstance().insertRecords(productList, false, AccessLevel.USER_MODE);

            for (Designation__c dc : designationList) {
                dc.Ready_For_Publishing__c = true;
                dc.Public_Giving_Publish_Start_Date__c = System.Today();
                dc.Public_Giving_Publish_End_Date__c = System.Today() + 1;
                QA_Completed__c = true;
            }

            Test.startTest();
            DesignationsDAO.newInstance()
                .updateRecords(designationList, false, AccessLevel.USER_MODE);
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

            for (Designation__c dc : designationList) {
                dc.Stage__c = '';
            }

            DesignationsDAO.newInstance()
                .updateRecords(designationList, false, AccessLevel.USER_MODE);

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