/**
 * @description Test class for LeadScoreConfigCourseLevelService
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | October 06, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
private class LeadScoreConfigCourseLevelServiceTest {
    @isTest
    private static void getLeadScoreConfigTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Course Level',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = 'International',
                Study_Level__c = 'Postgraduate',
                Description__c = '',
                Score_Allocation__c = null,
                Time_Limit_Months__c = null,
                Max_Score__c = 0
            )
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

        List<Lead_Score_Configuration__c> leadScoreConfigChildList = TestDataFactory.createInlAndPostGradSubCategory(
            leadScoreConfigList[0].Id,
            new List<String>{
                'Is blank',
                'Undergraduate',
                'Postgraduate',
                'Higher Degree Research',
                'Exchange and Study Abroad (1 or 2 Semesters Only)',
                'Short courses and Professional Development'
            },
            new List<Integer>{ 0, 0, 0, 0, 0, 0 }
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);
        LeadScoreConfigCourseLevel leadScoreConfigData;

        for (
            Lead_Score_Configuration__c leadScoreConfig : LeadScoreConfigurationDAO.newInstance()
                .getLeadScoreConfigByRecordTypeIds(
                    AccessLevel.USER_MODE,
                    LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY
                )
        ) {
            leadScoreConfigData = new LeadScoreConfigCourseLevel();
            LeadScoreConfigCourseLevelService.getLeadScoreConfig(
                leadScoreConfig,
                leadScoreConfigData
            );

            System.assert(leadScoreConfigData != null, 'leadScoreConfigData is not popualted');
        }
    }


    @isTest
    private static void calculateLeadScoreTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new MarketingSegmentationsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadsDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
        LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.USER_MODE);

        List<Marketing_Segmentation__c> marSegList = new List<Marketing_Segmentation__c>();
        marSegList.add(
            new Marketing_Segmentation__c(
                Contact__c = contactList[0].Id,
                My_Primary_Study_Level__c = 'Undergraduate'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Contact__c = contactList[0].Id,
                My_Primary_Study_Level__c = 'Postgraduate'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Contact__c = contactList[0].Id,
                My_Primary_Study_Level__c = 'Higher Degree Research'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Lead__c = leadList[0].Id,
                My_Primary_Study_Level__c = 'Short Courses and Professional Development'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Lead__c = leadList[0].Id,
                My_Primary_Study_Level__c = 'Exchange and Study Abroad (1 or 2 Semesters Only)'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Lead__c = leadList[0].Id,
                My_Primary_Study_Level__c = ''
            )
        );

        MarketingSegmentationsDAO.newInstance()
        .insertRecords(marSegList, true, AccessLevel.USER_MODE);

        Map<Id, Marketing_Segmentation__c> marSegMap = new Map<Id, Marketing_Segmentation__c>(
            marSegList
        );
        
        LeadScoreConfigCourseLevel leadScoreConfig = new LeadScoreConfigCourseLevel();
        leadScoreConfig.setStudyLevelExchange(10);
        leadScoreConfig.setStudyLevelHigherDeg(10);
        leadScoreConfig.setStudyLevelIsBlank(10);
        leadScoreConfig.setStudyLevelPostGrad(10);
        leadScoreConfig.setStudyLevelShortCoursePD(10);
        leadScoreConfig.setStudyLevelUnderGrad(10);

        System.assert(
            !LeadScoreConfigCourseLevelService.calculateLeadScore(
                    marSegMap,
                    leadScoreConfig
                )
                .isEmpty(),
            'score not calculated'
        );
    }
}
