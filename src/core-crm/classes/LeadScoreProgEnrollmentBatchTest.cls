/**
 * @description Test class for LeadScoreProgEnrollmentBatch
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
public with sharing class LeadScoreProgEnrollmentBatchTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.generateTestUsers(new List<String>{'System_Administrator'});
        System.runAs(TestDataFactory.getSystemAdminUser()){
            Test.startTest();
            setupLeadScoreConfig(
                LeadScoreConfigurationDAO.DOMESTIC, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD
            );          
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);
            contactList[0].QUT_Student__c = false;
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);    

            List<Account> accountList = TestDataFactory.createTestAccountRecordsWithRecordType(1, AccountsDAO.ACCT_ACADEMIC_PROGRAM_ID);
            accountList[0].Name = 'Start QUT';
            accountList[0].Program_Code__c = 'QC19';
            AccountsDAO.newInstance().insertRecords(accountList, true, AccessLevel.SYSTEM_MODE);
            
            List<hed__Program_Enrollment__c> programEnListToInsert = new List<hed__Program_Enrollment__c>();
            List<hed__Program_Enrollment__c> programEnListWithContact = TestDataFactory.createTestProgramEnrollmentRecords(1); 
            for(hed__Program_Enrollment__c prog: programEnListWithContact){                           
                prog.hed__Contact__c = contactList[0].Id;
                prog.hed__Account__c = accountList[0].Id;
                prog.Enrollment_Status__c = 'Test';
                
            }
            programEnListToInsert.addAll(programEnListWithContact);
            List<hed__Program_Enrollment__c> programEnList = TestDataFactory.createTestProgramEnrollmentRecords(1); 
            for(hed__Program_Enrollment__c prog: programEnList){                           
                prog.hed__Contact__c = contactList[0].Id;
            }
            programEnListToInsert.addAll(programEnList);
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnListToInsert, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            List<Marketing_Segmentation__c> marketingSegmentationConList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactIds(new Set<Id>{contactList[0].Id}, AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> mktgSegConToUpdate = new List<Marketing_Segmentation__c>();
            for(Marketing_Segmentation__c mktgSeg : marketingSegmentationConList){
                mktgSeg.My_Primary_Study_Level__c = 'Undergraduate';
                mktgSegConToUpdate.add(mktgSeg);
            }
            MarketingSegmentationsDAO.newInstance().updateRecords(mktgSegConToUpdate, true, AccessLevel.SYSTEM_MODE);         
        }
        
    }

    @isTest
    private static void updateSubCategoryConfigTest() {
        System.runAs(TestDataFactory.getSystemAdminUser()) {
            
            Test.startTest();
            List<Lead_Score_Configuration__c> configsToUpdate = new List<Lead_Score_Configuration__c>();
            List<Lead_Score_Configuration__c> configs = LeadScoreConfigurationDAO.newInstance().getLeadScoreConfigByCitizenshipStudyLvl('Domestic', 'Undergraduate');
            for(Lead_Score_Configuration__c config : configs){
                if(
                    config.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY &&
                    config.Domestic_International__c == 'Domestic' && 
                    config.Study_Level__c == 'Undergraduate'
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
                Name = 'Total Max Score DUG',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG,
                Domestic_International__c = citizenship,
                Study_Level__c = studyLevel
            )
        );

        LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreParentConfigList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> categList = new List<Lead_Score_Configuration__c>();
        categList.add(setCategory('Program Engagement', leadScoreParentConfigList[0].Id)); 
        LeadScoreConfigurationDAO.newInstance().insertRecords(categList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> subCategList = new List<Lead_Score_Configuration__c>();
        for(Lead_Score_Configuration__c conf : categList){
            if(conf.Name == 'Program Engagement'){
                subCategList.add(setSubCategory('Program Engagement attendance', conf.Id, 10));
            }            
        }
        LeadScoreConfigurationDAO.newInstance().insertRecords(subCategList, true, AccessLevel.SYSTEM_MODE);
    }

    private static Lead_Score_Configuration__c setCategory(String categName, Id parentCategId){
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

    private static Lead_Score_Configuration__c setSubCategory(String subCategName, Id parentCategId, Integer score){
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