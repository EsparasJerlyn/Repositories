/**
 * @description Test class for LeadScoreConfigProgEngagmentService
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
private class LeadScoreConfigProgEngagmentServiceTest {
    @isTest
    private static void getLeadScoreConfigTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Program Engagement',
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
                'Program Engagement attendance'
            },
            new List<Integer>{ 30 }
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);
            LeadScoreConfigProgEngagment leadScoreConfigData;

        for (
            Lead_Score_Configuration__c leadScoreConfig : LeadScoreConfigurationDAO.newInstance()
                .getLeadScoreConfigByRecordTypeIds(
                    AccessLevel.USER_MODE,
                    LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY
                )
        ) {
            leadScoreConfigData = new LeadScoreConfigProgEngagment();
            LeadScoreConfigProgEngagmentService.getLeadScoreConfig(
                leadScoreConfig,
                leadScoreConfigData
            );

            System.assert(leadScoreConfigData != null, 'leadScoreConfigData is not popualted');
        }
    }


    @isTest
    private static void calculateLeadScoreTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new AccountsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ProgramEnrollmentsDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Test', Program_Code__c = 'QC19', RecordTypeId = AccountsDAO.ACCT_ACADEMIC_PROGRAM_ID));

        AccountsDAO.newInstance().insertRecords(accountList,false,AccessLevel.USER_MODE);
        
        List<hed__Program_Enrollment__c> progEnrolmentList = new List<hed__Program_Enrollment__c>();
        progEnrolmentList.add(
            new hed__Program_Enrollment__c(
                hed__Account__c = accountList[0].Id,
                hed__Contact__c = contactList[0].Id
            )
        );

        ProgramEnrollmentsDAO.newInstance()
        .insertRecords(progEnrolmentList, true, AccessLevel.USER_MODE);

        Map<Id, hed__Program_Enrollment__c> progEnrolmentMap = new Map<Id, hed__Program_Enrollment__c>(
            progEnrolmentList
        );
        
        LeadScoreConfigProgEngagment leadScoreConfig = new LeadScoreConfigProgEngagment();
        leadScoreConfig.setProgramEngAttendance(10);

        System.assert(
            !LeadScoreConfigProgEngagmentService.calculateLeadScore(
                progEnrolmentMap,
                    leadScoreConfig
                )
                .isEmpty(),
            'score not calculated'
        );
    }
}
