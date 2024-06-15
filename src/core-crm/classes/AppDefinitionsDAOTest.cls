/**
 * @description Test Class for AppDefinitionsDAO Object. 
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 13, 2023         | DEPP-5391              | Created file
 */
@isTest
private class AppDefinitionsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                AppDefinitionsDAO.newInstance() != null,
                'AppDefinitionsDAO instance is null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                new AppDefinitionsDAO().getSObjectType() == AppDefinition.SObjectType,
                'SObject is not AppDefinitionsDAO'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getAppDefinitionRecordsByDurableIdSetTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<AppDefinition> appDefinitionList = AppDefinitionsDAO.newInstance()
                .getAppDefinitionRecordsByDurableIdSet(new Set<String>{});
            System.assert(appDefinitionList.isEmpty(), 'AppDefinitionList is not empty');
        }
        Test.stopTest();
    }
}
