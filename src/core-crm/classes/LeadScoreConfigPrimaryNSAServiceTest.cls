/**
 * @description Test class for LeadScoreConfigPrimaryNSAService
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
private class LeadScoreConfigPrimaryNSAServiceTest {
    @isTest
    private static void getLeadScoreConfigTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Primary NSA',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = 'International',
                Study_Level__c = 'Postgraduate',
                Description__c = '',
                Score_Allocation__c = null,
                Time_Limit_Months__c = null,
                Max_Score__c = 5
            )
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

        List<Lead_Score_Configuration__c> leadScoreConfigChildList = TestDataFactory.createInlAndPostGradSubCategory(
            leadScoreConfigList[0].Id,
            new List<String>{
                'Is unsure',
                'Is not blank',
                'Is blank'
            },
            new List<Integer>{ 5, 5, 0}
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);
        LeadScoreConfigPrimaryNSA leadScoreConfigData;

        for (
            Lead_Score_Configuration__c leadScoreConfig : LeadScoreConfigurationDAO.newInstance()
                .getLeadScoreConfigByRecordTypeIds(
                    AccessLevel.USER_MODE,
                    LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY
                )
        ) {
            leadScoreConfigData = new LeadScoreConfigPrimaryNSA();
            LeadScoreConfigPrimaryNSAService.getLeadScoreConfig(
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
                My_Primary_NSA__c = 'I am not sure'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Contact__c = contactList[0].Id,
                My_Primary_NSA__c = ''
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Contact__c = contactList[0].Id,
                My_Primary_NSA__c = null
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Lead__c = leadList[0].Id,
                My_Primary_NSA__c = 'Is not blank'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Lead__c = leadList[0].Id,
                My_Primary_NSA__c = ''
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Lead__c = leadList[0].Id,
                My_Primary_NSA__c = null
            )
        );

        MarketingSegmentationsDAO.newInstance()
        .insertRecords(marSegList, true, AccessLevel.USER_MODE);

        Map<Id, Marketing_Segmentation__c> marSegMap = new Map<Id, Marketing_Segmentation__c>(
            marSegList
        );
        
        LeadScoreConfigPrimaryNSA leadScoreConfig = new LeadScoreConfigPrimaryNSA();
        leadScoreConfig.setIsBlank(10);
        leadScoreConfig.setIsNotBlank(10);
        leadScoreConfig.setIsUnsure(10);

        System.assert(
            !LeadScoreConfigPrimaryNSAService.calculateLeadScore(
                    marSegMap,
                    leadScoreConfig
                )
                .isEmpty(),
            'score not calculated'
        );
    }
}
