/**
 * @description test class for  Distribution_Management_to_Designation_Stage_Update
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | April 15, 2024        | DEPP-8401              | Created file                 | 
 */

@isTest
private with sharing class DistributionMngmtToDesigationFlowTest {

    @testSetup
    static void setupDate() {
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
    private static void distributionManagementWithDesignationGivingToCauseTestOnCreate() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );

            for (Designation__c d : designationList) {
                d.Stage__c = DesignationsDAO.DC_ARCHIVED;
                d.Ready_For_Publishing__c = false;
                d.Activation_End_Date__c = System.Today() + 1;
            }

            DesignationsDAO.newInstance()
            .insertRecords(designationList, false, AccessLevel.USER_MODE);

            Test.startTest();
            List<Distribution_Management__c> distributionMgtList = TestDataFactory.createDistributionManagementRecords(
                100, 
                'Active');

            for(Integer i = 0; i<100; i++){
                distributionMgtList[i].Designation__c = designationList[i].Id;
            }
            DistributionManagementsDAO.newInstance().insertRecords(distributionMgtList, false, AccessLevel.USER_MODE);

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
    private static void distributionManagementWithDesignationEndowmentTestOnCreate() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.ENDOWNMENT_RECTYPE_ID
            );

            for (Designation__c d : designationList) {
                d.Stage__c = DesignationsDAO.DC_ARCHIVED;
                d.Ready_For_Publishing__c = false;
                d.Activation_End_Date__c = System.Today() + 1;
                d.Endowment_Account_Type__c = DesignationsDAO.ENDOWMENT_ACCOUNT_TYPE_PERPETUAL;
            }

            DesignationsDAO.newInstance()
            .insertRecords(designationList, false, AccessLevel.USER_MODE);

            Test.startTest();
            List<Distribution_Management__c> distributionMgtList = TestDataFactory.createDistributionManagementRecords(
                100, 
                'Active');

            for(Integer i = 0; i<100; i++){
                distributionMgtList[i].Designation__c = designationList[i].Id;
            }
            DistributionManagementsDAO.newInstance().insertRecords(distributionMgtList, false, AccessLevel.USER_MODE);

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
    private static void distributionManagementWithDesignationGivingToCauseTestOnUpdate() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );

            for (Designation__c d : designationList) {
                d.Stage__c = DesignationsDAO.DC_ARCHIVED;
                d.Ready_For_Publishing__c = false;
                d.Activation_End_Date__c = System.Today() + 1;
            }

            DesignationsDAO.newInstance()
            .insertRecords(designationList, false, AccessLevel.USER_MODE);

            List<Distribution_Management__c> distributionMgtList = TestDataFactory.createDistributionManagementRecords(
                100, 
                'Define'
            );

            for(Integer i = 0; i<100; i++){
                distributionMgtList[i].Designation__c = designationList[i].Id;
            }
            DistributionManagementsDAO.newInstance().insertRecords(distributionMgtList, false, AccessLevel.USER_MODE);


            Test.startTest();
            for(Distribution_Management__c dm : distributionMgtList){
                dm.Status__c = 'Active';
            }
            DistributionManagementsDAO.newInstance().updateRecords(distributionMgtList, false, AccessLevel.USER_MODE);

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
    private static void distributionManagementWithDesignationEndowmentTestOnUpdate() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.ENDOWNMENT_RECTYPE_ID
            );

            for (Designation__c d : designationList) {
                d.Stage__c = DesignationsDAO.DC_ARCHIVED;
                d.Ready_For_Publishing__c = false;
                d.Activation_End_Date__c = System.Today() + 1;
                d.Endowment_Account_Type__c = DesignationsDAO.ENDOWMENT_ACCOUNT_TYPE_PERPETUAL;
            }

            DesignationsDAO.newInstance()
            .insertRecords(designationList, false, AccessLevel.USER_MODE);

            List<Distribution_Management__c> distributionMgtList = TestDataFactory.createDistributionManagementRecords(
                100, 
                'Define'
            );

            for(Integer i = 0; i<100; i++){
                distributionMgtList[i].Designation__c = designationList[i].Id;
            }
            DistributionManagementsDAO.newInstance().insertRecords(distributionMgtList, false, AccessLevel.USER_MODE);


            Test.startTest();
            for(Distribution_Management__c dm : distributionMgtList){
                dm.Status__c = 'Active';
            }
            DistributionManagementsDAO.newInstance().updateRecords(distributionMgtList, false, AccessLevel.USER_MODE);

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


}