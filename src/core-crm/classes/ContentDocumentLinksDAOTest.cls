/**
 * @description Test class for ContentDocumentLinksDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
private class ContentDocumentLinksDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void getContentDocLinksBySetLinkedEntityIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            MockIdGenerator builder = new MockIdGenerator(ContentDocumentLink.sObjectType);
            List<ContentDocumentLink> contentDocumentLinkList = ContentDocumentLinksDAO.newInstance()
                .getContentDocLinksBySetLinkedEntityIds(builder.getMockId());
            System.assert(
                contentDocumentLinkList.isEmpty(),
                'contentDocumentLinkList is not empty'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new ContentDocumentLinksDAO().getSObjectType() == ContentDocumentLink.SObjectType,
                'SObject is not ContentDocumentLink'
            );
        }
        Test.stopTest();
    }
}
