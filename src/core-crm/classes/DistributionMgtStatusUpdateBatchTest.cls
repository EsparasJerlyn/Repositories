/**
 * @description test class for DistributionMgtStatusUpdateBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay      	       | April 11, 2024        | DEPP-8453              | Created file                 |
      | nicole.genon         	       | April 12, 2024        | DEPP-8452              | Added forActiveBatchTest     |
 */
@isTest
public class DistributionMgtStatusUpdateBatchTest {
    @testSetup
    static void setupDate() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
        Test.stopTest();
    }
    
    @isTest
    private static void forInactiveBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            //Create Designation with Giving to Cause record type
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(1, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);
            
            DesignationsDAO.newInstance().insertRecords(designationList, false, AccessLevel.USER_MODE);
            
            //Create Distribution Management record and link to created designation
            List<Distribution_Management__c> dmList = TestDataFactory.createDistributionManagementRecords(
                100, 'Active'
            );

            for(Distribution_Management__c dm : dmList){
                dm.End_Date__c = System.Today() - 1;
                dm.Designation__c = designationList[0].Id;
            }
            
            DistributionManagementsDAO.newInstance().insertRecords(dmList, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            DistributionMgtStatusUpdateBatch batch = new DistributionMgtStatusUpdateBatch();
            Database.executeBatch(batch);
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
                    'Status should be inactive'
                );
            }
        }
    }

    @isTest
    private static void forActiveBatchTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            //Create Designation with Giving to Cause record type
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(1, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);
            
            DesignationsDAO.newInstance().insertRecords(designationList, false, AccessLevel.USER_MODE);
            
            //Create Distribution Management record and link to created designation
            List<Distribution_Management__c> dmList = TestDataFactory.createDistributionManagementRecordsWithDesignation(
                100, designationList[0].Id
            );

            for(Distribution_Management__c dm : dmList){
                dm.Start_Date__c = System.Today() + 5;
                dm.End_Date__c = System.Today() + 6;
            }
            
            DistributionManagementsDAO.newInstance().insertRecords(dmList, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            DistributionMgtStatusUpdateBatch batch = new DistributionMgtStatusUpdateBatch();
            Database.executeBatch(batch);
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
                    'Status should be active'
                );
            }
        }
    }
}