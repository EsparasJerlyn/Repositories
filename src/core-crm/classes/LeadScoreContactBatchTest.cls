/**
 * @description Test class for LeadScoreContactBatch
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
public with sharing class LeadScoreContactBatchTest {
    @TestSetup
    static void makeData(){
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        setupLeadScoreConfig(
                LeadScoreConfigurationDAO.UNDETERMINED, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDETERMINED
            );

            List<Contact> contactsToAdd = new List<Contact>();
            List<Contact> contactList = TestDataFactory.createTestContactRecords(2);
            contactList[0].Email_Opt_In_DateTime__c = System.now();
            contactList[1].Email_Opt_In_DateTime__c = System.now();
            contactsToAdd.addAll(contactList);
            ContactsDAO.newInstance().insertRecords(contactsToAdd, true, AccessLevel.SYSTEM_MODE);    
            Test.stopTest();            
    }

    @isTest
    private static void updateSubCategoryConfigTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            
            Test.startTest();
            List<Lead_Score_Configuration__c> configsToUpdate = new List<Lead_Score_Configuration__c>();
            List<Lead_Score_Configuration__c> configs = LeadScoreConfigurationDAO.newInstance().getLeadScoreConfigByCitizenshipStudyLvl('Undetermined', 'Undetermined');
            for(Lead_Score_Configuration__c config : configs){
                if(
                    config.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY &&
                    config.Domestic_International__c == 'Undetermined' && 
                    config.Study_Level__c == 'Undetermined'
                ){
                    config.Score_Allocation__c = 4;
                    configsToUpdate.add(config);
                }
            }
            LeadScoreConfigurationDAO.newInstance().updateRecords(configsToUpdate, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            List<Lead_Score_Detail__c> leadScoreDetailList = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailWithLimit(1);
            System.assertEquals(
                4, 
                leadScoreDetailList[0].Total_Lead_Score__c,
                'Lead Score Config update failed.'
            );
        }
    }

    private static void setupLeadScoreConfig(String citizenship, String studyLevel){
        List<Lead_Score_Configuration__c> leadScoreParentConfigList = new List<Lead_Score_Configuration__c>();
        leadScoreParentConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Total Max Score UU',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG,
                Domestic_International__c = citizenship,
                Study_Level__c = studyLevel
            )
        );

        LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreParentConfigList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> categList = new List<Lead_Score_Configuration__c>();
        categList.add(setCategory('Marketing consent', leadScoreParentConfigList[0].Id)); 
        LeadScoreConfigurationDAO.newInstance().insertRecords(categList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> subCategList = new List<Lead_Score_Configuration__c>();
        for(Lead_Score_Configuration__c conf : categList){
            if(conf.Name == 'Marketing consent'){
                subCategList.add(setSubCategory('is blank', conf.Id, 10));
                subCategList.add(setSubCategory('Yes', conf.Id, 10));
                subCategList.add(setSubCategory('No', conf.Id, 10));
            }            
        }
        LeadScoreConfigurationDAO.newInstance().insertRecords(subCategList, true, AccessLevel.SYSTEM_MODE);
    }

    private static Lead_Score_Configuration__c setCategory(String categName, Id parentCategId){
        Lead_Score_Configuration__c leadScoreConfig = new Lead_Score_Configuration__c(
            Parent_Category__c = parentCategId,
            Name = categName,
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = 'Undetermined',
            Study_Level__c = 'Undetermined',
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = 18,
            Max_Score__c = 30
        );

        return leadScoreConfig;
    }

    private static Lead_Score_Configuration__c setSubCategory(String subCategName, Id parentCategId, Integer score){
        Lead_Score_Configuration__c leadScoreConfig = new Lead_Score_Configuration__c(
            Parent_Category__c = parentCategId,
            Name = subCategName,
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY,
            Domestic_International__c = 'Undetermined',
            Study_Level__c = 'Undetermined',
            Description__c = '',
            Score_Allocation__c = score
        );

        return leadScoreConfig;
    }
}