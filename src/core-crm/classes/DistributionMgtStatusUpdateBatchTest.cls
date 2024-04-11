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
 */
@isTest
public class DistributionMgtStatusUpdateBatchTest {
    @testSetup
    static void setupDate() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Advancement_Manager' });
        Test.stopTest();
    }
    
    @isTest
    private static void forInactiveBatchTest() {
        System.runAs(TestDataFactory.getAdvancementManager()) {
            //Create Designation with Giving to Cause record type
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(1);
            designationList[0].RecordTypeId = DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID;
            
            DesignationsDAO.newInstance().insertRecords(designationList, false, AccessLevel.USER_MODE);
            
            //Create Distribution Management record and link to created designation
            List<Distribution_Management__c> dmList = TestDataFactory.createDistributionManagementRecords(
                1, 'Active'
            );
            dmList[0].End_Date__c = System.Today();
            dmList[0].Designation__c = designationList[0].Id;
            
            DistributionManagementsDAO.newInstance().insertRecords(dmList, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            DistributionMgtStatusUpdateBatch batch = new DistributionMgtStatusUpdateBatch();
            Database.executeBatch(batch);
            Test.stopTest();

            System.assertEquals(
                DistributionManagementsDAO.DM_INACTIVE,
                DistributionManagementsDAO.newInstance()
                        .getDistributionManagementByDesignationId(new Set<Id>{ designationList[0].Id }, AccessLevel.SYSTEM_MODE)[0]
                    .Status__c,
                'Status should be inactive'
            );
        }
    }
}