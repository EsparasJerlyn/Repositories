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
public with sharing class ContactLeadScoreHelperTest {

    @TestSetup
    static void makeData(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB){
            // Test.startTest();
            setupLeadScoreConfig(
                LeadScoreConfigurationDAO.DOMESTIC, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD
            );

            List<Contact> contactList = new List<Contact>();
            contactList.addAll(TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC));
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);    
            // Test.stopTest();
            List<Marketing_Segmentation__c> marketingSegmentationList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactIds(new Set<Id>{contactList[0].Id}, AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> mktgSegToUpdate = new List<Marketing_Segmentation__c>();
            for(Marketing_Segmentation__c mktgSeg : marketingSegmentationList){
                mktgSeg.My_Primary_Study_Level__c = 'Undergraduate';
                mktgSeg.My_Citizenship_Status__c = MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_AU;
                mktgSeg.My_Expected_Admission_Year__c = Integer.valueOf(Date.today().year());
                mktgSegToUpdate.add(mktgSeg);
            }
            MarketingSegmentationsDAO.newInstance().updateRecords(mktgSegToUpdate, true, AccessLevel.SYSTEM_MODE);        
        }
        
    }

    @isTest
    public static void processLeadScoreCalculationUndergradTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contactListUpdate = new List<Contact>();
            for(Contact contactRec : ContactsDAO.newInstance().getPersonContactsWithLimit(1)){
                contactListUpdate.add(new Contact(Id = contactRec.Id, HasOptedOutOfEmail = true));
            }

            ContactsDAO.newInstance().updateRecords(contactListUpdate, true, AccessLevel.USER_MODE); 
            Test.stopTest();

            List<Lead_Score_Detail__c> leadScoreDetails = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailWithLimit(1);
            System.assertEquals(10,leadScoreDetails[0].Total_Lead_Score__c, 'Incorrect Total Lead Score.');
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
                Name = 'Marketing Consent',
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

    private static List<String> getCategoryList(){
        return new List<String>{
            'Yes',
            'is blank'
        };
    }

    private static List<Integer> getScoreAllocList(){
        return new List<Integer>{ 10, 0 };
    }
}