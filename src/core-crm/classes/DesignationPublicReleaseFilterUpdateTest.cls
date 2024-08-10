/**
 * @description test class for Designation_Public_Release_Filter_Update Flow
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                          |
 *    |--------------------------------|-----------------------|------------------------|-----------------------------------------|
 *    | kim.howard.capanas             | April 16, 2024        | DEPP-8433              | Created File                            |
 */
@isTest
private class DesignationPublicReleaseFilterUpdateTest {
    // * Description: This method is used to create initial data for the test methods
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
        Test.stopTest();
    }

    @isTest
    private static void checkProductsUpdate() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            Test.startTest();
            List<Designation__C> designationList = TestDataFactory.createDesignationRecords(
                10,
                DesignationsDAO.ENDOWNMENT_RECTYPE_ID
            );
            
            for(Designation__c d : designationList){
                d.Endowment_Account_Type__c = DesignationsDAO.ENDOWMENT_ACCOUNT_TYPE_PERPETUAL;
            }

            ProductsDAO.newInstance().insertRecords(designationList, false, AccessLevel.USER_MODE);

            List<Product2> productsList = ProductsDAO.newInstance().getProductByDesignationId(new Set<Id>{designationList[0].Id}, AccessLevel.USER_MODE);

            productsList[0].Giving_Category__c = 'Support Community';
            productsList[0].Study_Association__c = 'Architecture and Built Environment';

            ProductsDAO.newInstance().updateRecords(productsList, false, AccessLevel.USER_MODE);

            Test.stopTest();

            List<Designation__c> designationsList = DesignationsDAO.newInstance().getDesignationsBySetRecordIds(new Set<Id>{productsList[0].Designation__c}, AccessLevel.USER_MODE);
            
            System.assert(designationsList[0].Giving_Category__c == 'Support Community', 'Giving_Category__c is Support Community.');
            System.assert(designationsList[0].Study_Association__c == 'Architecture and Built Environment', 'Architecture and Built Environment is Architecture and Built Environment.');
        }
    }
}