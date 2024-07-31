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
private class Designation_Child_Product_Update_Test {
    @testSetup
    static void setupData() {
        Test.startTest();
        TestDataFactoryUser.generateUserDonorEngagementManager();

        Designation_Code_Auto_Number__c designationCodeAutoNum = designationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        designationCodeAutoNum.Giving_To_Cause__c = 1;
        designationCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Designation_Code_Auto_Number__c>{designationCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
            );

        Test.stopTest();
    }

    @isTest
    private static void forAvailableOnCartTrueAndFalseTest() {
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );
            DesignationsDAO.newInstance().insertRecords(designationList, false, AccessLevel.USER_MODE);
            
            List<Distribution_Management__c> distributionMgtList = TestDataFactory.createDistributionManagementRecords(100, 'Active');
            for(Integer i = 0; i<100; i++){
                distributionMgtList[i].Designation__c = designationList[i].Id;
            }
            DistributionManagementsDAO.newInstance().insertRecords(distributionMgtList, false, AccessLevel.USER_MODE);

            Set<Id> designationIdSet = (new Map<Id,SObject>(designationList)).keySet();
            List<Product2> products = ProductsDAO.newInstance().getProductByDesignationId(designationIdSet, AccessLevel.USER_MODE);


            Integer count = 0;
            for (Product2 prd : products) {
                prd.Description__c = 'Test Description';
                prd.Title_Image_URL__c = 'imageurl.com';
                count++;
            }

            ProductsDAO.newInstance().updateRecords(products, false, AccessLevel.USER_MODE);

            for (Designation__c d : designationList) {
                d.Ready_For_Publishing__c = true;
                d.Public_Giving_Publish_Start_Date__c = System.Today();
                d.Public_Giving_Publish_End_Date__c = System.Today() + 1;
                d.QA_Completed__c = true;
            }

            Test.startTest();
            DesignationsDAO.newInstance()
                .updateRecords(designationList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Product2 prd : ProductsDAO.newInstance()
                    .getProductById(
                        (new Map<Id, Product2>(products)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    true,
                    prd.Available_on_Cart__c,
                    'Available_on_Cart__c should be true'
                );
            }

            for (Designation__c d : designationList) {
                d.Stage__c = '';
            }

            DesignationsDAO.newInstance()
                .updateRecords(designationList, false, AccessLevel.USER_MODE);

            for (
                Product2 prd : ProductsDAO.newInstance()
                    .getProductById(
                        (new Map<Id, Product2>(products)).keySet(),
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