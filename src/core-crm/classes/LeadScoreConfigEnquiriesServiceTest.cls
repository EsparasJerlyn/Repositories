/**
 * @description Test class for LeadScoreConfigEnquiriesService
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
private class LeadScoreConfigEnquiriesServiceTest {
    @isTest
    private static void getLeadScoreConfigTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Enquiries',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = 'International',
                Study_Level__c = 'Undetermined',
                Description__c = '',
                Score_Allocation__c = null,
                Time_Limit_Months__c = 36,
                Max_Score__c = 15
            )
        );


        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

        List<Lead_Score_Configuration__c> leadScoreConfigChildList = new List<Lead_Score_Configuration__c>();
        leadScoreConfigChildList.addAll(TestDataFactory.createInlAndPostGradSubCategory(
            leadScoreConfigList[0].Id,
            new List<String>{
                'Applying for a course',
                'Entry requirements & study pathways',
                'Fees, costs and scholarships',
                'Course information',
                'Course application & offers',
                'Preparing to Study',
                'Student Life'
            },
            new List<Integer>{ 10, 10, 5, 5, 5, 5, 5}
        ));


        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);
        LeadScoreConfigEnquiries leadScoreConfigData;

        for (
            Lead_Score_Configuration__c leadScoreConfig : LeadScoreConfigurationDAO.newInstance()
                .getLeadScoreConfigByRecordTypeIds(
                    AccessLevel.USER_MODE,
                    LeadScoreConfigurationDAO.RECTYPE_IDS_CATEGORY_AND_SUB_CATEGORY
                )
        ) {
            leadScoreConfigData = new LeadScoreConfigEnquiries();
            LeadScoreConfigEnquiriesService.getLeadScoreConfig(
                leadScoreConfig,
                leadScoreConfigData
            );

            System.assert(leadScoreConfigData != null, 'leadScoreConfigData is not popualted');
        }
    }


    @isTest
    private static void calculateLeadScoreTest() {//NOPMD test class is mocked user is not needed

        ImplementationSelector.DAO.setMock(new CasesDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadsDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
        LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.USER_MODE);

        List<Case> caseList = new List<Case>();
        caseList.add(
            new Case(
                ContactId = contactList[0].Id,
                Category__c = 'Applying for a course'
            )
        );
        caseList.add(
            new Case(
                ContactId = contactList[0].Id,
                Category__c = 'Entry requirements & study pathways' 
            )
        );
        caseList.add(
            new Case(
                ContactId = contactList[0].Id,
                Category__c = 'Fees, costs and scholarships'
            )
        );
        caseList.add(
            new Case(
                Lead__c = leadList[0].Id,
                Category__c = 'Course information'
            )
        );
        caseList.add(
            new Case(
                Lead__c = leadList[0].Id,
                Category__c = 'Course application & offers'
            )
        );
        caseList.add(
            new Case(
                Lead__c = leadList[0].Id,
                Category__c = 'Preparing to Study'
            )
        );
        caseList.add(
            new Case(
                Lead__c = leadList[0].Id,
                Category__c = 'Student Life'
            )
        );

        caseList.add(
            new Case(
                Lead__c = leadList[0].Id,
                Category__c = ''
            )
        );


        CasesDAO.newInstance()
        .insertRecords(caseList, true, AccessLevel.USER_MODE);
        
        Map<Id, Case> caseMap = new Map<Id, Case>(
            CasesDAO.newInstance().getCasesByContactOrLeadIds(new Set<Id>{leadList[0].Id, contactList[0].Id}, AccessLevel.SYSTEM_MODE)
        );
        
        LeadScoreConfigEnquiries leadScoreConfig = new LeadScoreConfigEnquiries();
        leadScoreConfig.setApplyingForCourse(10);
        leadScoreConfig.setCourseInformation(10);
        leadScoreConfig.setEntryReqAndUnivStudy(10);
        leadScoreConfig.setFeesCostScholarship(10);
        leadScoreConfig.setMyApplicationAndOffer(10);
        leadScoreConfig.setMyEnrollment(10);
        leadScoreConfig.setStudentLife(10);
        leadScoreConfig.setTimeLimit(36);

        System.assert(
            !LeadScoreConfigEnquiriesService.calculateLeadScore(
                    caseMap,
                    leadScoreConfig
                )
                .isEmpty(),
            'score not calculated'
        );
    }
}
