/**
 * @description Test Class for GroupsDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | gabriel.p.ventayen             | May 9, 2024           | DEPP-8041              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
@isTest
public with sharing class GroupsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator', 'QUT_ESB'});
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new GroupsDAO().getSObjectType() == Group.SObjectType,
                'SObject is not Group'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getQueueByNameEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Id expectedQueueId = GroupsDAO.newInstance()
            .getQueueByName(null);
            System.assertEquals(null,expectedQueueId,'expectedQueueId is not null');
        }
        Test.stopTest();
    }

    @isTest
    static void getQueueByNameTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Id expectedQueueId = GroupsDAO.newInstance()
            .getQueueByName('Test');
            System.assertEquals(null,expectedQueueId,'expectedQueueId is not null');
        }
        Test.stopTest();
    }
}