/**
 * @description Test class for LeadScoreConfigResidenceService
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
private class LeadScoreConfigResidenceServiceTest {

    @isTest
    private static void getLeadScoreConfigTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Residence',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = 'International',
                Study_Level__c = 'Postgraduate',
                Description__c = '',
                Score_Allocation__c = null,
                Time_Limit_Months__c = null,
                Max_Score__c = 10
            )
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

        List<Lead_Score_Configuration__c> leadScoreConfigChildList = TestDataFactory.createInlAndPostGradSubCategory(
            leadScoreConfigList[0].Id,
            new List<String>{ 'Australia (Onshore)', 'Non-Australia (offshore)' },
            new List<Integer>{ 10, 5 }
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);
        LeadScoreConfigResidence leadScoreConfigData;

        for (
            Lead_Score_Configuration__c leadScoreConfig : LeadScoreConfigurationDAO.newInstance()
                .getLeadScoreConfigByRecordTypeIds(
                    AccessLevel.USER_MODE,
                    LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY
                )
        ) {
            boolean isDomestic = leadScoreConfig.Domestic_International__c == 'Domestic';
            leadScoreConfigData = new LeadScoreConfigResidence();
            LeadScoreConfigResidenceService.getLeadScoreConfig(
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
                My_Country_Of_Residency__c = 'Australia'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Lead__c = leadList[0].Id,
                My_Country_Of_Residency__c = 'New Zealand'
            )
        );

        MarketingSegmentationsDAO.newInstance()
            .insertRecords(marSegList, true, AccessLevel.USER_MODE);

        Map<Id, Marketing_Segmentation__c> marSegMap = new Map<Id, Marketing_Segmentation__c>(
            marSegList
        );

        LeadScoreConfigResidence leadScoreConfigRes = new LeadScoreConfigResidence();
        leadScoreConfigRes.setAustraliaOnshore(10);
        leadScoreConfigRes.setNonAustraliaOffShore(10);

        System.assert(
            !LeadScoreConfigResidenceService.calculateLeadScore(
                    marSegMap,
                    leadScoreConfigRes,
                    false
                )
                .isEmpty(),
            'score not calculated'
        );
    }
}
