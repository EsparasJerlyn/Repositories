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
        TestDataFactoryUser.generateUserIndustryOperationsManager();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            System.assert(IPManagementsDAO.newInstance() != null, 'IPManagement instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            System.assert(
                new IPManagementsDAO().getSObjectType() == IP_Management__c.SObjectType,
                'SObject is not IP Management'
            );
        }
        Test.stopTest();
    }
}
