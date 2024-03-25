/**
 * @description test class for DesignationStageUpdateBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | March 15, 2024        | DEPP-8210              | Created file                 |
      | eugene.andrew.abuan            | March 18, 2024        | DEPP-8211              | Added Active Stage           |         

 */
@isTest
private class DesignationStageUpdateBatchTest {
    @testSetup
    static void setupDate() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Sys_Admin','QUT_IE_Partnership_Manager' });
        Test.stopTest();
    }

    @isTest
    private static void forPublishedBatchTest() {
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                1
            );

            designationList[0].Ready_For_Publishing__c = true;
            designationList[0].QUT_Giving_Publish_Start_Date__c = System.Today();
            designationList[0].QUT_Giving_Publish_End_Date__c = System.Today() + 1;

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
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                1
            );
            designationList[0].QUT_Giving_Publish_Start_Date__c = System.Today() + 1;
            designationList[0].Ready_For_Publishing__c = true;
            designationList[0].QUT_Giving_Publish_End_Date__c = System.Today();
            designationList[0].Activation_End_Date__c = System.Today() + 1;

            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);

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

}