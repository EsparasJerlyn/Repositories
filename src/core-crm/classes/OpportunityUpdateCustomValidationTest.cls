/**
 * @description Test Class for Opportunity Update - Custom Validation flow
 *
 * @see ../flows/Opportunity Update - Custom Validation
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary         |
      |---------------------------|-----------------------|--------------|------------------------|
      | nicole.genon    	      | February 29, 2024     | DEPP-7905    | Created file           |
*/
@isTest
public with sharing class OpportunityUpdateCustomValidationTest {
    public static final String CONTRIBUTORS_CONTEXTUAL_ROLE_GROUP = 'Contributors';
    public static final String PRIMARY_CONTACT_CONTEXTUAL_ROLE = 'Primary Contact';

    @testSetup
    static void makeData(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Sys_Admin', 'QUT_Advancement_Manager'});
    	System.runAs(TestDataFactory.getAdvancementManager()) {
            List<Account> accountRecord = TestDataFactory.createTestAccountRecordsWithRecordType(1, AccountsDAO.ACCT_UNIV_DEP_ID);
            accountRecord[0].Organization_Unit_Level__c ='2';
            accountRecord[0].End_Date__c = null;
            AccountsDAO.newInstance().insertRecords(accountRecord, false, AccessLevel.SYSTEM_MODE);
        
            List<Opportunity> newOpportunityRecords = TestDataFactory.createTestOpportunityRecords(
                1,'OppTest',OpportunitiesDAO.ORGANISATION_GIVING_RECTYPE_ID);
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

            List<Opportunity> individualOpportunityRecords = TestDataFactory.createTestOpportunityRecords(
                1,'OppTest',OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID);
            individualOpportunityRecords[0].Description = 'Test';
            individualOpportunityRecords[0].ContactId = newContacts[0].Id;
            individualOpportunityRecords[0].Contact__c = newContacts[0].Id;
            individualOpportunityRecords[0].Donor_Linkage_Rank__c = 'Low Level of Connection';
            individualOpportunityRecords[0].Donor_Interest_Rank__c = 'Unknown or not assessed';
            individualOpportunityRecords[0].Donor_Ability_Rank__c = '$250K - $500K';
            individualOpportunityRecords[0].Probability_Of_Success__c = '60%';
            individualOpportunityRecords[0].Qualification_Summary__c = 'Test';
            individualOpportunityRecords[0].Is_Qualified__c = true;
            individualOpportunityRecords[0].Solicitation_Sub_Stage__c = 'Agreement';
            individualOpportunityRecords[0].Due_Diligence_Summary__c = 'Test';
            individualOpportunityRecords[0].Due_Diligence_Completed__c = true;
            individualOpportunityRecords[0].Is_Agreement_Signed__c = true;
            individualOpportunityRecords[0].StageName = OpportunitiesDAO.SOLICITATION_STAGE;

            OpportunitiesDAO.newInstance().insertRecords(individualOpportunityRecords, false, AccessLevel.USER_MODE);
        }

        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<Opportunity> oppRecords = OpportunitiesDAO.getOpportunityByRecordTypeIds(new Set<Id>{OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID},AccessLevel.USER_MODE);

            List<Donation__c> donationRecords = TestDataFactory.createDonationRecordsWithOpportunity(10,oppRecords[0].Id);

            DonationsDAO.newInstance().insertRecords(donationRecords, false, AccessLevel.USER_MODE);
        }
    }

    @isTest
    private static void checkStageUpdateWithActivePrimaryContact() {
        System.runAs(TestDataFactory.getAdvancementManager()) {
            Test.startTest();
            List<Opportunity> oppRecords = OpportunitiesDAO.getOpportunityByRecordTypeIds(new Set<Id>{OpportunitiesDAO.ORGANISATION_GIVING_RECTYPE_ID},AccessLevel.USER_MODE);

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
            List<Opportunity> oppRecords = OpportunitiesDAO.getOpportunityByRecordTypeIds(new Set<Id>{OpportunitiesDAO.ORGANISATION_GIVING_RECTYPE_ID},AccessLevel.USER_MODE);
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

    @isTest
    static void opportunityWithPendingPlanActivityStatusTest(){
        System.runAs(TestDataFactory.getAdvancementManager()){
            List<Opportunity> oppRecords = OpportunitiesDAO.getOpportunityByRecordTypeIds(new Set<Id>{OpportunitiesDAO.ORGANISATION_GIVING_RECTYPE_ID},AccessLevel.USER_MODE);
            List<Plan_Activity__c> planActivityRecords = PlanActivitiesDAO.newInstance().getPlanActivityRecordsWithOpportunityIds(new Set<Id>{oppRecords[0].id}, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            for( Plan_Activity__c planActivity: planActivityRecords){
                planActivity.Status__c = 'Pending';
            }
            PlanActivitiesDAO.newInstance().updateRecords(planActivityRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();
            oppRecords[0].StageName = 'Solicitation';
            Database.SaveResult[] srList = OpportunitiesDAO.newInstance().updateRecords(oppRecords, false, AccessLevel.USER_MODE);
            for (Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.'); 
            }
        }
    }

    @isTest
    private static void checkStageUpdateWithProposedDonations() {
        System.runAs(TestDataFactory.getAdvancementManager()) {
            Test.startTest();
            List<Opportunity> oppRecords = OpportunitiesDAO.getOpportunityByRecordTypeIds(new Set<Id>{OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID},AccessLevel.USER_MODE);

            oppRecords[0].StageName = 'Executed' ;
            OpportunitiesDAO.newInstance().updateRecords(oppRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();

            List<Opportunity> oppUpdatedRecords = OpportunitiesDAO.getRecordsBySetIds(new Set<Id>{oppRecords[0].Id});
            System.assert(oppUpdatedRecords[0].StageName.equals('Solicitation'), 'Stage value is Solicitation.');
        }
    }

    @isTest
    private static void checkStageUpdateWithNoAcceptedOrCompletedDonations() {
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<Opportunity> oppList = OpportunitiesDAO.getOpportunityByRecordTypeIds(new Set<Id>{OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID},AccessLevel.USER_MODE);
            List<Donation__c> relatedDonations = DonationsDAO.getDonationsByOpportunityIds(new Set<Id>{oppList[0].Id},AccessLevel.USER_MODE);

            for(Donation__c don : relatedDonations){
                don.Stage__c = 'Active';
            }

            DonationsDAO.newInstance().updateRecords(relatedDonations, false, AccessLevel.USER_MODE);
        }
        System.runAs(TestDataFactory.getAdvancementManager()) {

            Test.startTest();
            List<Opportunity> oppRecords = OpportunitiesDAO.getOpportunityByRecordTypeIds(new Set<Id>{OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID},AccessLevel.USER_MODE);

            oppRecords[0].StageName = 'Executed' ;
            OpportunitiesDAO.newInstance().updateRecords(oppRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();

            List<Opportunity> oppUpdatedRecords = OpportunitiesDAO.getRecordsBySetIds(new Set<Id>{oppRecords[0].Id});
            System.assert(oppUpdatedRecords[0].StageName.equals('Solicitation'), 'Stage value is Solicitation.');
        }
    }

    @isTest
    private static void checkStageUpdateWithAcceptedOrCompletedDonations() {
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            List<Opportunity> oppList = OpportunitiesDAO.getOpportunityByRecordTypeIds(new Set<Id>{OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID},AccessLevel.USER_MODE);
            List<Donation__c> relatedDonations = DonationsDAO.getDonationsByOpportunityIds(new Set<Id>{oppList[0].Id},AccessLevel.USER_MODE);

            for(Donation__c don : relatedDonations){
                don.Stage__c = 'Accepted';
            }

            DonationsDAO.newInstance().updateRecords(relatedDonations, false, AccessLevel.USER_MODE);
        }
        System.runAs(TestDataFactory.getAdvancementManager()) {

            Test.startTest();
            List<Opportunity> oppRecords = OpportunitiesDAO.getOpportunityByRecordTypeIds(new Set<Id>{OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID},AccessLevel.USER_MODE);

            oppRecords[0].StageName = 'Executed' ;
            OpportunitiesDAO.newInstance().updateRecords(oppRecords, false, AccessLevel.USER_MODE);
            Test.stopTest();

            List<Opportunity> oppUpdatedRecords = OpportunitiesDAO.getRecordsBySetIds(new Set<Id>{oppRecords[0].Id});
            System.assert(oppUpdatedRecords[0].StageName.equals('Executed'), 'Stage value is successfully changed to Executed.');
        }
    }
}