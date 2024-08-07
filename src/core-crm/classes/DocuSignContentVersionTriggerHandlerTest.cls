/**
 * @description Tests Class for DocuSignContentVersionTriggerHandler
 * @see DocuSignContentVersionTriggerHandlerTest
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email               | Date                  | JIRA                   | Change Summary               |
 *    |-------------------------------|-----------------------|------------------------|------------------------------|
 *    | arsenio.dayrit@qut.edu.au     | November 11, 2021     | DEPP-503               | Created file                 |
 */
@isTest
public class DocuSignContentVersionTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void insertContentVersion() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<ContentVersion> contentVersionRecords = TestDataFactory.createTestContentVersionRecords(
                1
            );
            Test.startTest();
            ContentVersionsDAO.newInstance()
                .insertRecords(contentVersionRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();

            List<ContentVersion> contentVersions = [SELECT Id, Title FROM ContentVersion LIMIT 1];
            for (ContentVersion checkContentVersion : contentVersions) {
                System.assertEquals(
                    80,
                    checkContentVersion.Title.length(),
                    'Content version title length should match.'
                );
            }
        }

    }

    @isTest
    private static void updatetContentVersion() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<ContentVersion> contentVersionRecords = TestDataFactory.createTestContentVersionRecords(
                1
            );
            ContentVersionsDAO.newInstance()
                .insertRecords(contentVersionRecords, false, AccessLevel.USER_MODE);

            Test.startTest();
            List<ContentVersion> updateContentVersions = new List<ContentVersion>();
            List<ContentVersion> contentVersions = [SELECT Id, Title FROM ContentVersion LIMIT 1];
            for (ContentVersion contentVersionUpdate : contentVersions) {
                contentVersionUpdate.Title = 'Proposal - General With Content_ALPHA ZENITH PTY LTD-test sample sample opportunity that may e123123123samplesample';
                updateContentVersions.add(contentVersionUpdate);
            }
            ContentVersionsDAO.newInstance()
                .updateRecords(updateContentVersions, false, AccessLevel.USER_MODE);
            Test.stopTest();
        }

        List<ContentVersion> getContentVersions = [SELECT Id, Title FROM ContentVersion LIMIT 1];
        for (ContentVersion checkContentVersion : getContentVersions) {
            System.assertEquals(
                80,
                checkContentVersion.Title.length(),
                'Content version title length should match.'
            );
        }
    }
}
