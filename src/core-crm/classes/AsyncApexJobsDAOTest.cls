/**
 * @description Test Class for AsyncApexJobsDAO
 *
 * @author Accenture
 *
  * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | arsenio.jr.dayrit              | May 13, 2024          | DEPP-8743              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
@isTest
public with sharing class AsyncApexJobsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator', 'QUT_ESB'});
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new AsyncApexJobsDAO().getSObjectType() == AsyncApexJob.SObjectType,
                'SObject is not Async Apex Job'
            );
        }
        Test.stopTest();
    }
    @isTest
    static void findByIdEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            AsyncApexJob asyncApexJob = AsyncApexJobsDAO.newInstance()
            .findById(null, AccessLevel.SYSTEM_MODE);
            System.assertEquals(null,asyncApexJob,'asyncApexJob is not null');
        }
        Test.stopTest();
    }
    @isTest
    static void findByIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            MockIdGenerator mockIdGen = new MockIdGenerator(AsyncApexJob.SObjectType);
            AsyncApexJob asyncApexJob = AsyncApexJobsDAO.newInstance()
            .findById(mockIdGen.getMockId(), AccessLevel.SYSTEM_MODE);
            System.assertEquals(null,asyncApexJob,'asyncApexJob is not null');
        }
        Test.stopTest();
    }
}