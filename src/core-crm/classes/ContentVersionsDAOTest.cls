/**
 * @description test class for ContentVersionsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
public with sharing class ContentVersionsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void getContentVersionBySetContentDocumentIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<ContentVersion> contentVersionList = ContentVersionsDAO.newInstance()
                .getContentVersionBySetContentDocumentIds(new Set<Id>());
            System.assert(contentVersionList.isEmpty(), 'contentVersionList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getContentVersionBySetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<ContentVersion> contentVersionList = ContentVersionsDAO.newInstance()
                .getContentVersionBySetIds(new Set<Id>());
            System.assert(contentVersionList.isEmpty(), 'contentVersionList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new ContentVersionsDAO().getSObjectType() == ContentVersion.SObjectType,
                'SObject is not ContentVersion'
            );
        }
        Test.stopTest();
    }
}
