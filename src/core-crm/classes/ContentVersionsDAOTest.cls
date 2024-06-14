/**
 * @description test class for ContentVersionsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                 |
      | carl.alvin.cabiles             | June 28, 2023         | DEPP-5388              | Added getContentVersionByTitle|

 */
@isTest
public with sharing class ContentVersionsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getContentVersionBySetContentDocumentIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<ContentVersion> contentVersionList = ContentVersionsDAO.newInstance()
                .getContentVersionBySetContentDocumentIds(new Set<Id>());
            System.assert(contentVersionList.isEmpty(), 'contentVersionList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContentVersionBySetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<ContentVersion> contentVersionList = ContentVersionsDAO.newInstance()
                .getContentVersionBySetIds(new Set<Id>());
            System.assert(contentVersionList.isEmpty(), 'contentVersionList should not be empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new ContentVersionsDAO().getSObjectType() == ContentVersion.SObjectType,
                'SObject is not ContentVersion'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getContentVersionByTitle() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<ContentVersion> contentVersionList = ContentVersionsDAO.newInstance()
                .getContentVersionByTitle(new Set<String>());
            System.assert(contentVersionList.isEmpty(), 'contentVersionList should not be empty');
        }
        Test.stopTest();
    }

}
