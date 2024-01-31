/**
 * @description Test class for LeadScoreIndivEmailBatch
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
public with sharing class LeadScoreIndivEmailBatchTest {
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
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);
            contactsToAdd.addAll(contactList);
            ContactsDAO.newInstance().insertRecords(contactsToAdd, true, AccessLevel.SYSTEM_MODE);    
            Test.stopTest();

            et4ae5__Automated_Send__c automatedSend = new et4ae5__Automated_Send__c( Name = 'Test Automated Send' );
            insert automatedSend;

            List<et4ae5__IndividualEmailResult__c> indivEmailListToAdd = new List<et4ae5__IndividualEmailResult__c>();
            indivEmailListToAdd.add(
                new et4ae5__IndividualEmailResult__c(
                    et4ae5__TriggeredSendDefinition__c = automatedSend.Id,
                    et4ae5__Contact__c = contactList[0].Id, 
                    et4ae5__Opened__c = true,
                    et4ae5__NumberOfUniqueClicks__c	= 2,
                    et4ae5__DateOpened__c = System.Today()
                )
            );
            IndividualEmailResultsDAO.newInstance().insertRecords(indivEmailListToAdd, true, AccessLevel.SYSTEM_MODE); 
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
        categList.add(setDomesticUndeterminedCategory('Email Interaction', leadScoreParentConfigList[0].Id)); 
        LeadScoreConfigurationDAO.newInstance().insertRecords(categList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> subCategList = new List<Lead_Score_Configuration__c>();
        for(Lead_Score_Configuration__c conf : categList){
            if(conf.Name == 'Email Interaction'){
                subCategList.add(setDomesticUndeterminedSubCategory('Has Clicked Email', conf.Id, 10));
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