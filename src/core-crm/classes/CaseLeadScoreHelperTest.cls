/**
 * @description Test class for LeadLeadScoreHelper
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
public with sharing class CaseLeadScoreHelperTest {
    @TestSetup
    static void makeData(){
            TestDataFactoryUser.generateUserQUTESB();
            Test.startTest();
            setupLeadScoreConfig(
                LeadScoreConfigurationDAO.DOMESTIC, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD
            );

            setupLeadScoreConfig(
                LeadScoreConfigurationDAO.DOMESTIC, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_POSTGRAD
            );

            setupLeadScoreConfig(
                LeadScoreConfigurationDAO.INTERNATIONAL, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_POSTGRAD
            );

            List<Lead> leadList = TestDataFactory.createTestLeadRecords(1,3);
            LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.SYSTEM_MODE);     

            //Contact
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);               
        
            Test.stopTest();

            List<Marketing_Segmentation__c> mktgSegToUpdate = new List<Marketing_Segmentation__c>();
            List<Marketing_Segmentation__c> marketingSegmentationList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[0].Id}, AccessLevel.SYSTEM_MODE);
            for(Marketing_Segmentation__c mktgSeg : marketingSegmentationList){
                mktgSeg.My_Primary_Study_Level__c = 'Undergraduate';
                mktgSeg.My_Citizenship_Status__c = MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_AU;
                mktgSegToUpdate.add(mktgSeg);
            }
            List<Marketing_Segmentation__c> marketingSegmentationListIPG = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(new Set<Id>{leadList[1].Id}, AccessLevel.SYSTEM_MODE);
            for(Marketing_Segmentation__c mktgSeg : marketingSegmentationListIPG){
                mktgSeg.My_Primary_Study_Level__c = 'Postgraduate';
                mktgSeg.My_Citizenship_Status__c = MarketingSegmentationsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
                mktgSegToUpdate.add(mktgSeg);
            }
            MarketingSegmentationsDAO.newInstance().updateRecords(mktgSegToUpdate, true, AccessLevel.SYSTEM_MODE);

            List<Case> caseListDomUG = TestDataFactory.createTestCaseRecords(CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID, 'Test Case', 3);
            for(Case caseRec : caseListDomUG){
                caseRec.Lead__c = leadList[0].Id;
                caseRec.Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC;
            }
            List<Case> caseListIntPG = TestDataFactory.createTestCaseRecords(CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID, 'Test Case Int', 3);
            for(Case caseRec : caseListIntPG){
                caseRec.Lead__c = leadList[1].Id;
                caseRec.Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL;
            }
            List<Case> caseList = new List<Case>();
            caseList.addAll(caseListDomUG);
            caseList.addAll(caseListIntPG);
            CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.SYSTEM_MODE);  

            List<Marketing_Segmentation__c> marketingSegmentationConList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactIds(new Set<Id>{contactList[0].Id}, AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> mktgSegConToUpdate = new List<Marketing_Segmentation__c>();
            for(Marketing_Segmentation__c mktgSeg : marketingSegmentationConList){
                mktgSeg.My_Primary_Study_Level__c = 'Postgraduate';
                mktgSegConToUpdate.add(mktgSeg);
            }
            MarketingSegmentationsDAO.newInstance().updateRecords(mktgSegConToUpdate, true, AccessLevel.SYSTEM_MODE);

            List<Case> caseConList = TestDataFactory.createTestCaseRecords(CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID, 'Test Contact Case', 3);
            for(Case caseRec : caseConList){
                caseRec.ContactId = contactList[0].Id;
                caseRec.Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC;
            }
            CasesDAO.newInstance().insertRecords(caseConList, true, AccessLevel.SYSTEM_MODE);  
        //} 
    }

    @isTest
    public static void processLeadScoreCalculationDomUGTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();

            List<Lead> leadListToUpdate = LeadsDAO.newInstance().getLeadsWithLimit(2);

            List<Case> caseList = CasesDAO.newInstance().getCasesByLeadIds(new Set<Id>{leadListToUpdate[0].Id}, AccessLevel.SYSTEM_MODE);
            List<Case> caseListToUpdate = new List<Case>();
            for(Case caseRec : caseList){
                if(caseRec.Subject == 'Test Case1'){
                    caseRec.Category__c = 'Course information';
                    caseListToUpdate.add(caseRec);
                }
            }
            CasesDAO.newInstance().updateRecords(caseListToUpdate, true, AccessLevel.SYSTEM_MODE); 

            Test.stopTest();
           
            List<Lead_Score_Detail__c> leadScoreDetails = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsByContactOrLeadId(new Set<Id>{leadListToUpdate[0].Id}, AccessLevel.SYSTEM_MODE);
            System.assert(leadScoreDetails[0].Total_Lead_Score__c == 5, 'Incorrect Total Lead Score.');
        }        
    }
    
    @isTest
    public static void processLeadScoreCalculationDomPGTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();

            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(1);

            List<Case> caseList = CasesDAO.newInstance().getCasesByContactIds(new Set<Id>{contactList[0].Id}, AccessLevel.SYSTEM_MODE);
            List<Case> caseListToUpdate = new List<Case>();
            for(Case caseRec : caseList){
                if(caseRec.Subject == 'Test Contact Case1'){
                    caseRec.Category__c = 'Applying for a course';
                    caseListToUpdate.add(caseRec);
                }
            }
            CasesDAO.newInstance().updateRecords(caseListToUpdate, true, AccessLevel.SYSTEM_MODE); 

            Test.stopTest();
           
            List<Lead_Score_Detail__c> leadScoreDetails = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsByContactOrLeadId(new Set<Id>{contactList[0].Id}, AccessLevel.SYSTEM_MODE);
            System.assert(leadScoreDetails[0].Total_Lead_Score__c == 10, 'Incorrect Total Lead Score.');
        }        
    }

    @isTest
    public static void processLeadScoreCalculationIntPGTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();

            List<Lead> leadListToUpdate = LeadsDAO.newInstance().getLeadsWithLimit(2);

            List<Case> caseList = CasesDAO.newInstance().getCasesByLeadIds(new Set<Id>{leadListToUpdate[1].Id}, AccessLevel.SYSTEM_MODE);
            List<Case> caseListToUpdate = new List<Case>();
            for(Case caseRec : caseList){
                if(caseRec.Subject == 'Test Case Int1'){
                    caseRec.Category__c = 'Course information';
                    caseListToUpdate.add(caseRec);
                }
            }
            CasesDAO.newInstance().updateRecords(caseListToUpdate, true, AccessLevel.SYSTEM_MODE); 

            Test.stopTest();
           
            List<Lead_Score_Detail__c> leadScoreDetails = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsByContactOrLeadId(new Set<Id>{leadListToUpdate[1].Id}, AccessLevel.SYSTEM_MODE);
            System.assert(leadScoreDetails[0].Total_Lead_Score__c == 5, 'Incorrect Total Lead Score.');
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
                Name = 'Enquiries',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = citizenship,
                Study_Level__c = studyLevel,
                Description__c = '',
                Time_Limit_Months__c = 0,
                Max_Score__c = 10
            )
        );

        LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreCategoryList, true, AccessLevel.SYSTEM_MODE);

        Id categoryId = leadScoreCategoryList[0].Id;

        List<Lead_Score_Configuration__c> leadScoreSubCategoryList = new List<Lead_Score_Configuration__c>();
        leadScoreSubCategoryList.addALl(createDomUGCategoryRecords(citizenship, studyLevel, categoryId));    
        leadScoreSubCategoryList.addALl(createDomPGCategoryRecords(citizenship, studyLevel, categoryId));   
        leadScoreSubCategoryList.addALl(createIntPGCategoryRecords(citizenship, studyLevel, categoryId));   
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

    private static List<Lead_Score_Configuration__c> createDomPGCategoryRecords(String citizenship, String studyLevel, Id categoryId){
        List<Lead_Score_Configuration__c> response = new List<Lead_Score_Configuration__c>();
        if(citizenship == 'Domestic' && studylevel == 'Postgraduate'){
            response.addAll(
                TestDataFactory.createDomstcAndPostGradSubCategory(
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
                TestDataFactory.createInlAndPostGradSubCategory(
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
            'Applying for a course',
            'Entry requirements & study pathways',
            'Fees, costs and scholarships',
            'Course information',
            'My application and offer',
            'My enrolment',
            'Student Life'
        };
    }

    private static List<Integer> getScoreAllocList(){
        return new List<Integer>{ 10, 10, 10, 5, 5, 5, 5 };
    }
}