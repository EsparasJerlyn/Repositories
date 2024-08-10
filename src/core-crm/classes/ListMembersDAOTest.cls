/**
 * @description Test Class for List Member DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                        |
      |--------------------------------|-----------------------|------------------------|---------------------------------------|
      | carl.alvin.cabiles             | September 14, 2023    | DEPP-6510              | Created file                          |
      | kenneth.f.alsay                | January 26, 2024      | DEPP-6964              | Added getListMembersByStatus          |
      | nicole.genon                   | February 1, 2024      | DEPP-7003              | Added getexistingListMembersWithMatchingContactList |
      | kenneth.f.alsay                | February 12, 2024     | DEPP-6953              | Added getListMembersByListIdAndStatus |
      |                                |                       |                        | Added runAs to all methods. PMD fix.  |     
 */
@isTest
public with sharing class ListMembersDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserAlumniEngagementManager();
    } 

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            System.assert(ListMembersDAO.newInstance() != null, 'ListMembersDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getexistingListMembersWithMatchingList() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager){
            List<List_Member__c> listMemberRecords = ListMembersDAO.newInstance()
                .getexistingListMembersWithMatchingList(new Set<Id>(),new Set<Id>(),'SYSTEM_MODE');
            System.assert(listMemberRecords.isEmpty(), 'listMemberRecords is not empty');
        }
        Test.stopTest();
    }
    
    @isTest
    static void getListMembersByStatus() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager){
            List<List_Member__c> listMemberRecords = ListMembersDAO.newInstance()
                .getListMembersByStatus(100, AccessLevel.SYSTEM_MODE, '');
            System.assert(listMemberRecords.isEmpty(), 'listMemberRecords is not empty');
        }
        Test.stopTest();     
    }

    @isTest
    static void getListMembersByListIdAndStatus() {
        Test.startTest();  
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager){
            List<List_Member__c> listMemberRecords = ListMembersDAO.newInstance()
                .getListMembersByListIdAndStatus(new Set<Id>(), 'Qualified', AccessLevel.SYSTEM_MODE);
            System.assert(listMemberRecords.isEmpty(), 'listMemberRecords is not empty'); 
        }
        Test.stopTest(); 
    }

    @isTest
    static void getListMembersByActivityStatus() {
        Test.startTest();  
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager){
            List<List_Member__c> listMemberRecords = ListMembersDAO.newInstance()
                .getListMembersByActivityStatus(100, 'Accepted', AccessLevel.SYSTEM_MODE);
            System.assert(listMemberRecords.isEmpty(), 'listMemberRecords is not empty'); 
        }
        Test.stopTest(); 
    }

    @isTest
    static void getexistingListMembersWithMatchingContactList() {
        Test.startTest();
            List<List_Member__c> listMemberRecords = ListMembersDAO.newInstance()
                .getexistingListMembersWithMatchingContactList(new Set<Id>(),new Set<Id>(),'SYSTEM_MODE');
            System.assert(listMemberRecords.isEmpty(), 'listMemberRecords is not empty');
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager){
            System.assert(
                new ListMembersDAO().getSObjectType() == List_Member__c.SObjectType,
                'SObject is not List_Member__c'
            );
        }        
        Test.stopTest();
    }
}