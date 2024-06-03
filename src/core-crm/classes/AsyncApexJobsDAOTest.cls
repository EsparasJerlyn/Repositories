/**
 * @description test class for AsyncApexJob
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 30, 2023        | DEPP-7984              | Created file
 */
@isTest
private class AsyncApexJobsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
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
