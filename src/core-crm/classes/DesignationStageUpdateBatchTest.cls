/**
 * @description test class for DesignationStageUpdateBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
      | roy.nino.s.regala              | March 15, 2024        | DEPP-8210              | Created file                                    |
      | eugene.andrew.abuan            | March 18, 2024        | DEPP-8211              | Added Active Stage                              |
      | nicole.genon                   | March 20, 2024        | DEPP-8212              | Added Archived Stage                            |
      | kenneth.f.alsay                | April 1, 2024         | DEPP-8209              | Added field values to pass new validation rules |

 */
@isTest
private class DesignationStageUpdateBatchTest {
    @testSetup
    static void setupDate() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Advancement_Manager' });
        Test.stopTest();
    }

    @isTest
    private static void forPublishedBatchTest() {
        System.runAs(TestDataFactory.getAdvancementManager()) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                1
            );

            designationList[0].Ready_For_Publishing__c = true;
            designationList[0].Public_Giving_Publish_Start_Date__c = System.Today();
            designationList[0].Public_Giving_Publish_End_Date__c = System.Today() + 1;
            designationList[0].QA_Completed__c = true;

            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);

            Test.startTest();
            DesignationStageUpdateBatch batch = new DesignationStageUpdateBatch();
            Database.executeBatch(batch);
            Test.stopTest();

            System.assertEquals(
                DesignationsDAO.DC_PUBLISHED,
                DesignationsDAO.newInstance()
                        .getDesignationsBySetRecordIds(new Set<Id>{ designationList[0].Id }, AccessLevel.SYSTEM_MODE)[0]
                    .Stage__c,
                'Stage should be published'
            );
        }
    }

    @isTest
    private static void forActiveBatchTest() {
        System.runAs(TestDataFactory.getAdvancementManager()) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                1
            );
            designationList[0].Public_Giving_Publish_Start_Date__c = System.Today() + 1;
            designationList[0].Ready_For_Publishing__c = true;
            designationList[0].Public_Giving_Publish_End_Date__c = System.Today();
            designationList[0].Activation_End_Date__c = System.Today() + 1;
            designationList[0].QA_Completed__c = true;

            DesignationsDAO.newInstance()
                .insertRecords(designationList, true, AccessLevel.USER_MODE);

            designationList[0].Stage__c = null;

            DesignationsDAO.newInstance()
                .updateRecords(designationList, true, AccessLevel.USER_MODE);

            Test.startTest();
            DesignationStageUpdateBatch batch = new DesignationStageUpdateBatch();
            Database.executeBatch(batch);
            Test.stopTest();

            System.assertEquals(
                DesignationsDAO.DC_ACTIVE,
                DesignationsDAO.newInstance()
                        .getDesignationsBySetRecordIds(new Set<Id>{ designationList[0].Id }, AccessLevel.SYSTEM_MODE)[0]
                    .Stage__c,
                'Stage should be Active'
            );
        }
    }

    @isTest
    private static void forArchivedBatchTest() {
        System.runAs(TestDataFactory.getAdvancementManager()) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                1
            );
            designationList[0].Activation_Start_Date__c = System.Today() - 4;
            designationList[0].Archived_Date__c = System.Today() - 1;
            designationList[0].Archived_Comment__c = 'Test';
            designationList[0].Archived_Reason__c = 'Other';
            designationList[0].Activation_End_Date__c = System.Today() - 1;

            DesignationsDAO.newInstance()
                .insertRecords(designationList, true, AccessLevel.USER_MODE);

            Test.startTest();
            DesignationStageUpdateBatch batch = new DesignationStageUpdateBatch();
            Database.executeBatch(batch);
            Test.stopTest();

            System.assertEquals(
                DesignationsDAO.DC_ARCHIVED,
                DesignationsDAO.newInstance()
                        .getDesignationsBySetRecordIds(new Set<Id>{ designationList[0].Id }, AccessLevel.SYSTEM_MODE)[0]
                    .Stage__c,
                'Stage should be archived'
            );
        }
    }

}