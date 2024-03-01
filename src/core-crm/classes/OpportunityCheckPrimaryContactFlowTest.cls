/**
 * @description Test Class for Opportunity Check Primary Contact flow
 *
 * @see ../flows/Opportunity Check Primary Contact
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary         |
      |---------------------------|-----------------------|--------------|------------------------|
      | nicole.genon    	      | February 29, 2024     | DEPP-7905    | Created file           |
*/
@isTest
public with sharing class OpportunityCheckPrimaryContactFlowTest {
    public static final String CONTRIBUTORS_CONTEXTUAL_ROLE_GROUP = 'Contributors';
    public static final String PRIMARY_CONTACT_CONTEXTUAL_ROLE = 'Primary Contact';

    @testSetup
    static void makeData(){
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Advancement_Manager'});
    	System.runAs(TestDataFactory.getAdvancementManager()) {
            List<Account> accountRecord = TestDataFactory.createTestAccountRecordsWithRecordType(1, AccountsDAO.ACCT_UNIV_DEP_ID);
            accountRecord[0].Organization_Unit_Level__c ='2';
            accountRecord[0].End_Date__c = null;
            AccountsDAO.newInstance().insertRecords(accountRecord, false, AccessLevel.SYSTEM_MODE);
        
            List<Opportunity> newOpportunityRecords = TestDataFactory.createTestOpportunityRecords(
                1,'OppTest',OpportunitiesDAO.ORGANISATIONGIVING_RECTYPE_ID);
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);
            newOpportunityRecords[0].AccountId = accountRecord[0].Id;
            newOpportunityRecords[0].StageName = OpportunitiesDAO.IDENTIFY_STAGE;
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            newContacts[0].AccountId = accountRecord[0].Id;

            OpportunitiesDAO.newInstance().insertRecords(newOpportunityRecords, false, AccessLevel.USER_MODE);
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

            List<Contextual_Role__c> contextualRoleRecords = new List<Contextual_Role__c>();
            List<Contextual_Role__c> newContextualRoleRecords = TestDataFactory.createContextualRolesForOpportunity(10,ContextualRolesDAO.ADVANCEMENT_OPPORTUNITY_ROLE_RECTYPE_ID,newOpportunityRecords[0].id,accountRecord[0].Id,CONTRIBUTORS_CONTEXTUAL_ROLE_GROUP);

            for(Contextual_Role__c con : newContextualRoleRecords){
                con.Contextual_Role__c = PRIMARY_CONTACT_CONTEXTUAL_ROLE;
                con.Role_Is_Active__c = true;
                contextualRoleRecords.add(con);
            }
            ContextualRolesDAO.newInstance().insertRecords(contextualRoleRecords, false, AccessLevel.USER_MODE);  
        }
    }

    @isTest
    private static void checkStageUpdateWithActivePrimaryContact() {
        System.runAs(TestDataFactory.getAdvancementManager()) {
            Test.startTest();
            List<Opportunity> oppRecords = OpportunitiesDAO.getOpportunityByRecordTypeIds(new Set<Id>{OpportunitiesDAO.ORGANISATIONGIVING_RECTYPE_ID},AccessLevel.USER_MODE);

            oppRecords[0].Start_Date__c = System.today() + 10 ;
            oppRecords[0].Description = 'Opp Test';
            oppRecords[0].StageName = 'Qualify';
            OpportunitiesDAO.newInstance().updateRecords(oppRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();

            List<Opportunity> oppUpdatedRecords = OpportunitiesDAO.getRecordsBySetIds(new Set<Id>{oppRecords[0].Id});
            System.assert(oppUpdatedRecords[0].StageName.equals('Qualify'), 'Stage is successfully changed to Qualify.');
        }
    }

    @isTest
    private static void checkStageUpdateWithInActivePrimaryContact() {
        System.runAs(TestDataFactory.getAdvancementManager()) {
            Test.startTest();
            List<Opportunity> oppRecords = OpportunitiesDAO.getOpportunityByRecordTypeIds(new Set<Id>{OpportunitiesDAO.ORGANISATIONGIVING_RECTYPE_ID},AccessLevel.USER_MODE);
            List<Contextual_Role__c> contextualRoleRecordsToUpdate = new List<Contextual_Role__c>();
            List<Contextual_Role__c> contextualRoleRecords = ContextualRolesDAO.newInstance().getActiveOpportunityContextualRolesRecords(new Set<Id>{oppRecords[0].Id}, new List<String>{CONTRIBUTORS_CONTEXTUAL_ROLE_GROUP});

            for(Contextual_Role__c con : contextualRoleRecords){
                con.Role_Is_Active__c = false;
                contextualRoleRecordsToUpdate.add(con);
            }
            ContextualRolesDAO.newInstance().updateRecords(contextualRoleRecordsToUpdate, false, AccessLevel.USER_MODE);

            oppRecords[0].Start_Date__c = System.today() + 10 ;
            oppRecords[0].Description = 'Opp Test';
            oppRecords[0].StageName = 'Qualify';
            Database.SaveResult[] srList = OpportunitiesDAO.newInstance().updateRecords(oppRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();

            List<Opportunity> oppUpdatedRecords = OpportunitiesDAO.getRecordsBySetIds(new Set<Id>{oppRecords[0].Id});
            for (Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
            System.assert(oppUpdatedRecords[0].StageName.equals('Identify'), 'Stage value is Identify.');
        }
    }
}