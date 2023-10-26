/**
 * @description Test class for LeadScoreStudyLevelCommand
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
private class LeadScoreStudyLevelCommandTest {
    @isTest
    private static void processStudyLevelForCaseTest() { //NOPMD test class is mocked user is not needed
        
        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());
        ImplementationSelector.DAO.setMock(new CasesDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadScoreDetailsDAOMock());
        ImplementationSelector.DAO.setMock(new MarketingSegmentationsDAOMock());

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Enquiries',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = 'Domestic',
                Study_Level__c = 'Undergraduate',
                Description__c = '',
                Score_Allocation__c = null,
                Time_Limit_Months__c = 36,
                Max_Score__c = 15
            )
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

        List<Lead_Score_Configuration__c> leadScoreConfigChildList = new List<Lead_Score_Configuration__c>();
        leadScoreConfigChildList.addAll(
            TestDataFactory.createDomstcAndUnderGradSubCategory(
                leadScoreConfigList[0].Id,
                new List<String>{
                    'Applying for a course'
                },
                new List<Integer>{ 10, 10, 5, 5, 5, 5, 5 }
            )
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        List<Case> caseList = new List<Case>();
        caseList.add(
            new Case(ContactId = contactList[0].Id, Category__c = 'Applying for a course')
        );

        CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.USER_MODE);

        LeadScoreDetailsDAO.newInstance()
            .insertRecords(
                new List<Lead_Score_Detail__c>{
                    new Lead_Score_Detail__c(Contact__c = contactList[0].Id)
                },
                false,
                AccessLevel.USER_MODE
            );

        Set<Id> contactIds = new Set<Id>{ contactList[0].Id};

        LeadScoreCalculatorService.LeadScoreCalculatorParams leadScoreCalcParams = new LeadScoreCalculatorService.LeadScoreCalculatorParams(
            Case.sObjectType,
            new Map<Id, Case>(CasesDAO.newInstance().getCasesByContactOrLeadIds(contactIds, AccessLevel.SYSTEM_MODE)),
            LeadScoreConfigurationDAO.newInstance()
                .getLeadScoreConfigByRecordTypeIds(
                    AccessLevel.USER_MODE,
                    LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY
                ),
                contactIds
        );

        System.assert(
            !LeadScoreUndergradDomCmd.processStudyLevel(leadScoreCalcParams).isEmpty(),
            'Was not able to calcualte lead score details'
        );
    }
}
