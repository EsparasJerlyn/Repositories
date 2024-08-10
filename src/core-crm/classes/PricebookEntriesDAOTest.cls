/**
 * @description test class for PricebookEntriesDAO.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                    |
 *    |--------------------------------|-----------------------|------------------------|-----------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                      |
 */
@isTest
private class PricebookEntriesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new PricebookEntriesDAO().getSObjectType() == PricebookEntry.SObjectType,
                'SObject is not PricebookEntry'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getPricebookEntriesByRecordIdsAndPricebookNamesTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<PricebookEntry> pricebookEntryList = PricebookEntriesDAO.newInstance()
                .getPricebookEntriesByRecordIdsAndPricebookNames(
                    new Set<String>(),
                    new Set<String>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(pricebookEntryList.isEmpty(), 'pricebookEntryList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getPricebookEntriesByIdsTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            MockIdGenerator mockPbEntry = new MockIdGenerator(PricebookEntry.SObjectType);
            List<PricebookEntry> pbEntries = PricebookEntriesDAO.newInstance().getPricebookEntriesByIds(
                new Set<Id>{mockPbEntry.getMockId()},
                AccessLevel.USER_MODE
            );
            System.assert(pbEntries.isEmpty(), 'pricebookEntries is not empty');
            Test.stopTest();
        }
    }

    @isTest
    static void getPricebookEntriesByIdsEmptyTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            List<PricebookEntry> pbEntries = PricebookEntriesDAO.newInstance().getPricebookEntriesByIds(
                new Set<Id>(),
                AccessLevel.USER_MODE
            );
            System.assert(pbEntries.isEmpty(), 'pricebookEntries is not empty');
            Test.stopTest();
        }
    }
}
