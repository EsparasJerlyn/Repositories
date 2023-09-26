/**
 * @description test class for PricebookEntriesdao.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                        |
 */
@isTest
private class PricebookEntriesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
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
        System.runAs(TestDataFactory.getProgramAdminUser()) {
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
}
