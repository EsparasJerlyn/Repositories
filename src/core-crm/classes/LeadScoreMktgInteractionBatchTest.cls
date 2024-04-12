/**
 * @description Test class for LeadScoreMktgInteractionBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | November 08, 2023     | DEPP-7155              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class LeadScoreMktgInteractionBatchTest {
    @TestSetup
    static void setupData(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_System_Administrator' });
        System.runAs(TestDataFactory.getSystemAdminUser()) { 
            Test.startTest();
            setupDomesticUndeterminedLeadScoreConfig(
                LeadScoreConfigurationDAO.DOMESTIC, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDETERMINED
            );

            List<Contact> contactsToAdd = new List<Contact>();
            List<Contact> contactList = TestDataFactory.createTestContactRecords(2, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);
            contactsToAdd.addAll(contactList);
            ContactsDAO.newInstance().insertRecords(contactsToAdd, true, AccessLevel.SYSTEM_MODE);    
            Test.stopTest();

            List<Marketing_Interaction__c> marInteractionList = new List<Marketing_Interaction__c>();
            marInteractionList.add(
                new Marketing_Interaction__c(
                    Match_My_Skill_Completion__c = 'TRUE',
                    Lead_Source__c = 'MMS',
                    Contact__c = contactList[0].Id
                )
            );        
            MarketingInteractionsDAO.newInstance().insertRecords(marInteractionList, true, AccessLevel.SYSTEM_MODE);
        }
    }

    @isTest
    private static void updateSubCategoryConfigTest() {
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            
            Test.startTest();
            List<Lead_Score_Configuration__c> configsToUpdate = new List<Lead_Score_Configuration__c>();
            List<Lead_Score_Configuration__c> configs = LeadScoreConfigurationDAO.newInstance().getLeadScoreConfigByCitizenshipStudyLvl('Domestic', 'Undetermined');
            for(Lead_Score_Configuration__c config : configs){
                if(
                    config.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY &&
                    config.Domestic_International__c == 'Domestic' && 
                    config.Study_Level__c == 'Undetermined'
                ){
                    config.Score_Allocation__c = 8;
                    configsToUpdate.add(config);
                }
            }
            LeadScoreConfigurationDAO.newInstance().updateRecords(configsToUpdate, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            List<Lead_Score_Detail__c> leadScoreDetailList = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailWithLimit(1);
            System.assertEquals(
                8, 
                leadScoreDetailList[0].Total_Lead_Score__c,
                'Lead Score Config update failed.'
            );
        }
    }

    private static void setupDomesticUndeterminedLeadScoreConfig(String citizenship, String studyLevel){
        List<Lead_Score_Configuration__c> leadScoreParentConfigList = new List<Lead_Score_Configuration__c>();
        leadScoreParentConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Total Max Score DU',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG,
                Domestic_International__c = citizenship,
                Study_Level__c = studyLevel
            )
        );

        LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreParentConfigList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> categList = new List<Lead_Score_Configuration__c>();
        categList.add(setDomesticUndeterminedCategory('Match My Skills', leadScoreParentConfigList[0].Id)); 
        categList.add(setDomesticUndeterminedCategory('Event Registration and Attendance', leadScoreParentConfigList[0].Id)); 
        LeadScoreConfigurationDAO.newInstance().insertRecords(categList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> subCategList = new List<Lead_Score_Configuration__c>();
        for(Lead_Score_Configuration__c conf : categList){
            if(conf.Name == 'Match My Skills'){
                subCategList.add(setDomesticUndeterminedSubCategory('Match My Skills completed', conf.Id, 10));
            }
            else if(conf.Name == 'Event Registration and Attendance'){
                subCategList.add(setDomesticUndeterminedSubCategory('Open Day Registration', conf.Id, 10));
                subCategList.add(setDomesticUndeterminedSubCategory('Other Event Registration', conf.Id, 5));
                subCategList.add(setDomesticUndeterminedSubCategory('Other Event Attendance', conf.Id, 5));
            }
        }
        LeadScoreConfigurationDAO.newInstance().insertRecords(subCategList, true, AccessLevel.SYSTEM_MODE);
    }

    private static Lead_Score_Configuration__c setDomesticUndeterminedCategory(String categName, Id parentCategId){
        Lead_Score_Configuration__c leadScoreConfig = new Lead_Score_Configuration__c(
            Parent_Category__c = parentCategId,
            Name = categName,
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = 'Domestic',
            Study_Level__c = 'Undetermined',
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = 18,
            Max_Score__c = 30
        );

        return leadScoreConfig;
    }

    private static Lead_Score_Configuration__c setDomesticUndeterminedSubCategory(String subCategName, Id parentCategId, Integer score){
        Lead_Score_Configuration__c leadScoreConfig = new Lead_Score_Configuration__c(
            Parent_Category__c = parentCategId,
            Name = subCategName,
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY,
            Domestic_International__c = 'Domestic',
            Study_Level__c = 'Undetermined',
            Description__c = '',
            Score_Allocation__c = score
        );

        return leadScoreConfig;
    }
}