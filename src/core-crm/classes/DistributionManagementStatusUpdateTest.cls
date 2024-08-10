/**
 * @description test class for Distribution_Management_Status_Update Flow
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                        |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------------------------------|
      | nicole.genon                   | April 11, 2024        | DEPP-8452              | Created file                                                          |
      | kenneth.f.alsay                | April 12, 2024        | DEPP-8453              | Added forInactiveStatusOnCreateTest                                   |
      |                                                                                 | Added forInactiveStatusOnUpdateTest                                   |
      | kenneth.f.alsay                | April 22, 2024        | DEPP-8392              | CI Error Fix after query updates on                                   |
      |                                |                       |                        | DistributionManagementsDAO.getDistributionManagementByDesignationId   |
 */
@isTest
private class DistributionManagementStatusUpdateTest {
    @testSetup
    static void setupData() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
        Test.stopTest();

        Designation_Code_Auto_Number__c designationCodeAutoNum = DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();

        designationCodeAutoNum.Giving_To_Cause__c = 1;
        DesignationCodeAutoNumbersDAO.newInstance().upsertRecords(
        new List<Designation_Code_Auto_Number__c>{designationCodeAutoNum},
        false,AccessLevel.USER_MODE);
        
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(1, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);

            DesignationsDAO.newInstance()
                    .insertRecords(designationList, false, AccessLevel.USER_MODE);      
        }
    }

    @isTest
    private static void forActiveStatusOnCreateTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = DesignationsDAO.newInstance()
            .getDesignationsByNameStart('Test Designation', AccessLevel.USER_MODE);
            List<Distribution_Management__c> dMList = TestDataFactory.createDistributionManagementRecordsWithDesignation(
                100, designationList[0].Id);

            Test.startTest();
            
            DistributionManagementsDAO.newInstance()
                .insertRecords(dMList, false, AccessLevel.USER_MODE);

            Test.stopTest();

            for (
                Distribution_Management__c dm : DistributionManagementsDAO.newInstance()
                    .getDistributionManagementByDesignationId(
                        new Set<Id>{designationList[0].Id},
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    DistributionManagementsDAO.DM_ACTIVE,
                    dm.Status__c,
                    'Stage should be active'
                );
            }
        }
    }

    @isTest
    private static void forActiveStatusOnUpdateTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = DesignationsDAO.newInstance()
            .getDesignationsByNameStart('Test Designation', AccessLevel.USER_MODE);
            List<Distribution_Management__c> newDmList = TestDataFactory.createDistributionManagementRecordsWithDesignation(
                100, designationList[0].Id);
            
            for(Distribution_Management__c rec : newDmList){
                rec.Start_Date__c = System.today() + 1;
            }

            DistributionManagementsDAO.newInstance()
                .insertRecords(newDmList, false, AccessLevel.USER_MODE);
            
            List<Distribution_Management__c> getDMList = DistributionManagementsDAO.newInstance().getDistributionManagementByDesignationId(new Set<Id>{designationList[0].Id},AccessLevel.USER_MODE);
            List<Distribution_Management__c> dMList = new List<Distribution_Management__c>();
            
            for(Distribution_Management__c dm : getDMList){
                dMList.add(new Distribution_Management__c (
                	Id = dm.Id,
                    Start_Date__c = dm.Start_Date__c,
                    End_Date__c = dm.End_Date__c,
                    Status__c = dm.Status__c
                ));
            }

            for(Distribution_Management__c rec : dMList){
                rec.Start_Date__c = System.today();
            }

            Test.startTest();
            
            DistributionManagementsDAO.newInstance()
                .updateRecords(dMList, false, AccessLevel.USER_MODE);

            Test.stopTest();

            for (
                Distribution_Management__c dm : DistributionManagementsDAO.newInstance()
                    .getDistributionManagementsBySetRecordIds(
                        (new Map<Id, Distribution_Management__c>(dMList)).keySet(),
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    DistributionManagementsDAO.DM_ACTIVE,
                    dm.Status__c,
                    'Stage should be active'
                );
            }       
        }
    }
    
    @isTest
    private static void forInactiveStatusOnCreateTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = DesignationsDAO.newInstance()
            .getDesignationsByNameStart('Test Designation', AccessLevel.USER_MODE);
            List<Distribution_Management__c> dMList = TestDataFactory.createDistributionManagementRecordsWithDesignation(100, designationList[0].Id);
            for(Distribution_Management__c dm : dMList){
                dm.End_Date__c = System.Today();
                dm.Status__c = 'Active';
            }

            Test.startTest();
            
            DistributionManagementsDAO.newInstance()
                .insertRecords(dMList, false, AccessLevel.USER_MODE);

            Test.stopTest();

            for (
                Distribution_Management__c dm : DistributionManagementsDAO.newInstance()
                    .getDistributionManagementByDesignationId(
                        new Set<Id>{designationList[0].Id},
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    DistributionManagementsDAO.DM_INACTIVE,
                    dm.Status__c,
                    'Stage should be Inactive'
                );
            }
        }
    }
    
    @isTest
    private static void forInactiveStatusOnUpdateTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = DesignationsDAO.newInstance()
            .getDesignationsByNameStart('Test Designation', AccessLevel.USER_MODE);
            List<Distribution_Management__c> dMList = TestDataFactory.createDistributionManagementRecordsWithDesignation(1, designationList[0].Id);
            
            DistributionManagementsDAO.newInstance()
                .insertRecords(dMList, false, AccessLevel.USER_MODE);

            List<Distribution_Management__c> getDMList = DistributionManagementsDAO.newInstance().getDistributionManagementByDesignationId(new Set<Id>{designationList[0].Id},AccessLevel.USER_MODE);
            List<Distribution_Management__c> dMListToUpdate = new List<Distribution_Management__c>();
            
            for(Distribution_Management__c dm : getDMList){
                dmListToUpdate.add(new Distribution_Management__c (
                	Id = dm.Id,
                    Start_Date__c = dm.Start_Date__c,
                    End_Date__c = dm.End_Date__c,
                    Status__c = dm.Status__c
                ));
            }
            
            for(Distribution_Management__c rec : dMListToUpdate){
                rec.Status__c = 'Active';
                rec.End_Date__c = System.Today();
            }
            
            Test.startTest();
            
            DistributionManagementsDAO.newInstance()
                .updateRecords(dMListToUpdate, false, AccessLevel.USER_MODE);

            Test.stopTest();
            
            for (
                Distribution_Management__c dm : DistributionManagementsDAO.newInstance()
                    .getDistributionManagementByDesignationId(
                        new Set<Id>{designationList[0].Id},
                        AccessLevel.USER_MODE
                    )
            ) {
                System.assertEquals(
                    DistributionManagementsDAO.DM_INACTIVE,
                    dm.Status__c,
                    'Stage should be Inactive'
                );
            }
        }
    }
}