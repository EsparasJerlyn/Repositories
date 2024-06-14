/**
 * @description Test class for IPManagementRelationshipsDAO.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | ryan.j.a.dela.cruz             | July 17, 2023         | DEPP-5468              | Created file                 |
 */
@isTest
public with sharing class IPManagementRelationshipsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserIndustryOperationsManager();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            System.assert(
                IPManagementRelationshipsDAO.newInstance() != null,
                'IPManagementRelationships instance is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryOperationsManager) {
            System.assert(
                new IPManagementRelationshipsDAO().getSObjectType() ==
                IP_Management_Relationship__c.SObjectType,
                'SObject is not IP Management'
            );
        }
        Test.stopTest();
    }
}
