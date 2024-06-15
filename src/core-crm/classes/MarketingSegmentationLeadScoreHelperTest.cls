/**
 * @description Test class for MarketingSegmentationLeadScoreHelper
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 08, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class MarketingSegmentationLeadScoreHelperTest {

    @TestSetup
    static void makeData(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB){

            setupLeadScoreConfig(
                LeadScoreConfigurationDAO.DOMESTIC, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD
            );

            setupLeadScoreConfig(
                LeadScoreConfigurationDAO.INTERNATIONAL, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_POSTGRAD
            );

            setupLeadScoreConfig(
                LeadScoreConfigurationDAO.UNDETERMINED, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDETERMINED
            );

            setupLeadScoreConfig(
                LeadScoreConfigurationDAO.INTERNATIONAL, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD
            );

            setupLeadScoreConfig(
                LeadScoreConfigurationDAO.DOMESTIC, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_POSTGRAD
            );

            List<Contact> contactList = new List<Contact>();
            contactList.addAll(TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC));
            contactList.addAll(TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL));
            contactList.addAll(TestDataFactory.createTestContactRecords(1, ''));
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);            
           
        }
    }

    @isTest
    public static void processLeadScoreCalculationUndergradTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contactList = [SELECT Id, Name, hed__Citizenship_Status__c FROM Contact WHERE hed__Citizenship_Status__c = 'Domestic'];

            List<Marketing_Segmentation__c> marketingSegmentationList = [
                SELECT Id, Contact__r.Name, My_Primary_Study_Level__c, My_Expected_Admission_Year__c, My_Citizenship_Status__c, 
                        My_Primary_BSA__c, My_Primary_NSA__c, My_Double_Degree__c, My_Interested_English_Pathways__c 
                FROM Marketing_Segmentation__c 
                WHERE Contact__c = : contactList[0].Id LIMIT 1
            ];

            List<Marketing_Segmentation__c> mktgSegToUpdate = new List<Marketing_Segmentation__c>();
            for(Marketing_Segmentation__c mktgSeg : marketingSegmentationList){
                mktgSeg.My_Primary_Study_Level__c = 'Undergraduate';
                mktgSeg.My_Expected_Admission_Year__c = Integer.valueOf(Date.today().year());
                mktgSegToUpdate.add(mktgSeg);
            }
            MarketingSegmentationsDAO.newInstance().updateRecords(mktgSegToUpdate, true, AccessLevel.SYSTEM_MODE);
            
            Test.stopTest();

            List<Lead_Score_Detail__c> leadScoreDetails = [SELECT Id, Contact__c, Total_Lead_Score__c, Preferred_Intake__c FROM Lead_Score_Detail__c WHERE Contact__c = : contactList[0].Id];

            System.assert(leadScoreDetails[0].Total_Lead_Score__c == 30, 'Incorrect Total Lead Score.');
        }        
    }

    @isTest
    public static void processLeadScoreCalculationPostgradTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contactList = [SELECT Id, Name, hed__Citizenship_Status__c FROM Contact WHERE hed__Citizenship_Status__c = 'International'];

            List<Marketing_Segmentation__c> marketingSegmentationList = [
                SELECT Id, Contact__r.Name, My_Primary_Study_Level__c, My_Expected_Admission_Year__c, My_Citizenship_Status__c, 
                        My_Primary_BSA__c, My_Primary_NSA__c, My_Double_Degree__c, My_Interested_English_Pathways__c 
                FROM Marketing_Segmentation__c 
                WHERE Contact__c = : contactList[0].Id LIMIT 1
            ];

            List<Marketing_Segmentation__c> mktgSegToUpdate = new List<Marketing_Segmentation__c>();
            for(Marketing_Segmentation__c mktgSeg : marketingSegmentationList){
                mktgSeg.My_Primary_Study_Level__c = 'Postgraduate';
                mktgSeg.My_Expected_Admission_Year__c = Integer.valueOf(Date.today().year());
                mktgSegToUpdate.add(mktgSeg);
            }
            MarketingSegmentationsDAO.newInstance().updateRecords(mktgSegToUpdate, true, AccessLevel.SYSTEM_MODE);
            
            Test.stopTest();

            List<Lead_Score_Detail__c> leadScoreDetails = [SELECT Id, Contact__c, Total_Lead_Score__c, Preferred_Intake__c FROM Lead_Score_Detail__c WHERE Contact__c = : contactList[0].Id];
            System.assert(leadScoreDetails[0].Total_Lead_Score__c == 30, 'Incorrect Total Lead Score.');
        }        
    }

    @isTest
    public static void processLeadScoreCalculationUndeterminedTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contactList = [SELECT Id, Name, hed__Citizenship_Status__c FROM Contact WHERE hed__Citizenship_Status__c = null];

            List<Marketing_Segmentation__c> marketingSegmentationList = [
                SELECT Id, Contact__r.Name, My_Primary_Study_Level__c, My_Expected_Admission_Year__c, My_Citizenship_Status__c, 
                        My_Primary_BSA__c, My_Primary_NSA__c, My_Double_Degree__c, My_Interested_English_Pathways__c 
                FROM Marketing_Segmentation__c 
                WHERE Contact__c = : contactList[0].Id LIMIT 1
            ];

            List<Marketing_Segmentation__c> mktgSegToUpdate = new List<Marketing_Segmentation__c>();
            for(Marketing_Segmentation__c mktgSeg : marketingSegmentationList){
                mktgSeg.My_Expected_Admission_Year__c = Integer.valueOf(Date.today().year());
                mktgSegToUpdate.add(mktgSeg);
            }
            MarketingSegmentationsDAO.newInstance().updateRecords(mktgSegToUpdate, true, AccessLevel.SYSTEM_MODE);
            
            Test.stopTest();

            List<Lead_Score_Detail__c> leadScoreDetails = [SELECT Id, Contact__c, Total_Lead_Score__c, Preferred_Intake__c FROM Lead_Score_Detail__c WHERE Contact__c = : contactList[0].Id];

            System.assert(leadScoreDetails[0].Total_Lead_Score__c == 30, 'Incorrect Total Lead Score.');
        }        
    }

    @isTest
    public static void processLeadScoreCalculationDomPGTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contactList = [SELECT Id, Name, hed__Citizenship_Status__c FROM Contact WHERE hed__Citizenship_Status__c = 'Domestic'];

            List<Marketing_Segmentation__c> marketingSegmentationList = [
                SELECT Id, Contact__r.Name, My_Primary_Study_Level__c, My_Expected_Admission_Year__c, My_Citizenship_Status__c, 
                        My_Primary_BSA__c, My_Primary_NSA__c, My_Double_Degree__c, My_Interested_English_Pathways__c 
                FROM Marketing_Segmentation__c 
                WHERE Contact__c = : contactList[0].Id LIMIT 1
            ];

            List<Marketing_Segmentation__c> mktgSegToUpdate = new List<Marketing_Segmentation__c>();
            for(Marketing_Segmentation__c mktgSeg : marketingSegmentationList){
                mktgSeg.My_Primary_Study_Level__c = 'Postgraduate';
                mktgSeg.My_Expected_Admission_Year__c = Integer.valueOf(Date.today().year());
                mktgSegToUpdate.add(mktgSeg);
            }
            MarketingSegmentationsDAO.newInstance().updateRecords(mktgSegToUpdate, true, AccessLevel.SYSTEM_MODE);
            
            Test.stopTest();

            List<Lead_Score_Detail__c> leadScoreDetails = [SELECT Id, Contact__c, Total_Lead_Score__c, Preferred_Intake__c FROM Lead_Score_Detail__c WHERE Contact__c = : contactList[0].Id];

            System.assert(leadScoreDetails[0].Total_Lead_Score__c == 30, 'Incorrect Total Lead Score.');
        }        
    }

    @isTest
    public static void processLeadScoreCalculationIntUGTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contactList = [SELECT Id, Name, hed__Citizenship_Status__c FROM Contact WHERE hed__Citizenship_Status__c = 'International'];

            List<Marketing_Segmentation__c> marketingSegmentationList = [
                SELECT Id, Contact__r.Name, My_Primary_Study_Level__c, My_Expected_Admission_Year__c, My_Citizenship_Status__c, 
                        My_Primary_BSA__c, My_Primary_NSA__c, My_Double_Degree__c, My_Interested_English_Pathways__c 
                FROM Marketing_Segmentation__c 
                WHERE Contact__c = : contactList[0].Id LIMIT 1
            ];

            List<Marketing_Segmentation__c> mktgSegToUpdate = new List<Marketing_Segmentation__c>();
            for(Marketing_Segmentation__c mktgSeg : marketingSegmentationList){
                mktgSeg.My_Primary_Study_Level__c = 'Undergraduate';
                mktgSeg.My_Expected_Admission_Year__c = Integer.valueOf(Date.today().year());
                mktgSegToUpdate.add(mktgSeg);
            }
            MarketingSegmentationsDAO.newInstance().updateRecords(mktgSegToUpdate, true, AccessLevel.SYSTEM_MODE);
            
            Test.stopTest();

            List<Lead_Score_Detail__c> leadScoreDetails = [SELECT Id, Contact__c, Total_Lead_Score__c, Preferred_Intake__c FROM Lead_Score_Detail__c WHERE Contact__c = : contactList[0].Id];

            System.assert(leadScoreDetails[0].Total_Lead_Score__c == 30, 'Incorrect Total Lead Score.');
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

        List<Lead_Score_Configuration__c> leadScoreCategoryList = new List<Lead_Score_Configuration__c>();
        leadScoreCategoryList.add(
            new Lead_Score_Configuration__c(
                Parent_Category__c = leadScoreParentConfigList[0].Id,
                Name = 'Preferred Intake',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = citizenship,
                Study_Level__c = studyLevel,
                Description__c = '',
                Time_Limit_Months__c = 0,
                Max_Score__c = 30
            )
        );

        LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreCategoryList, true, AccessLevel.SYSTEM_MODE);

        Id categoryId = leadScoreCategoryList[0].Id;

        List<Lead_Score_Configuration__c> leadScoreSubCategoryList = new List<Lead_Score_Configuration__c>();
        leadScoreSubCategoryList.addALl(createDomUGCategoryRecords(citizenship, studyLevel, categoryId));
        leadScoreSubCategoryList.addALl(createIntPGCategoryRecords(citizenship, studyLevel, categoryId));
        leadScoreSubCategoryList.addALl(createUndUDCategoryRecords(citizenship, studyLevel, categoryId));
        leadScoreSubCategoryList.addALl(createDomPGCategoryRecords(citizenship, studyLevel, categoryId));
        leadScoreSubCategoryList.addALl(createIntUGCategoryRecords(citizenship, studyLevel, categoryId));
        LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreSubCategoryList, true, AccessLevel.SYSTEM_MODE);
    }

    private static List<Lead_Score_Configuration__c> createDomUGCategoryRecords(String citizenship, String studyLevel, Id categoryId){
        List<Lead_Score_Configuration__c> response = new List<Lead_Score_Configuration__c>();
        if(citizenship == 'Domestic' && studylevel == 'Undergraduate'){
            response.addAll(
                TestDataFactory.createDomstcAndUnderGradSubCategory(
                    categoryId,
                    getCategoryList(),
                    getScoreAllocList()
                )
            );
        }
        return response;
    }

    private static List<Lead_Score_Configuration__c> createIntPGCategoryRecords(String citizenship, String studyLevel, Id categoryId){
        List<Lead_Score_Configuration__c> response = new List<Lead_Score_Configuration__c>();
        if(citizenship == 'International' && studylevel == 'Postgraduate'){
            response.addAll(
                TestDataFactory.createIntlAndPostgradSubCategory(
                    categoryId,
                    getCategoryList(),
                    getScoreAllocList()
                )
            );
        }
        return response;
    }

    private static List<Lead_Score_Configuration__c> createUndUDCategoryRecords(String citizenship, String studyLevel, Id categoryId){
        List<Lead_Score_Configuration__c> response = new List<Lead_Score_Configuration__c>();
        if(citizenship == 'Undetermined' && studylevel == 'Undetermined'){
            response.addAll(
                TestDataFactory.createUndAndUndeterminedSubCategory(
                    categoryId,
                    getCategoryList(),
                    getScoreAllocList()
                )
            );
        }
        return response;
    }

    private static List<Lead_Score_Configuration__c> createDomPGCategoryRecords(String citizenship, String studyLevel, Id categoryId){
        List<Lead_Score_Configuration__c> response = new List<Lead_Score_Configuration__c>();
        if(citizenship == 'Domestic' && studylevel == 'Postgraduate'){
            response.addAll(
                TestDataFactory.createDomestcAndPostgradSubCategory(
                    categoryId,
                    getCategoryList(),
                    getScoreAllocList()
                )
            );
        }
        return response;
    }

    private static List<Lead_Score_Configuration__c> createIntUGCategoryRecords(String citizenship, String studyLevel, Id categoryId){
        List<Lead_Score_Configuration__c> response = new List<Lead_Score_Configuration__c>();
        if(citizenship == 'International' && studylevel == 'Undergraduate'){
            response.addAll(
                TestDataFactory.createIntlAndUnderGradSubCategory(
                    categoryId,
                    getCategoryList(),
                    getScoreAllocList()
                )
            );
        }
        return response;
    }

    private static List<String> getCategoryList(){
        return new List<String>{
            'Is this year (rolling each year)',
            'Next year',
            'Is not blank',
            'Is blank'
        };
    }

    private static List<Integer> getScoreAllocList(){
        return new List<Integer>{ 30, 30, 10, 0 };
    }
}