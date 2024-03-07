/**
 * @description Test class for LeadScoreConfigCountryTierService
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
      | roy.nino.s.regala              | October 06, 2023      | DEPP-5866              | Created file                                          |
      | johanna.a.gibas                | Nov 24, 2023          | DEPP-7143              | Removed references to Priority on International Tier  |
      |                                |                       |                        |     and added Developed Nations sub category          |
 */
@isTest
private class LeadScoreConfigCountryTierServiceTest {
    @isTest
    private static void getLeadScoreConfigTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Country Tier',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = 'International',
                Study_Level__c = 'Postgraduate',
                Description__c = '',
                Score_Allocation__c = null,
                Time_Limit_Months__c = null,
                Max_Score__c = 30
            )
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

        List<Lead_Score_Configuration__c> leadScoreConfigChildList = TestDataFactory.createInlAndPostGradSubCategory(
            leadScoreConfigList[0].Id,
            new List<String>{
                'Country Tier1',
                'Country Tier2',
                'Country Tier3',
                'Untiered nationality - unrestricted cohort (ex. developed countries)',
                'Untiered nationality - restricted cohort, Australian',
                'Developed Nations',
                'Unlisted'
            },
            new List<Integer>{ 30, 20, 10, 5, 5, 20, 5 }
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);
        LeadScoreConfigCountryTier leadScoreConfigData;

        for (
            Lead_Score_Configuration__c leadScoreConfig : LeadScoreConfigurationDAO.newInstance()
                .getLeadScoreConfigByRecordTypeIds(
                    AccessLevel.USER_MODE,
                    LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY
                )
        ) {
            boolean isDomestic = leadScoreConfig.Domestic_International__c == 'Domestic';
            leadScoreConfigData = new LeadScoreConfigCountryTier();
            LeadScoreConfigCountryTierService.getLeadScoreConfig(
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
        ImplementationSelector.DAO.setMock(new InternationalTiersDAOMock());

        List<International_Tier__c> internationalTiers = new List<International_Tier__c>();
        internationalTiers.addAll(
            TestDataFactory.createInternationalTierRecords(
                new List<String>{ 'Australia1' },
                'Tier 1',
                true
            )
        );
        internationalTiers.addAll(
            TestDataFactory.createInternationalTierRecords(
                new List<String>{ 'Australia2' },
                'Tier 2',
                true
            )
        );
        internationalTiers.addAll(
            TestDataFactory.createInternationalTierRecords(
                new List<String>{ 'Australia3' },
                'Tier 3',
                true
            )
        );
        International_Tier__c untieredRestricted = TestDataFactory.createInternationalTierRecords(
            new List<String>{ 'Yemen' },
            'Untiered',
            true
        )[0];
        untieredRestricted.Tier_Subcategory__c = 'Restricted';
        internationalTiers.add(untieredRestricted);

        International_Tier__c untieredUnRestricted = TestDataFactory.createInternationalTierRecords(
            new List<String>{ 'Uruguay' },
            'Untiered',
            true
        )[0];
        untieredUnRestricted.Tier_Subcategory__c = 'Unrestricted';
        internationalTiers.add(untieredUnRestricted);

        InternationalTiersDAO.newInstance()
            .insertRecords(internationalTiers, true, AccessLevel.SYSTEM_MODE);

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
        LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.USER_MODE);

        List<Marketing_Segmentation__c> marSegList = new List<Marketing_Segmentation__c>();
        marSegList.add(
            new Marketing_Segmentation__c(
                Contact__c = contactList[0].Id,
                My_Country_Of_Citizenship__c = 'Australia1'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Contact__c = contactList[0].Id,
                My_Country_Of_Citizenship__c = 'Australia2'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Contact__c = contactList[0].Id,
                My_Country_Of_Citizenship__c = 'Australia3'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Lead__c = leadList[0].Id,
                My_Country_Of_Citizenship__c = 'Australia'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Lead__c = leadList[0].Id,
                My_Country_Of_Citizenship__c = 'New Zealand'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Lead__c = leadList[0].Id,
                My_Country_Of_Citizenship__c = 'Yemen'
            )
        );
        marSegList.add(
            new Marketing_Segmentation__c(
                Lead__c = leadList[0].Id,
                My_Country_Of_Citizenship__c = 'Uruguay'
            )
        );

        MarketingSegmentationsDAO.newInstance()
        .insertRecords(marSegList, true, AccessLevel.USER_MODE);

        LeadScoreConfigCountryTier leadScoreConfig = new LeadScoreConfigCountryTier();
        leadScoreConfig.setCountryTier1(10);
        leadScoreConfig.setCountryTier2(10);
        leadScoreConfig.setCountryTier3(10);
        leadScoreConfig.setUntieredRestricted(10);
        leadScoreConfig.setUntieredUnrestricted(10);
        leadScoreConfig.setDevelopedNations(10);
        leadScoreConfig.setUnlisted(5);

        System.assert(
            !LeadScoreConfigCountryTierService.calculateLeadScore(
                    new Map<Id, Marketing_Segmentation__c>(marSegList),
                    leadScoreConfig,
                    false
                )
                .isEmpty(),
            'score not calculated'
        );
    }
}
