/**
 * @description Test Class for Engagement Opportunity Check List Member flow
 *
 * @see ../flows/Engagement Opportunity Check List Member
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary         |
      |---------------------------|-----------------------|--------------|------------------------|
      | carl.alvin.cabiles	      | February 7, 2022      | DEPP-7134    | Created file           |
*/
@isTest
public class EngagementOpportunityCheckListMemberTest {
    @testSetup
    static void makeData(){
        Test.startTest();
        TestDataFactoryUser.generateUserCorporateEngagementManager();
        TestDataFactoryUser.generateUserAlumniEngagementManager();
        Test.stopTest();

    	System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            List<Account> accountRecord = TestDataFactory.createTestAccountRecordsWithRecordType(1, AccountsDAO.ACCT_UNIV_DEP_ID);
            accountRecord[0].Organization_Unit_Level__c ='2';
            accountRecord[0].End_Date__c = null;
            AccountsDAO.newInstance().insertRecords(accountRecord, false, AccessLevel.SYSTEM_MODE);
        
            List<List__c> newListRecords = TestDataFactory.createListRecords(1);
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            newContacts[0].QUT_Employee_ID__c = '0001';
            ListsDAO.newInstance().insertRecords(newListRecords, false, AccessLevel.USER_MODE);
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            List<Engagement_Opportunity__c> newEngagementOpportunity = TestDataFactory.createTestEngagementOpportunityRecords(1);
            newEngagementOpportunity[0].Stage__c = 'Identify';
            newEngagementOpportunity[0].Requestor_Name__c = newContacts[0].id;
            newEngagementOpportunity[0].Requesting_Faculty__c = accountRecord[0].id;
            EngagementOpportunitiesDAO.newInstance().insertRecords(newEngagementOpportunity, false, AccessLevel.USER_MODE);  
            List<List__c> listToUpdate = new List<List__c>();
            listToUpdate.add(
                new List__c(
                    Id = newListRecords[0].id,
                    Engagement_Opportunity__c = newEngagementOpportunity[0].id
                )
            );
            ListsDAO.newInstance().updateRecords(listToUpdate, false, AccessLevel.USER_MODE);
    	}   
    }

    @isTest
    private static void checkStageUpdeWithQualifiedListMembers() {
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            Test.startTest();
            List<Engagement_Opportunity__c> engOpportunityRecords = EngagementOpportunitiesDAO.getEngagementOpportunitiesBySetNames(new Set<String>{'0Test Engagement Opp'},AccessLevel.USER_MODE);
            List<List__c> listRec = ListsDAO.newInstance().getListRecordsByRelatedEngagementOpportunitySetIds(new Set<Id>{engOpportunityRecords.get(0).id},AccessLevel.USER_MODE);
        	List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(5,listRec[0].id,engOpportunityRecords[0].Requestor_Name__c);
        	for( List_Member__c listMember: newListMemberRecords){
               	listMember.List_Member_Status__c = 'Qualified';
                }
        	ListMembersDAO.newInstance().insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();
            engOpportunityRecords[0].Stage__c = 'Engage';
            Database.SaveResult[] srList = EngagementOpportunitiesDAO.newInstance().updateRecords(engOpportunityRecords, false, AccessLevel.USER_MODE);
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was saved.');
            }
        }
    }
    
    @isTest
    private static void checkStageUpdeWithDisqualifiedListMembers() {
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            Test.startTest();
            List<Engagement_Opportunity__c> engOpportunityRecords = EngagementOpportunitiesDAO.getEngagementOpportunitiesBySetNames(new Set<String>{'0Test Engagement Opp'},AccessLevel.USER_MODE);
            List<List__c> listRec = ListsDAO.newInstance().getListRecordsByRelatedEngagementOpportunitySetIds(new Set<Id>{engOpportunityRecords.get(0).id},AccessLevel.USER_MODE);
        	List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(5,listRec[0].id,engOpportunityRecords[0].Requestor_Name__c);
        	for( List_Member__c listMember: newListMemberRecords){
               	listMember.List_Member_Status__c = 'Disqualified';
                }
            ListMembersDAO.newInstance().insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();
             List<Engagement_Opportunity__c> engagementOppRecords = EngagementOpportunitiesDAO.getEngagementOpportunitiesBySetNames(new Set<String>{'0Test Engagement Opp'},AccessLevel.USER_MODE);
            engagementOppRecords[0].Stage__c = 'Engage';
            Database.SaveResult[] srList = EngagementOpportunitiesDAO.newInstance().updateRecords(engagementOppRecords, false, AccessLevel.USER_MODE);
            for (Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }
    
    @isTest
    private static void checkStageUpdeWithSingleQualifiedListMembers() {
        System.runAs(TestDataFactoryUser.selectUserAlumniEngagementManager) {
            Test.startTest();
            List<Engagement_Opportunity__c> engOpportunityRecords = EngagementOpportunitiesDAO.getEngagementOpportunitiesBySetNames(new Set<String>{'0Test Engagement Opp'},AccessLevel.USER_MODE);
            List<List__c> listRec = ListsDAO.newInstance().getListRecordsByRelatedEngagementOpportunitySetIds(new Set<Id>{engOpportunityRecords.get(0).id},AccessLevel.USER_MODE);
        	List<List_Member__c> newListMemberRecords = TestDataFactory.createListMemberRecords(1,listRec[0].id,engOpportunityRecords[0].Requestor_Name__c);
        	for( List_Member__c listMember: newListMemberRecords){
               	listMember.List_Member_Status__c = 'Qualified';
                }
            ListMembersDAO.newInstance().insertRecords(newListMemberRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();
             List<Engagement_Opportunity__c> engagementOppRecords = EngagementOpportunitiesDAO.getEngagementOpportunitiesBySetNames(new Set<String>{'0Test Engagement Opp'},AccessLevel.USER_MODE);
            engagementOppRecords[0].Stage__c = 'Engage';
            Database.SaveResult[] srList = EngagementOpportunitiesDAO.newInstance().updateRecords(engagementOppRecords, false, AccessLevel.USER_MODE);
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was saved.');
            }
        }
    }

}