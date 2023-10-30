/**
 * @description Test class for LeadScoreCalculatorService
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
private class LeadScoreCalculatorServiceTest {
    @isTest
    private static void calculatorLeadScoreTest() { //NOPMD test class is mocked user is not needed
        
        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());
        ImplementationSelector.DAO.setMock(new CasesDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadScoreDetailsDAOMock());
        ImplementationSelector.DAO.setMock(new MarketingSegmentationsDAOMock());

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Enquiries',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = 'Domestic',
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
        leadScoreConfigChildList.addAll(
            TestDataFactory.createDomestcAndUndeterminedSubCategory(
                leadScoreConfigList[0].Id,
                new List<String>{
                    'Applying for a course',
                    'Entry requirements & study pathways',
                    'Fees, costs and scholarships',
                    'Course information',
                    'My application and offer',
                    'My enrolment',
                    'Student Life'
                },
                new List<Integer>{ 10, 10, 5, 5, 5, 5, 5 }
            )
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigChildList, true, AccessLevel.USER_MODE);

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
        LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.USER_MODE);

        List<Case> caseList = new List<Case>();
        caseList.add(
            new Case(ContactId = contactList[0].Id, Category__c = 'Applying for a course')
        );
        caseList.add(new Case(Lead__c = leadList[0].Id, Category__c = 'Course information'));

        CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.USER_MODE);

        Set<Id> contactAndLeadIds = LeadScoreCalculatorService.mergeContactAndLeadIdsIntoOneSet(new Set<Id>{contactList[0].Id}, new Set<Id>{leadList[0].Id});

        LeadScoreCalculatorService.ObjectMap objectMap = new LeadScoreCalculatorService.ObjectMap();
        objectMap.domesticUndeterminedMap = new Map<Id, Case>(CasesDAO.newInstance().getCasesByContactOrLeadIds(contactAndLeadIds, AccessLevel.SYSTEM_MODE));
        objectMap.domesticPostGradMap = new Map<Id, Case>(new List<Case>());
        objectMap.domesticUnderGradMap = new Map<Id, Case>(new List<Case>());        
        objectMap.internationalPostGradMap = new Map<Id, Case>(new List<Case>());
        objectMap.internationalUnderGradMap = new Map<Id, Case>(new List<Case>());
        objectMap.internationalUndeterminedMap = new Map<Id, Case>(new List<Case>());
        objectMap.undeterminedUndeterminedMap = new Map<Id, Case>(new List<Case>());

        LeadScoreCalculatorService.calculateLeadScore(objectMap, contactAndLeadIds, Case.sObjectType);

        System.assert(!LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsByContactOrLeadId(contactAndLeadIds,AccessLevel.USER_MODE).isEmpty(),'lead score detail is not created');
            
    }

    @isTest
    private static void calculatorLeadScoreErrorTest() { //NOPMD test class is mocked user is not needed
        ImplementationSelector.DAO.setMock(new CasesDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadScoreDetailsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadScoreConfigurationDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        List<Case> caseList = new List<Case>();
        caseList.add(
            new Case(ContactId = contactList[0].Id, Category__c = 'Applying for a course')
        );

        CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.USER_MODE);

        Set<Id> contactAndLeadIds = new Set<Id>{ contactList[0].Id};

        LeadScoreCalculatorService.calculateLeadScore(null, contactAndLeadIds, Case.sObjectType);

        System.assert(LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsByContactOrLeadId(contactAndLeadIds,AccessLevel.USER_MODE).isEmpty(),'lead score detail is not created');
    }

    @isTest
    private static void processStudyLevelForMarSegTest() {//NOPMD test class is mocked user is not needed
        
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
                My_Country_Of_Residency__c = 'Australia',
                My_Funding_Source__c = 'I need a full scholarship'
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

        System.assert(
            !LeadScoreCalculatorService.getMarketingSegmentation(new Set<Id>{contactList[0].Id}, new Set<Id>{leadList[0].Id}).isEmpty(),
            'Was not able to get Marketing Segmentation'
        );
    }

}
