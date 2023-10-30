/**
 * @description Test class for LeadScoreConfigMktgConsentService
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
private class LeadScoreConfigMktgConsentServiceTest {
    @isTest
    private static void getLeadScoreConfigTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Marketing Consent',
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

        List<Lead_Score_Configuration__c> leadScoreConfigChildList = new List<Lead_Score_Configuration__c>();
        leadScoreConfigChildList.addAll(TestDataFactory.createInlAndPostGradSubCategory(
            leadScoreConfigList[0].Id,
            new List<String>{
                'Yes',
                'Is blank'
            },
            new List<Integer>{10,0}
        ));

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);
        LeadScoreConfigMktgConsent leadScoreConfigData;

        for (
            Lead_Score_Configuration__c leadScoreConfig : LeadScoreConfigurationDAO.newInstance()
                .getLeadScoreConfigByRecordTypeIds(
                    AccessLevel.USER_MODE,
                    LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY
                )
        ) {
            leadScoreConfigData = new LeadScoreConfigMktgConsent();
            LeadScoreConfigMktgConsentService.getLeadScoreConfig(
                leadScoreConfig,
                leadScoreConfigData
            );

            System.assert(leadScoreConfigData != null, 'leadScoreConfigData is not popualted');
        }
    }


    @isTest
    private static void calculateLeadScoreTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadsDAOMock());

        List<Contact> contactList = new List<Contact>();

        contactList.add(new Contact(Email_Opt_In_DateTime__c = System.Today()));
        contactList.add(new Contact());

        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        Map<Id,Contact> contactMap = new Map<Id,Contact>(contactList);

        List<Lead> leadList = new List<Lead>();

        leadList.add(new Lead(Email_Opt_In_DateTime__c = System.Today()));
        leadList.add(new Lead());

        LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.USER_MODE);

        Map<Id,Lead> leadMap = new Map<Id,Lead>(leadList);
        
        LeadScoreConfigMktgConsent leadScoreConfig = new LeadScoreConfigMktgConsent();
        leadScoreConfig.setIsBlank(10);
        leadScoreConfig.setYes(10);

        System.assert(
            !LeadScoreConfigMktgConsentService.calculateLeadScoreForContact(
                    contactMap,
                    leadScoreConfig
                )
                .isEmpty(),
            'score not calculated'
        );

        System.assert(
            !LeadScoreConfigMktgConsentService.calculateLeadScoreForLead(
                    leadMap,
                    leadScoreConfig
                )
                .isEmpty(),
            'score not calculated'
        );
    }
}
