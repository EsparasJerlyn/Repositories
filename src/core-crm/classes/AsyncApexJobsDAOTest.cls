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
    static void findasyncApexJobByIdEmptTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            AsyncApexJob asyncApexJob = AsyncApexJobsDAO.newInstance()
            .findasyncApexJobById(null, AccessLevel.SYSTEM_MODE);
            System.assertEquals(null,asyncApexJob,'asyncApexJob is not null');
        }
        Test.stopTest();
    }
    @isTest
    static void findasyncApexJobByIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

            AssetToCompleteBatch batch = new AssetToCompleteBatch();
            Database.executeBatch(batch);

            List<AsyncApexJob> asyncApex = [SELECT Id,ApexClass.Name  FROM AsyncApexJob WHERE ApexClass.Name =: 'AssetToCompleteBatch' LIMIT 1];

            AsyncApexJob asyncApexJob = AsyncApexJobsDAO.newInstance()
            .findasyncApexJobById(asyncApex[0].Id, AccessLevel.SYSTEM_MODE);
            System.assertEquals(asyncApex[0].ApexClass.Name,asyncApexJob.ApexClass.Name,'asyncApexJob is not null');
        }
        Test.stopTest();
    }
}