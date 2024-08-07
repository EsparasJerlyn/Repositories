/**
 * @description DynamicRecordEditFormCtrl Test Class
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                          |
 *    |--------------------------------|-----------------------|------------------------|-----------------------------------------|
 *    | eugene.andrew.abuan            | March 27, 2024        | DEPP-8203              | Created File                            |
 *    | kim.howard.capanas             | April 16, 2024        | DEPP-8393              | Update to designation test logic        |
 */


 @isTest
public class DynamicRecordEditFormCtrlTest {

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
        Test.stopTest();
    }

    @isTest
    private static void getRecordIdsTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            // Create test records 
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                10, 
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );
            DesignationsDAO.newInstance().insertRecords(designationList, false, AccessLevel.USER_MODE);
            List<Product2> product2RecList = ProductsDAO.newInstance().getProductByDesignationId(new Set<Id>{designationList[0].Id}, AccessLevel.USER_MODE);

            Test.startTest();
            // Call the method for getRecordIds
            String recordId = DynamicRecordEditFormCtrl.getRecordIds(designationList[0].Id, 'Product2');
            Test.stopTest();

            // Verify that the defualt value  is not null and has the expected value
            System.assertEquals(product2RecList[0].Id, recordId,'The recordId must be the same as the Product2Id');
            System.assertNotEquals(null, recordId, 'DynamicRecordEditFormCtrl getReocrdIds must have a return value');
        }
    }

    @isTest
    private static void getUiBehaviorTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            String stageNameVaue = 'Archived';
            String visibilityByParentFilter = 'Stage__c ' + ' = \'' + stageNameVaue + '\''; 
            
            //Create Donation Cause Record
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                10, 
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );
            designationList[0].Stage__c = stageNameVaue;
            DesignationsDAO.newInstance().insertRecords(designationList, false, AccessLevel.USER_MODE);
            
            //Build Map for Visibility by Parent
            Map<String, String> visibilityByParentParamMap = new Map<String, String>{
                'recordId' => designationList[0].Id,
                'parentRecord' => 'Designation__c',
                'visibilityByParent' => visibilityByParentFilter
            };

            String userRoleValue = 'Advancement_Operations_Manager';
            String visibilityByUserFilter = 'UserRole.DeveloperName ' + ' != \'' + userRoleValue + '\''; 

            //Build Map for Visibility by User
            Map<String, String> visibilityByUserParamMap = new Map<String, String>{
                'recordId' => TestDataFactoryUser.selectUserAdvancementManager.Id,
                'parentRecord' => 'User',
                'visibilityByUser' => visibilityByUserFilter
            };
            
            Test.startTest();
            Boolean visibilityByParent = DynamicRecordEditFormCtrl.getUiBehavior(visibilityByParentParamMap);
            Boolean visibilityByUser = DynamicRecordEditFormCtrl.getUiBehavior(visibilityByUserParamMap);
            Test.stopTest();

            System.assertEquals(false, visibilityByParent, 'Visibility by Parent should be false');
            System.assertEquals(false, visibilityByUser, 'Visibility by User should be false');
        }
    }

    @isTest
    private static void getContentBlockFilterTest (){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {

            //Create Test Data
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                10, 
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );
            DesignationsDAO.newInstance().insertRecords(designationList, false, AccessLevel.USER_MODE);

            List<Product2> productList = TestDataFactory.createTestProductRecords(10);
            Integer count = 0;

            for (Product2 prd : productList) {
                prd.Designation__c = designationList[0].Id;
                prd.Has_Detail_Page__c = true;
                count++;
            }
            DesignationsDAO.newInstance().insertRecords(productList, false, AccessLevel.USER_MODE);

            
            //Build Parameter Map 
            Map<String, String> contentBlockVisibilityParamMap = new Map<String, String>{
                'recordId' => productList[0].Id,
                'childRecord' => 'Product2',
                'contentBlockFilter' => 'Has_Detail_Page__c = true'
            };
            
            Test.startTest();
            Boolean contentBlockVisibility = DynamicRecordEditFormCtrl.getContentBlockFilter(contentBlockVisibilityParamMap);
            Test.stopTest();

            System.assertEquals(true, contentBlockVisibility, 'Content Visibility should be true');
        }
    }
}