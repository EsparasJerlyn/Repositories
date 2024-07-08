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
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Id expectedQueueId = GroupsDAO.newInstance()
            .getQueueByName(null);
            System.assertEquals(null,expectedQueueId,'expectedQueueId is not null');
        }
        Test.stopTest();
    }

    @isTest
    static void getQueueByNameTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            String queueName = GroupsDAO.STUDENT_RETENTION_QUEUE;
            Id expectedQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName WITH SYSTEM_MODE LIMIT 1]?.Id;
            Id actualQueueId = GroupsDAO.newInstance().getQueueByName(queueName);
            System.assertEquals(actualQueueId, expectedQueueId, 'expectedQueueId is not equals to actualQueueId');
        }
        Test.stopTest();
    }
}