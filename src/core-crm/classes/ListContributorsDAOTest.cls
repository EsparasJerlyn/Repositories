/**
 * @description test class for RisksDAOTest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                  |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------------------------------------------|
 *    | ryan.j.a.dela.cruz             | August 08, 2023       | DEPP-6335              | Created file                                                                    |
 *    | nicole.genon                   | February 1, 2024      | DEPP-7003              | Added getListContributorByUserIDTest                                            |
 *    | kenneth.f.alsay                | February 14, 2024     | DEPP-8040              | Added method getAllListContributors. Added runAs to all methods for PMD Error.  |
 */
@isTest
public with sharing class ListContributorsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserCorporatePartnershipsManager();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager) {
            System.assert(ListContributorsDAO.newInstance() != null, 'ListContributorsDAO instance is null');
        }
        Test.stopTest(); 
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager) {
            System.assert(
                new ListContributorsDAO().getSObjectType() == List_Contributor__c.SObjectType,
                'SObject is not List_Contributor__c'
            );
        }
        Test.stopTest();
    }
    @isTest
    static void getListContributorByListID() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager) {
            List<List_Contributor__c> listContributors = ListContributorsDAO.newInstance()
                .getListContributorByListID(new Set<Id>(),AccessLevel.USER_MODE);
            System.assert(listContributors.isEmpty(), 'listContributors is not empty');
        }

        Test.stopTest();
    }
    @isTest
    static void getListContributorByUserIDTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager) {
            List<List_Contributor__c> listContributors = ListContributorsDAO.newInstance()
                .getListContributorByUserID(new Set<Id>(),new Set<Id>(),AccessLevel.USER_MODE);
            System.assert(listContributors.isEmpty(), 'listContributors is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordIdListContributorByListIDTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager) {
            List<List_Contributor__c> listContributors = ListContributorsDAO.newInstance()
                .getRecordIdListContributorByListID(new Set<Id>(),new Set<Id>(),AccessLevel.USER_MODE);
            System.assert(listContributors.isEmpty(), 'listContributors is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getAllListContributors() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager) {
            List<List_Contributor__c> listContributors = ListContributorsDAO.newInstance()
                .getAllListContributors(new Set<Id>(),AccessLevel.USER_MODE);
            System.assert(listContributors.isEmpty(), 'listContributors is not empty');
        }
        Test.stopTest();
    }
}
