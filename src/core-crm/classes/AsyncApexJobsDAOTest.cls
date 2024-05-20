/**
 * @description test class for AsyncApexJob
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 30, 2023        | DEPP-7984              | Created file                 |
      | arsenio.jr.dayrit              | May 13, 2024          | DEPP-8743              | Added test methods           |
 */
@isTest
private class AsyncApexJobsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator', 'QUT_ESB'});
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(AsyncApexJobsDAO.newInstance() != null, 'AsyncApexJobsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(
                new AsyncApexJobsDAO().getSObjectType() == AsyncApexJob.SObjectType,
                'SObject is not AsyncApexJob'
                );
        }
        Test.stopTest();
    }

    @isTest
    static void findAsyncApexJobByIdEmptTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            AsyncApexJob asyncApexJob = AsyncApexJobsDAO.newInstance()
            .findAsyncApexJobById(null, AccessLevel.SYSTEM_MODE);
            System.assertEquals(null,asyncApexJob,'asyncApexJob is not null');
        }
        Test.stopTest();
    }
    @isTest
    static void findAsyncApexJobByIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            AssetToCompleteBatch batch = new AssetToCompleteBatch();
            Database.executeBatch(batch);

            List<AsyncApexJob> asyncApex = [SELECT Id,ApexClass.Name  FROM AsyncApexJob WHERE ApexClass.Name =: 'AssetToCompleteBatch' LIMIT 1];

            AsyncApexJob asyncApexJob = AsyncApexJobsDAO.newInstance()
            .findAsyncApexJobById(asyncApex[0].Id, AccessLevel.SYSTEM_MODE);
            System.assertEquals(asyncApex[0].ApexClass.Name,asyncApexJob.ApexClass.Name,'asyncApexJob does not match');
        }
        Test.stopTest();
    }

	@isTest
	static void getRunningJobsByNameAndIdExemptionTest(){
		Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(
                AsyncApexJobsDAO.newInstance().getRunningJobsByNameAndIdExemption(
					new Set<String>{'TestBatch'},
					new Set<Id>(),
					AccessLevel.SYSTEM_MODE
				).isEmpty(),
				'return should be empty'
            );
        }
        Test.stopTest();
	}

	@isTest
	static void getRunningJobsByNameAndIdExemptionTestEmpty(){
		Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            System.assert(
                AsyncApexJobsDAO.newInstance().getRunningJobsByNameAndIdExemption(
					new Set<String>(),
					new Set<Id>(),
					AccessLevel.SYSTEM_MODE
				).isEmpty(),
				'return should be empty'
            );
        }
        Test.stopTest();
	}
}
