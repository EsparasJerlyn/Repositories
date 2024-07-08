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
      | eugene.andrew.abuan            | May 22, 2024          | DEPP-8822              | Added test for Apex Name     |
 */
@isTest
private class AsyncApexJobsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(AsyncApexJobsDAO.newInstance() != null, 'AsyncApexJobsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            AsyncApexJob asyncApexJob = AsyncApexJobsDAO.newInstance()
            .findAsyncApexJobById(null, AccessLevel.SYSTEM_MODE);
            System.assertEquals(null,asyncApexJob,'asyncApexJob is not null');
        }
        Test.stopTest();
    }

    @isTest
    static void findAsyncApexJobByIdTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

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
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
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
    
    @isTest
    static void findAsyncApexJobByApexNameTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            QualtricsSurveyCalloutQueuable executeQueueable = new QualtricsSurveyCalloutQueuable(new List<Qualtrics_Survey__c>() , 'checkInProgressSurveyURL');
            System.enqueueJob(executeQueueable);

            AsyncApexJob asyncApexJob = AsyncApexJobsDAO.newInstance().findAsyncApexJobByApexName('QualtricsSurveyCalloutQueuable', AccessLevel.SYSTEM_MODE);
            System.assertEquals('QualtricsSurveyCalloutQueuable', asyncApexJob.ApexClass.Name,'asyncApexJob does not match');
        }
        Test.stopTest();
    }

    @isTest
    static void findAsyncApexJobByApexNameEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            AsyncApexJob asyncApexJob = AsyncApexJobsDAO.newInstance().findAsyncApexJobByApexName('test', AccessLevel.SYSTEM_MODE);
            System.assertEquals(null , asyncApexJob,'Async Job Should be null');
        }
        Test.stopTest();
    }
}
