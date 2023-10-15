/**
 * @description Test class for LeadScoreConfigDownloadPDFService
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
private class LeadScoreConfigDownloadPDFServiceTest {
    @isTest
    private static void getLeadScoreConfigTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Downloaded PDF',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = 'International',
                Study_Level__c = 'Postgraduate',
                Description__c = '',
                Score_Allocation__c = null,
                Time_Limit_Months__c = 36,
                Max_Score__c = 30
            )
        );

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Downloaded PDF',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = 'Domestic',
                Study_Level__c = 'Postgraduate',
                Description__c = '',
                Score_Allocation__c = null,
                Time_Limit_Months__c = 36,
                Max_Score__c = 30
            )
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

        List<Lead_Score_Configuration__c> leadScoreConfigChildList = new List<Lead_Score_Configuration__c>();
        leadScoreConfigChildList.addAll(TestDataFactory.createInlAndPostGradSubCategory(
            leadScoreConfigList[0].Id,
            new List<String>{
                'Course Page PDF',
                'Course Guides'
            },
            new List<Integer>{ 5, 10}
        ));

        leadScoreConfigChildList.addAll(TestDataFactory.createDomstcAndPostGradSubCategory(
            leadScoreConfigList[0].Id,
            new List<String>{
                'Course Page PDF',
                'Welcome Guide'
            },
            new List<Integer>{ 5, 5}
        ));


        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);
        LeadScoreConfigDownloadPDF leadScoreConfigData;

        for (
            Lead_Score_Configuration__c leadScoreConfig : LeadScoreConfigurationDAO.newInstance()
                .getLeadScoreConfigByRecordTypeIds(
                    AccessLevel.USER_MODE,
                    LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY
                )
        ) {
            boolean isDomestic = leadScoreConfig.Domestic_International__c == 'Domestic';
            leadScoreConfigData = new LeadScoreConfigDownloadPDF();
            LeadScoreConfigDownloadPDFService.getLeadScoreConfig(
                leadScoreConfig,
                leadScoreConfigData,
                isDomestic
            );

            System.assert(leadScoreConfigData != null, 'leadScoreConfigData is not popualted');
        }
    }


    @isTest
    private static void calculateLeadScoreTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new MarketingInteractionsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadsDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
        LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.USER_MODE);

        List<Marketing_Interaction__c> marInteractionList = new List<Marketing_Interaction__c>();
        marInteractionList.add(
            new Marketing_Interaction__c(
                Contact__c = contactList[0].Id,
                Lead_Source__c = 'Course Page PDF Download'
            )
        );
        marInteractionList.add(
            new Marketing_Interaction__c(
                Contact__c = contactList[0].Id,
                Lead_Source__c = 'Welcome Guide Download'
            )
        );
        marInteractionList.add(
            new Marketing_Interaction__c(
                Contact__c = contactList[0].Id,
                Lead_Source__c = 'Course Guide Download'
            )
        );
        marInteractionList.add(
            new Marketing_Interaction__c(
                Lead__c = leadList[0].Id,
                Lead_Source__c = 'Course Page PDF Download'
            )
        );
        marInteractionList.add(
            new Marketing_Interaction__c(
                Lead__c = leadList[0].Id,
                Lead_Source__c = 'Welcome Guide Download'
            )
        );
        marInteractionList.add(
            new Marketing_Interaction__c(
                Lead__c = leadList[0].Id,
                Lead_Source__c = 'Course Page PDF Download'
            )
        );

        MarketingInteractionsDAO.newInstance()
        .insertRecords(marInteractionList, true, AccessLevel.USER_MODE);

        Map<Id, Marketing_Interaction__c> marItneractionMap = new Map<Id, Marketing_Interaction__c>(
            marInteractionList
        );
        
        LeadScoreConfigDownloadPDF leadScoreConfig = new LeadScoreConfigDownloadPDF();
        leadScoreConfig.setCourseGuide(10);
        leadScoreConfig.setCoursePagePDF(10);
        leadScoreConfig.setWelcomeGuide(10);

        System.assert(
            !LeadScoreConfigDownloadPDFService.calculateLeadScore(
                marItneractionMap,
                    leadScoreConfig,
                    false
                )
                .isEmpty(),
            'score not calculated'
        );

        System.assert(
            !LeadScoreConfigDownloadPDFService.calculateLeadScore(
                marItneractionMap,
                    leadScoreConfig,
                    true
                )
                .isEmpty(),
            'score not calculated'
        );
    }
}
