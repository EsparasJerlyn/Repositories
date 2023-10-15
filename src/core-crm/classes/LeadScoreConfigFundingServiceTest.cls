/**
 * @description Test class for LeadScoreConfigFundingService
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
private class LeadScoreConfigFundingServiceTest {
    @isTest
    private static void getLeadScoreConfigTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Funding',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = 'International',
                Study_Level__c = 'Postgraduate',
                Description__c = '',
                Score_Allocation__c = null,
                Time_Limit_Months__c = null,
                Max_Score__c = 20
            )
        );

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Funding',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = 'Domestic',
                Study_Level__c = 'Postgraduate',
                Description__c = '',
                Score_Allocation__c = null,
                Time_Limit_Months__c = null,
                Max_Score__c = 20
            )
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

        List<Lead_Score_Configuration__c> leadScoreConfigChildList = new List<Lead_Score_Configuration__c>();
        leadScoreConfigChildList.addAll(TestDataFactory.createInlAndPostGradSubCategory(
            leadScoreConfigList[0].Id,
            new List<String>{
                'I will fund my studies myself',
                'My family will fund my studies',
                'I already have a scholarship, loan or sponsorship',
                'I am not sure',
                'I need a full scholarship'
            },
            new List<Integer>{ 20, 20, 20, 5, -20}
        ));

        leadScoreConfigChildList.addAll(TestDataFactory.createDomstcAndPostGradSubCategory(
            leadScoreConfigList[0].Id,
            new List<String>{
                'Company Funded'
            },
            new List<Integer>{ 20}
        ));


        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);
        LeadScoreConfigFunding leadScoreConfigData;

        for (
            Lead_Score_Configuration__c leadScoreConfig : LeadScoreConfigurationDAO.newInstance()
                .getLeadScoreConfigByRecordTypeIds(
                    AccessLevel.USER_MODE,
                    LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY
                )
        ) {
            boolean isDomestic = leadScoreConfig.Domestic_International__c == 'Domestic';
            leadScoreConfigData = new LeadScoreConfigFunding();
            LeadScoreConfigFundingService.getLeadScoreConfig(
                leadScoreConfig,
                leadScoreConfigData,
                isDomestic
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
                My_Funding_Source__c = 'I will fund my studies myself'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Contact__c = contactList[0].Id,
                My_Funding_Source__c = 'My family will fund my studies'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Contact__c = contactList[0].Id,
                My_Funding_Source__c = 'I already have a scholarship, loan or sponsorship'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Lead__c = leadList[0].Id,
                My_Funding_Source__c = 'I am not sure'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Lead__c = leadList[0].Id,
                My_Funding_Source__c = 'I need a full scholarship'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Lead__c = leadList[0].Id,
                My_Funding_Source__c = ''
            )
        );

        MarketingSegmentationsDAO.newInstance()
        .insertRecords(marSegList, true, AccessLevel.USER_MODE);

        Map<Id, Marketing_Segmentation__c> marSegMap = new Map<Id, Marketing_Segmentation__c>(
            marSegList
        );
        
        LeadScoreConfigFunding leadScoreConfig = new LeadScoreConfigFunding();
        leadScoreConfig.setCompanyFunded(10);
        leadScoreConfig.setIAlreadyHaveScholarship(10);
        leadScoreConfig.setIAmNotSure(10);
        leadScoreConfig.setINeedFullScholarship(10);
        leadScoreConfig.setIWillFundMyself(10);
        leadScoreConfig.setMyFamilyWillFundMyStudy(10);

        System.assert(
            !LeadScoreConfigFundingService.calculateLeadScore(
                marSegMap,
                    leadScoreConfig,
                    false
                )
                .isEmpty(),
            'score not calculated'
        );

        System.assert(
            !LeadScoreConfigFundingService.calculateLeadScore(
                marSegMap,
                    leadScoreConfig,
                    true
                )
                .isEmpty(),
            'score not calculated'
        );
    }
}
