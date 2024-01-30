/**
 * @description Test Class for List Member DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | September 14, 2023    | DEPP-6510              | Created file                 |
 */
@isTest
public with sharing class ListMembersDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager' });
    } 

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            System.assert(ListMembersDAO.newInstance() != null, 'ListMembersDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getexistingListMembersWithMatchingList() {
        Test.startTest();
            List<List_Member__c> listMemberRecords = ListMembersDAO.newInstance()
                .getexistingListMembersWithMatchingList(new Set<Id>(),new Set<Id>(),'SYSTEM_MODE');
            System.assert(listMemberRecords.isEmpty(), 'listMemberRecords is not empty');
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
            System.assert(
                new ListMembersDAO().getSObjectType() == List_Member__c.SObjectType,
                'SObject is not List_Member__c'
            );
        Test.stopTest();
    }
}