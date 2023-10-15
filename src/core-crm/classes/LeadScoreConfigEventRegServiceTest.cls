/**
 * @description Test class for LeadScoreConfigEventRegService
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
private class LeadScoreConfigEventRegServiceTest {
    @isTest
    private static void getLeadScoreConfigTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Event Registration and Attendance',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = 'International',
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
                'Open Day Registration',
                'Other Event Registration',
                'Other Event Attendance'
            },
            new List<Integer>{20,20,30}
        ));

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);
        LeadScoreConfigEventRegistration leadScoreConfigData;

        for (
            Lead_Score_Configuration__c leadScoreConfig : LeadScoreConfigurationDAO.newInstance()
                .getLeadScoreConfigByRecordTypeIds(
                    AccessLevel.USER_MODE,
                    LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY
                )
        ) {
            leadScoreConfigData = new LeadScoreConfigEventRegistration();
            LeadScoreConfigEventRegService.getLeadScoreConfig(
                leadScoreConfig,
                leadScoreConfigData
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
        marInteractionList.add(
            new Marketing_Interaction__c(
                Lead__c = leadList[0].Id,
                Event_Type__c = 'Open Day',
                Event_Date__c = System.today()
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

        Map<Id, Marketing_Interaction__c> marInteractionMap = new Map<Id, Marketing_Interaction__c>(
            marInteractionList
        );
        
        LeadScoreConfigEventRegistration leadScoreConfig = new LeadScoreConfigEventRegistration();
        leadScoreConfig.setEventRegOpenDayReg(5);
        leadScoreConfig.setEventRegOtherEventAttendance(5);
        leadScoreConfig.setEventRegOtherEventReg(5);
        leadScoreConfig.setTimeLimit(10);

        System.assert(
            !LeadScoreConfigEventRegService.calculateLeadScore(
                marInteractionMap,
                    leadScoreConfig
                )
                .isEmpty(),
            'score not calculated'
        );
    }
}
