/**
 * @description Test Class OpportunityContactRolesDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | mark.j.mahilum                 | Aug  31, 2023         | DEPP-6565              | Created File                               |
 */
@isTest
public with sharing class OpportunityContactRolesDAOTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new OpportunityContactRolesDAO().getSObjectType() == OpportunityContactRole.SObjectType,
                'SObject is not OpportunityContactRole'
            );
        }
        Test.stopTest();
    }
    
    @isTest
    static void getOpportunityContactRoleByRoleContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<OpportunityContactRole> ocrList = OpportunityContactRolesDAO.newInstance()
                .getOpportunityContactRoleByRoleContactIds(
                    new Set<Id>(),
                    new Set<String>(),
                    'SYSTEM_MODE'
                );
            System.assert(ocrList.isEmpty(), 'applicationList should not be empty.');
        }
        Test.stopTest();
    }
}