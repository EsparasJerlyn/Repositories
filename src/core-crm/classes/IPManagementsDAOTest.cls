/**
 * @description Test class for IPManagementDAO.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | eugene.andrew.abuan            | July 12, 2023         | DEPP-5483              | Created file                 |
 */
@isTest
public with sharing class IPManagementsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'Industry_Operations_Manager' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getOperationsManager()) {
            System.assert(IPManagementsDAO.newInstance() != null, 'IPManagement instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getOperationsManager()) {
            System.assert(
                new IPManagementsDAO().getSObjectType() == IP_Management__c.SObjectType,
                'SObject is not IP Management'
            );
        }
        Test.stopTest();
    }
}
