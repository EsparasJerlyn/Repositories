/**
 * @description Test class for LeadScoreConfigRecalculationBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | November 04, 2023     | DEPP-7155              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class LeadScoreConfigRecalculationBatchTest {
    @TestSetup
    static void setupData(){
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) { 

            setupLeadScoreConfig(
                LeadScoreConfigurationDAO.DOMESTIC, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD
            );

            setupDomesticUndeterminedLeadScoreConfig(
                LeadScoreConfigurationDAO.DOMESTIC, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDETERMINED
            );

            List<Contact> contactsToAdd = new List<Contact>();
            List<Contact> contactList = TestDataFactory.createTestContactRecords(2, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);
            contactsToAdd.addAll(contactList);
            ContactsDAO.newInstance().insertRecords(contactsToAdd, true, AccessLevel.SYSTEM_MODE);    
            
            List<Marketing_Segmentation__c> mktgSegConToUpdate = new List<Marketing_Segmentation__c>();
            List<Marketing_Segmentation__c> marketingSegmentationConList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactIds(new Set<Id>{contactList[0].Id}, AccessLevel.SYSTEM_MODE);
            for(Marketing_Segmentation__c mktgSeg : marketingSegmentationConList){
                mktgSeg.My_Primary_Study_Level__c = 'Undergraduate';
                mktgSegConToUpdate.add(mktgSeg);
            }
            MarketingSegmentationsDAO.newInstance().updateRecords(mktgSegConToUpdate, true, AccessLevel.SYSTEM_MODE);
            
            List<Marketing_Interaction__c> marInteractionList = new List<Marketing_Interaction__c>();
            marInteractionList.add(
                new Marketing_Interaction__c(
                    Match_My_Skill_Completion__c = 'Yes',
                    Contact__c = contactList[0].Id,
                    Event_Type__c = 'Open Day',
                    Event_Date__c = System.today().addDays(1)
                )
            );        
            MarketingInteractionsDAO.newInstance().insertRecords(marInteractionList, true, AccessLevel.SYSTEM_MODE);

            List<Case> caseList = TestDataFactory.createTestCaseRecords(CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID, 'Test Case', 3);
            for(Case caseRec : caseList){
                caseRec.Category__c = 'Course information';
                caseRec.ContactId = contactList[0].Id;
                caseRec.Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC;
            }
            CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.SYSTEM_MODE); 
        }
    }

    @isTest
    private static void updateSubCategoryConfigTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();
            List<Lead_Score_Configuration__c> configsToUpdate = new List<Lead_Score_Configuration__c>();
            List<Lead_Score_Configuration__c> configs = [SELECT Id, RecordTypeId, Score_Allocation__c, Study_Level__c, Domestic_International__c FROM Lead_Score_Configuration__c];
            for(Lead_Score_Configuration__c config : configs){
                if(
                    config.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY &&
                    config.Domestic_International__c == 'Domestic' && 
                    config.Study_Level__c == 'Undergraduate'
                ){
                    config.Score_Allocation__c = 5;
                    configsToUpdate.add(config);
                }
            }
            LeadScoreConfigurationDAO.newInstance().updateRecords(configsToUpdate, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            System.assert(
                !configsToUpdate.isEmpty(),
                'Lead Score Config update failed.'
            );
        }
    }

    @isTest
    private static void updateCategoryConfigTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();
            List<Lead_Score_Configuration__c> configsToUpdate = new List<Lead_Score_Configuration__c>();
            List<Lead_Score_Configuration__c> configs = [SELECT Id, RecordTypeId, Score_Allocation__c, Study_Level__c, Domestic_International__c FROM Lead_Score_Configuration__c];
            for(Lead_Score_Configuration__c config : configs){
                if(
                    config.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY &&
                    config.Domestic_International__c == 'Domestic' && 
                    config.Study_Level__c == 'Undergraduate'
                ){
                    config.Max_Score__c = 50;
                    configsToUpdate.add(config);
                }
            }
            LeadScoreConfigurationDAO.newInstance().updateRecords(configsToUpdate, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            System.assert(
                !configsToUpdate.isEmpty(),
                'Lead Score Config update failed.'
            );
        }
    }

    private static void setupLeadScoreConfig(String citizenship, String studyLevel){
        List<Lead_Score_Configuration__c> leadScoreParentConfigList = new List<Lead_Score_Configuration__c>();
        leadScoreParentConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Total Max Score DUG',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG,
                Domestic_International__c = citizenship,
                Study_Level__c = studyLevel
            )
        );

        LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreParentConfigList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> categList = new List<Lead_Score_Configuration__c>();
        categList.add(setUpCategory('Event Registration and Attendance', leadScoreParentConfigList[0].Id)); 
        categList.add(setUpCategory('Enquiries', leadScoreParentConfigList[0].Id)); 
        categList.add(setUpCategory('Primary BSA', leadScoreParentConfigList[0].Id)); 
        categList.add(setUpCategory('Program Engagement', leadScoreParentConfigList[0].Id)); 
        categList.add(setUpCategory('Marketing consent', leadScoreParentConfigList[0].Id)); 
        LeadScoreConfigurationDAO.newInstance().insertRecords(categList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> subCategList = new List<Lead_Score_Configuration__c>();
        for(Lead_Score_Configuration__c conf : categList){
            if(conf.Name == 'Event Registration and Attendance'){
                subCategList.add(setUpSubCategory('Open Day Registration', conf.Id, 10));
                subCategList.add(setUpSubCategory('Other Event Registration', conf.Id, 5));
                subCategList.add(setUpSubCategory('Other Event Attendance', conf.Id, 5));
            }
            else if(conf.Name == 'Enquiries'){
                subCategList.add(setUpSubCategory('Applying for a course', conf.Id, 10));
                subCategList.add(setUpSubCategory('Entry requirements & university study pathways', conf.Id, 10));
                subCategList.add(setUpSubCategory('Fees, costs and scholarships', conf.Id, 5));
                subCategList.add(setUpSubCategory('Course information', conf.Id, 5));
                subCategList.add(setUpSubCategory('Course application & offers', conf.Id, 5));
                subCategList.add(setUpSubCategory('Preparing to Study', conf.Id, 5));
                subCategList.add(setUpSubCategory('Student Life', conf.Id, 5));
            }
            else if(conf.Name == 'Primary BSA'){
                subCategList.add(setUpSubCategory('Is not blank', conf.Id, 10));
                subCategList.add(setUpSubCategory('Is unsure', conf.Id, 5));
                subCategList.add(setUpSubCategory('Is blank', conf.Id, 5));
            }
            else if(conf.Name == 'Program Engagement'){
                subCategList.add(setUpSubCategory('Program Engagement attendance', conf.Id, 10));
            }
            else if(conf.Name == 'Marketing consent'){
                subCategList.add(setUpSubCategory('Yes', conf.Id, 10));
                subCategList.add(setUpSubCategory('Blank', conf.Id, 5));
            }
        }
        LeadScoreConfigurationDAO.newInstance().insertRecords(subCategList, true, AccessLevel.SYSTEM_MODE);
    }

    private static Lead_Score_Configuration__c setUpSubCategory(String subCategName, Id parentCategId, Integer score){
        Lead_Score_Configuration__c leadScoreConfig = new Lead_Score_Configuration__c(
            Parent_Category__c = parentCategId,
            Name = subCategName,
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY,
            Domestic_International__c = 'Domestic',
            Study_Level__c = 'Undergraduate',
            Description__c = '',
            Score_Allocation__c = score
        );

        return leadScoreConfig;
    }

    private static Lead_Score_Configuration__c setUpCategory(String categName, Id parentCategId){
        Lead_Score_Configuration__c leadScoreConfig = new Lead_Score_Configuration__c(
            Parent_Category__c = parentCategId,
            Name = categName,
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = 'Domestic',
            Study_Level__c = 'Undergraduate',
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = 18,
            Max_Score__c = 30
        );

        return leadScoreConfig;
    }

    private static void setupDomesticUndeterminedLeadScoreConfig(String citizenship, String studyLevel){
        List<Lead_Score_Configuration__c> leadScoreParentConfigList = new List<Lead_Score_Configuration__c>();
        leadScoreParentConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Total Max Score DUD',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG,
                Domestic_International__c = citizenship,
                Study_Level__c = studyLevel
            )
        );

        LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreParentConfigList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> categList = new List<Lead_Score_Configuration__c>();
        categList.add(setDomesticUndeterminedCategory('Event Registration and Attendance', leadScoreParentConfigList[0].Id)); 
        categList.add(setDomesticUndeterminedCategory('Enquiries', leadScoreParentConfigList[0].Id)); 
        categList.add(setDomesticUndeterminedCategory('Primary BSA', leadScoreParentConfigList[0].Id)); 
        categList.add(setDomesticUndeterminedCategory('Program Engagement', leadScoreParentConfigList[0].Id)); 
        categList.add(setDomesticUndeterminedCategory('Marketing consent', leadScoreParentConfigList[0].Id)); 
        LeadScoreConfigurationDAO.newInstance().insertRecords(categList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> subCategList = new List<Lead_Score_Configuration__c>();
        for(Lead_Score_Configuration__c conf : categList){
            if(conf.Name == 'Event Registration and Attendance'){
                subCategList.add(setUpSubCategory('Open Day Registration', conf.Id, 10));
                subCategList.add(setUpSubCategory('Other Event Registration', conf.Id, 5));
                subCategList.add(setUpSubCategory('Other Event Attendance', conf.Id, 5));
            }
            else if(conf.Name == 'Enquiries'){
                subCategList.add(setDomesticUndeterminedSubCategory('Applying for a course', conf.Id, 10));
                subCategList.add(setDomesticUndeterminedSubCategory('Entry requirements & university study pathways', conf.Id, 10));
                subCategList.add(setDomesticUndeterminedSubCategory('Fees, costs and scholarships', conf.Id, 5));
                subCategList.add(setDomesticUndeterminedSubCategory('Course information', conf.Id, 5));
                subCategList.add(setDomesticUndeterminedSubCategory('Course application & offers', conf.Id, 5));
                subCategList.add(setDomesticUndeterminedSubCategory('Preparing to Study', conf.Id, 5));
                subCategList.add(setDomesticUndeterminedSubCategory('Student Life', conf.Id, 5));
            }
            else if(conf.Name == 'Primary BSA'){
                subCategList.add(setDomesticUndeterminedSubCategory('Is not blank', conf.Id, 10));
                subCategList.add(setDomesticUndeterminedSubCategory('Is unsure', conf.Id, 5));
                subCategList.add(setDomesticUndeterminedSubCategory('Is blank', conf.Id, 5));
            }
            else if(conf.Name == 'Program Engagement'){
                subCategList.add(setDomesticUndeterminedSubCategory('Program Engagement attendance', conf.Id, 10));
            }
            else if(conf.Name == 'Marketing consent'){
                subCategList.add(setDomesticUndeterminedSubCategory('Yes', conf.Id, 10));
                subCategList.add(setDomesticUndeterminedSubCategory('Blank', conf.Id, 5));
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
            Study_Level__c = 'Undergraduate',
            Description__c = '',
            Score_Allocation__c = score
        );

        return leadScoreConfig;
    }
}