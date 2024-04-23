/**
 * @description test class for ContextualRolesDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                 |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------------------------------|
 *    | ryan.j.a.dela.cruz             | June 19, 2023         | DEPP-5748              | Created file                                                   |
 *    | ryan.j.a.dela.cruz             | July 19, 2023         | DEPP-5457/DEPP-5468    | Added getActiveOpportunityContextualRolesRecordsTest method    |
 */
@isTest
private class ContextualRolesDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserIndustryPartnershipManager();

    }

    @isTest 
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            System.assert(
                ContextualRolesDAO.newInstance() != null,
                'ContextualRolesDAO instance is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            System.assert(
                new ContextualRolesDAO().getSObjectType() == Contextual_Role__c.SObjectType,
                'SObject is not Contextual_Role__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getActiveOpportunityContextualRolesRecordsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Contextual_Role__c> contextualRoles = ContextualRolesDAO.newInstance().getActiveOpportunityContextualRolesRecords(new Set<Id>(), new List<String>());
            System.assert(contextualRoles != null, 'Contextual Roles not found');
        }
        Test.stopTest();
    }
    
    @isTest
    static void getActiveContextualRoleByContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Contextual_Role__c> contextualRoles = ContextualRolesDAO.newInstance().getActiveContextualRoleByContactIds(new Set<Id>(), new Set<String>(),'SYSTEM_MODE');
            System.assert(contextualRoles != null, 'Contextual Roles not found');
        }
        Test.stopTest();
    }
}
