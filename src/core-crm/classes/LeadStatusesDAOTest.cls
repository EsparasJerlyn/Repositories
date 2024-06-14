/**
 * @description test class for leadStatusesdaotest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 03, 2024          | n/a                    | Created file
 */
@isTest
public with sharing class LeadStatusesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(LeadStatusesDAO.newInstance() != null, 'leadStatusesdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new LeadStatusesDAO().getSObjectType() == LeadStatus.SObjectType,
                'SObject is not LeadStatus'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getConvertedLeadStatusTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            System.assert(LeadStatusesDAO.newInstance()
                .getConvertedLeadStatus(AccessLevel.USER_MODE) != null,
                'leadStatus must not be empty.'
            );
            Test.stopTest();
        }
    }
}
