/**
 * @description Test class for LeadScoreConfigEmailInteractService
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 26, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class LeadScoreConfigEmailInteractServiceTest {

    @isTest
    private static void getLeadScoreConfigTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Email Interaction',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = 'Domestic',
                Study_Level__c = 'Undetermined',
                Description__c = '',
                Score_Allocation__c = null,
                Time_Limit_Months__c = 3,
                Max_Score__c = 30
            )
        );
        
        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

        List<Lead_Score_Configuration__c> leadScoreConfigChildList = new List<Lead_Score_Configuration__c>();
        leadScoreConfigChildList.addAll(TestDataFactory.createDomestcAndUndeterminedSubCategory(
            leadScoreConfigList[0].Id,
            new List<String>{
                'Has Clicked Email'
            },
            new List<Integer>{ 10 }
        ));

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);
        
        LeadScoreConfigEmailInteract leadScoreConfigData;

        for (
            Lead_Score_Configuration__c leadScoreConfig : LeadScoreConfigurationDAO.newInstance()
                .getLeadScoreConfigByRecordTypeIds(
                    AccessLevel.USER_MODE,
                    LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY
                )
        ) {
            leadScoreConfigData = new LeadScoreConfigEmailInteract();
            LeadScoreConfigEmailInteractService.getLeadScoreConfig(
                leadScoreConfig,
                leadScoreConfigData
            );

            System.assert(leadScoreConfigData != null, 'leadScoreConfigData is not popualted');
        }
    }


    @isTest
    private static void calculateLeadScoreTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new IndividualEmailResultsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadsDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
        LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.USER_MODE);

        List<et4ae5__IndividualEmailResult__c> indivEmailList = new List<et4ae5__IndividualEmailResult__c>();
        indivEmailList.add(
            new et4ae5__IndividualEmailResult__c(
                et4ae5__Contact__c = contactList[0].Id, 
                et4ae5__Opened__c = true,
                et4ae5__NumberOfUniqueClicks__c	= 5,
                et4ae5__DateOpened__c = System.Today()
            )
        );

        indivEmailList.add(
            new et4ae5__IndividualEmailResult__c(
                et4ae5__Lead__c = leadList[0].Id, 
                et4ae5__Opened__c = true,
                et4ae5__NumberOfUniqueClicks__c	= 2,
                et4ae5__DateOpened__c = System.Today()
            )
        );

        IndividualEmailResultsDAO.newInstance().insertRecords(indivEmailList, true, AccessLevel.USER_MODE);

        Map<Id, et4ae5__IndividualEmailResult__c> indivEmailMap = new Map<Id, et4ae5__IndividualEmailResult__c>(
            indivEmailList
        );
        
        LeadScoreConfigEmailInteract leadScoreConfig = new LeadScoreConfigEmailInteract();
        leadScoreConfig.setHasClickedEmail(10);
        leadScoreConfig.setTimeLimit(3);

        System.assert(
            !LeadScoreConfigEmailInteractService.calculateLeadScore(
                indivEmailMap,
                leadScoreConfig
            ).isEmpty(),
            'score not calculated'
        );
        
    }
}