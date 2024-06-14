/**
 * @description Test class for MarketingInteractionLeadScoreHelper
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
public with sharing class MarketingInteractionLeadScoreHelperTest {
    @TestSetup
    static void makeData() {
        TestDataFactoryUser.generateUserQUTESB();
        
            Test.startTest();
            setupLeadScoreConfig(
                LeadScoreConfigurationDAO.DOMESTIC,
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD
            );

            setupLeadScoreConfig(
                LeadScoreConfigurationDAO.INTERNATIONAL,
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD
            );

            List<Contact> contactList = new List<Contact>();
            contactList.addAll(
                TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC)
            );
            contactList.addAll(
                TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL)
            );
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);

            List<Lead> leadList = TestDataFactory.createTestLeadRecords(1, 2);
            LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            List<Marketing_Segmentation__c> marketingSegmentationList = MarketingSegmentationsDAO.newInstance()
                .getMarketingSegmentationByContactOrLead(
                    new Set<Id>{ contactList[0].Id, contactList[1].Id},
                    new Set<Id>{ leadList[0].Id },
                    AccessLevel.SYSTEM_MODE
                );
            List<Marketing_Segmentation__c> mktgSegToUpdate = new List<Marketing_Segmentation__c>();
            for (Marketing_Segmentation__c mktgSeg : marketingSegmentationList) {
                mktgSeg.My_Primary_Study_Level__c = 'Undergraduate';
                mktgSeg.My_Citizenship_Status__c = MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_NZ;
                mktgSeg.My_Expected_Admission_Year__c = Integer.valueOf(Date.today().year());
                mktgSegToUpdate.add(mktgSeg);
            }
            MarketingSegmentationsDAO.newInstance()
                .updateRecords(mktgSegToUpdate, true, AccessLevel.SYSTEM_MODE);

            List<Marketing_Interaction__c> marInteractionList = new List<Marketing_Interaction__c>();
            marInteractionList.add(
                new Marketing_Interaction__c(
                    Lead__c = leadList[0].Id,
                    Match_My_Skill_Completion__c = 'Yes'
                )
            );
            MarketingInteractionsDAO.newInstance()
                .insertRecords(marInteractionList, true, AccessLevel.USER_MODE);
        
    }

    @isTest
    public static void processContactLeadScoreCalculationUndergradTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(1);
            List<Marketing_Interaction__c> marInteractionList = new List<Marketing_Interaction__c>();
            marInteractionList.add(
                new Marketing_Interaction__c(
                    Contact__c = contactList[0].Id,
                    Event_Type__c = 'Open Day',
                    Event_Date__c = System.today().addDays(1)
                )
            );
            marInteractionList.add(
                new Marketing_Interaction__c(
                    Contact__c = contactList[0].Id,
                    Lead_Source_Category__C = 'Event',
                    Interaction_DateTime__c = System.today()
                )
            );
            marInteractionList.add(
                new Marketing_Interaction__c(
                    Contact__c = contactList[0].Id,
                    Has_Attended__c = true,
                    Event_Date__c = System.today()
                )
            );
            
            MarketingInteractionsDAO.newInstance()
                .insertRecords(marInteractionList, true, AccessLevel.USER_MODE);
            Test.stopTest();

            List<Lead_Score_Detail__c> leadScoreDetails = LeadScoreDetailsDAO.newInstance()
                .getLeadScoreDetailsByContactOrLeadId(
                    new Set<Id>{ contactList[0].Id },
                    AccessLevel.USER_MODE
                );
            System.assertEquals(
                30,
                leadScoreDetails[0].Total_Lead_Score__c,
                'Incorrect Total Lead Score.'
            );
        }
    }

    @isTest
    public static void processLeadLeadScoreCalculationUndergradTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            List<Marketing_Interaction__c> marInteractionList = new List<Marketing_Interaction__c>();
            marInteractionList.add(
                new Marketing_Interaction__c(
                    Lead__c = leadList[0].Id,
                    Event_Type__c = 'Open Day',
                    Event_Date__c = System.today().addDays(1)
                )
            );
            marInteractionList.add(
                new Marketing_Interaction__c(
                    Lead__c = leadList[0].Id,
                    Lead_Source_Category__C = 'Event',
                    Interaction_DateTime__c = System.today()
                )
            );
            marInteractionList.add(
                new Marketing_Interaction__c(
                    Lead__c = leadList[0].Id,
                    Has_Attended__c = true,
                    Event_Date__c = System.today()
                )
            );
            MarketingInteractionsDAO.newInstance()
                .insertRecords(marInteractionList, true, AccessLevel.USER_MODE);
            Test.stopTest();

            List<Lead_Score_Detail__c> leadScoreDetails = LeadScoreDetailsDAO.newInstance()
                .getLeadScoreDetailsByContactOrLeadId(
                    new Set<Id>{ leadList[0].Id },
                    AccessLevel.USER_MODE
                );
            System.assertEquals(
                30,
                leadScoreDetails[0].Total_Lead_Score__c,
                'Incorrect Total Lead Score.'
            );
        }
    }

    @isTest
    public static void processLeadUpdateLeadScoreCalculationUndergradTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);

            List<Marketing_Interaction__c> marInteractionList = MarketingInteractionsDAO.newInstance()
                .getMarketingInteractionsByContactOrLeadIds(
                    new Set<Id>{ leadList[0].Id },
                    AccessLevel.USER_MODE
                );

            marInteractionList[0].Has_Attended__c = true;
            marInteractionList[0].Event_Date__c = System.today();

            MarketingInteractionsDAO.newInstance()
                .updateRecords(marInteractionList, true, AccessLevel.USER_MODE);

            Test.stopTest();

            List<Lead_Score_Detail__c> leadScoreDetails = LeadScoreDetailsDAO.newInstance()
                .getLeadScoreDetailsByContactOrLeadId(
                    new Set<Id>{ leadList[0].Id },
                    AccessLevel.USER_MODE
                );
            System.assertEquals(
                30,
                leadScoreDetails[0].Total_Lead_Score__c,
                'Incorrect Total Lead Score.'
            );
        }
    }

    private static void setupLeadScoreConfig(String citizenship, String studyLevel) {
        List<Lead_Score_Configuration__c> leadScoreParentConfigList = new List<Lead_Score_Configuration__c>();
        leadScoreParentConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Total Max Score DUG',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG,
                Domestic_International__c = citizenship,
                Study_Level__c = studyLevel
            )
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreParentConfigList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> leadScoreCategoryList = new List<Lead_Score_Configuration__c>();
        leadScoreCategoryList.add(
            new Lead_Score_Configuration__c(
                Parent_Category__c = leadScoreParentConfigList[0].Id,
                Name = 'Event Registration and Attendance',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = citizenship,
                Study_Level__c = studyLevel,
                Description__c = '',
                Time_Limit_Months__c = 0,
                Max_Score__c = 30
            )
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreCategoryList, true, AccessLevel.SYSTEM_MODE);

        Id categoryId = leadScoreCategoryList[0].Id;

        List<Lead_Score_Configuration__c> leadScoreSubCategoryList = new List<Lead_Score_Configuration__c>();
        leadScoreSubCategoryList.addALl(
            createDomUGCategoryRecords(citizenship, studyLevel, categoryId)
        );
        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreSubCategoryList, true, AccessLevel.SYSTEM_MODE);
    }

    private static List<Lead_Score_Configuration__c> createDomUGCategoryRecords(
        String citizenship,
        String studyLevel,
        Id categoryId
    ) {
        List<Lead_Score_Configuration__c> response = new List<Lead_Score_Configuration__c>();
        if (citizenship == 'Domestic' && studylevel == 'Undergraduate') {
            response.addAll(
                TestDataFactory.createDomstcAndUnderGradSubCategory(
                    categoryId,
                    getCategoryList(),
                    getScoreAllocList()
                )
            );
        }else if (citizenship == 'International' && studylevel == 'Undergraduate'){
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

    private static List<String> getCategoryList() {
        return new List<String>{
            'Open Day Registration',
            'Other Event Registration',
            'Other Event Attendance'
        };
    }

    private static List<Integer> getScoreAllocList() {
        return new List<Integer>{ 20, 20, 30 };
    }
}
