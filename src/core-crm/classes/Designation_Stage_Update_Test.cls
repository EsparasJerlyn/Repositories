/**
 * @description test class for Designation_Stage_Update Flow
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | March 15, 2024        | DEPP-8210              | Created file                 |
      | eugene.andrew.abuan            | March 19, 2024        | DEPP-8211              | Added Active Stage           | 

 */
@isTest
private class Designation_Stage_Update_Test {
    @testSetup
    static void setupData() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Donor_Engagement_Manager' });
        Test.stopTest();
    }

    @isTest
    private static void forPublishedBatchTest() {
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100
            );

            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);

            for (Designation__c dc : designationList) {
                dc.Ready_For_Publishing__c = true;
                dc.Public_Giving_Publish_Start_Date__c = System.Today();
                dc.Public_Giving_Publish_End_Date__c = System.Today() + 1;
            }

            Test.startTest();
            DesignationsDAO.newInstance()
                .updateRecords(designationList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Designation__c dc : DesignationsDAO.newInstance()
                    .getDesignationsBySetRecordIds(
                        (new Map<Id, Designation__c>(designationList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    DesignationsDAO.DC_PUBLISHED,
                    dc.Stage__c,
                    'Stage should be published'
                );
            }
        }
    }

    @isTest
    private static void forNotPublishedBatchTest() {
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100
            );

            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);

            for (Designation__c dc : designationList) {
                dc.Stage__c = DesignationsDAO.DC_ARCHIVED;
                dc.Ready_For_Publishing__c = true;
                dc.Public_Giving_Publish_Start_Date__c = System.Today();
                dc.Public_Giving_Publish_End_Date__c = System.Today() + 1;
            }

            Test.startTest();
            DesignationsDAO.newInstance()
                .updateRecords(designationList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Designation__c dc : DesignationsDAO.newInstance()
                    .getDesignationsBySetRecordIds(
                        (new Map<Id, Designation__c>(designationList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertNotEquals(
                    DesignationsDAO.DC_PUBLISHED,
                    dc.Stage__c,
                    'Stage should be published'
                );
            }
        }
    }

    @isTest
    private static void forActiveBatchTest() {
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100
            );

            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);

            for (Designation__c dc : designationList) {
                dc.Ready_For_Publishing__c = false;
                dc.Activation_End_Date__c = System.Today() + 1;
            }

            Test.startTest();
            DesignationsDAO.newInstance()
                .updateRecords(designationList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Designation__c dc : DesignationsDAO.newInstance()
                    .getDesignationsBySetRecordIds(
                        (new Map<Id, Designation__c>(designationList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    DesignationsDAO.DC_ACTIVE,
                    dc.Stage__c,
                    'Stage should be Active'
                );
            }
        }
    }

    @isTest
    private static void forNotActiveBatchTest() {
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100
            );

            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);

            for (Designation__c dc : designationList) {
                dc.Stage__c = DesignationsDAO.DC_ARCHIVED;
                dc.Ready_For_Publishing__c = false;
                dc.Activation_End_Date__c = System.Today() + 1;
            }

            Test.startTest();
            DesignationsDAO.newInstance()
                .updateRecords(designationList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (
                Designation__c dc : DesignationsDAO.newInstance()
                    .getDesignationsBySetRecordIds(
                        (new Map<Id, Designation__c>(designationList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertNotEquals(
                    DesignationsDAO.DC_ACTIVE,
                    dc.Stage__c,
                    'Stage should not be Active'
                );
            }
        }
    }
}