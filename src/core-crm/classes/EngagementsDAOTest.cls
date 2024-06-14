/**
 * @description test class for Engagementsdaotest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
      | alexnder.cadalin               |  May 17, 2023         | DEPP-5594              | added methods
 */
@isTest
public with sharing class EngagementsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(EngagementsDAO.newInstance() != null, 'Engagementsdao instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new EngagementsDAO().getSObjectType() == Engagement__c.SObjectType,
                'SObject is not Engagement__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsSortByEngagementCodeAscTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Engagement__c> engagementsList = EngagementsDAO.newInstance().getRecordsSortByEngagementCodeAsc();
            System.assert(engagementsList.isEmpty(), 'engagementsList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordsWithLikeEngagementCodeSortAscTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Engagement__c> engagementsList = EngagementsDAO.newInstance().getRecordsWithLikeEngagementCodeSortAsc('');
            System.assert(engagementsList.isEmpty(), 'engagementsList is not empty');
        }
        Test.stopTest();
    }
}
