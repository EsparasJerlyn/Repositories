/**
 * @description test class for Designation_Stage_Update Flow
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
      | eugene.andrew.abuan            | April 10, 2024        | DEPP-8390              | Added Define Stage                              |

 */
@isTest
private class Designation_Stage_Update_Test {
    @testSetup
    static void setupData() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();

        Designation_Code_Auto_Number__c designationCodeAutoNum = DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        designationCodeAutoNum.Giving_To_Cause__c = 1;
        DesignationCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Designation_Code_Auto_Number__c>{designationCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
        );

        Test.stopTest();
    }

    @isTest
    private static void forPublishedBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );

            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);

            List<Distribution_Management__c> distributionMgtList = TestDataFactory.createDistributionManagementRecords(100, 'Active');
            for(Integer i = 0; i<100; i++){
                distributionMgtList[i].Designation__c = designationList[i].Id;
            }
            DistributionManagementsDAO.newInstance().insertRecords(distributionMgtList, false, AccessLevel.USER_MODE);
            
            List<Product2> products = ProductsDAO.newInstance().getProductByDesignationId(
                new Map<Id,SObject>(designationList).keySet(), 
                AccessLevel.USER_MODE
            );

            for(Product2 product : products){
                product.Description__c = 'test';
                product.Title_Image_URL__c = 'test.com';
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
                Designation__c d : DesignationsDAO.newInstance()
                    .getDesignationsBySetRecordIds(
                        (new Map<Id, Designation__c>(designationList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    DesignationsDAO.DC_PUBLISHED,
                    d.Stage__c,
                    'Stage should be published'
                );
            }
        }
    }
    
    @isTest
    private static void forNotPublishedBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );

            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);

            for (Designation__c d : designationList) {
                d.Stage__c = DesignationsDAO.DC_ARCHIVED;
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
                Designation__c d : DesignationsDAO.newInstance()
                    .getDesignationsBySetRecordIds(
                        (new Map<Id, Designation__c>(designationList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertNotEquals(
                    DesignationsDAO.DC_PUBLISHED,
                    d.Stage__c,
                    'Stage should be published'
                );
            }
        }
    }

    @isTest
    private static void forActiveBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );

            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);

            for (Designation__c d : designationList) {
                d.Ready_For_Publishing__c = false;
                d.Activation_End_Date__c = System.Today() + 1;
            }

            Test.startTest();
            DesignationsDAO.newInstance()
                .updateRecords(designationList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Designation__c d : DesignationsDAO.newInstance()
                    .getDesignationsBySetRecordIds(
                        (new Map<Id, Designation__c>(designationList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    DesignationsDAO.DC_ACTIVE,
                    d.Stage__c,
                    'Stage should be Active'
                );
            }
        }
    }

    @isTest
    private static void forNotActiveBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );

            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);

            for (Designation__c d : designationList) {
                d.Stage__c = DesignationsDAO.DC_ARCHIVED;
                d.Ready_For_Publishing__c = false;
                d.Activation_End_Date__c = System.Today() + 1;
            }

            Test.startTest();
            DesignationsDAO.newInstance()
                .updateRecords(designationList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Designation__c d : DesignationsDAO.newInstance()
                    .getDesignationsBySetRecordIds(
                        (new Map<Id, Designation__c>(designationList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertNotEquals(
                    DesignationsDAO.DC_ACTIVE,
                    d.Stage__c,
                    'Stage should not be Active'
                );
            }
        }
    }

    @isTest
    private static void forArchivedBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );

            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);

            for (Designation__c d : designationList) {
                d.Archived_Date__c = System.Today();
                d.Archived_Comment__c = 'Test Archived';
                d.Archived_Reason__c = 'Other';
            }

            Test.startTest();
            DesignationsDAO.newInstance()
                .updateRecords(designationList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Designation__c d : DesignationsDAO.newInstance()
                    .getDesignationsBySetRecordIds(
                        (new Map<Id, Designation__c>(designationList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    DesignationsDAO.DC_ARCHIVED,
                    d.Stage__c,
                    'Stage should be archived'
                );
            }
        }
    }

    @isTest
    private static void forDefineTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );

            for (Designation__c d : designationList) {
                d.Activation_Start_Date__c = System.Today() + 1;
            }

            Test.startTest();
            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Designation__c d : DesignationsDAO.newInstance()
                    .getDesignationsBySetRecordIds(
                        (new Map<Id, Designation__c>(designationList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    DesignationsDAO.DC_DEFINE,
                    d.Stage__c,
                    'Stage should be Define'
                );
            }
        }
    }

    @isTest
    private static void forNotDefineTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );

            for (Designation__c d : designationList) {
                d.Stage__c = 'Active';
            }

            Test.startTest();
            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Designation__c d : DesignationsDAO.newInstance()
                    .getDesignationsBySetRecordIds(
                        (new Map<Id, Designation__c>(designationList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertNotEquals(
                    DesignationsDAO.DC_DEFINE,
                    d.Stage__c,
                    'Stage should not be Define'
                );
            }
        }
    }
}