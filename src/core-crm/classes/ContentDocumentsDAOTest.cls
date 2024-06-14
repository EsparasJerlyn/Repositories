/**
 * @description Interface for ContentDocument DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | June 28, 2023         | DEPP-5388              | Created file
 */
@isTest
private class ContentDocumentsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }
    @isTest
    static void getContentDocumentsByTitle() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<ContentDocument> contentDocumentList = ContentDocumentsDAO.newInstance()
                .getContentDocumentsByTitle('');
            System.assert(contentDocumentList.isEmpty(), 'contentDocumentList is not empty');
        }
        Test.stopTest();
    }
}
