/**
 * @description Test Class for LeadScoreService
 *
 * @see LeadScoreService
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                               |
      |---------------------------|-----------------------|--------------|----------------------------------------------|
      | roy.nino.s.regala         | Oct 10,2023           | DEPP-5866    | Created file                                 |
*/
@isTest
private class LeadScoreServiceTest {
    @isTest
    private static void getLeadStatusTest() {// NOPMD Test class is testing service method no user needed
        System.assertEquals('New', LeadScoreService.getLeadStatus(10), 'status not matched');
        System.assertEquals('Engaging', LeadScoreService.getLeadStatus(50), 'status not matched');
        System.assertEquals('Nurturing', LeadScoreService.getLeadStatus(100), 'status not matched');
    }

    @isTest
    private static void updateLeadScoreResetForMktgIntTest() {// NOPMD Test class is testing service method no user needed
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new MarketingInteractionsDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        Set<Id> contactIdSet = new Set<Id>{ contactList[0].Id };

        List<Marketing_Interaction__c> marInteractionList = new List<Marketing_Interaction__c>();
        marInteractionList.add(
            new Marketing_Interaction__c(
                Contact__c = contactList[0].Id,
                Lead_Source__c = 'MMS',
                Match_My_Skill_Completion__c = 'True'
            )
        );

        MarketingInteractionsDAO.newInstance()
            .insertRecords(marInteractionList, true, AccessLevel.USER_MODE);

        LeadScoreService.updateLeadScoreResetForMktgInt(contactIdSet);

        for (
            Marketing_Interaction__c record : MarketingInteractionsDAO.newInstance()
                .getMarketingInteractionsByContactOrLeadIds(contactIdSet, AccessLevel.SYSTEM_MODE)
        ) {
            System.assert(record.Lead_Score_Reset__c, 'Lead Score Reset must be set to true');
        }
    }

    @isTest
    private static void updateLeadScoreResetForIndivEmailTest() {// NOPMD Test class is testing service method no user needed
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new IndividualEmailResultsDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        Set<Id> contactIdSet = new Set<Id>{ contactList[0].Id };

        List<et4ae5__IndividualEmailResult__c> indivEmailListToAdd = new List<et4ae5__IndividualEmailResult__c>();
        indivEmailListToAdd.add(
            new et4ae5__IndividualEmailResult__c(
                et4ae5__Contact__c = contactList[0].Id,
                et4ae5__Opened__c = true,
                et4ae5__NumberOfUniqueClicks__c = 2,
                et4ae5__DateOpened__c = System.Today()
            )
        );

        IndividualEmailResultsDAO.newInstance()
            .insertRecords(indivEmailListToAdd, true, AccessLevel.SYSTEM_MODE);

        LeadScoreService.updateLeadScoreResetForIndivEmail(contactIdSet);

        for (
            et4ae5__IndividualEmailResult__c record : IndividualEmailResultsDAO.newInstance()
                .getIndivEmailResultsByContactOrLeadIds(contactIdSet, AccessLevel.SYSTEM_MODE)
        ) {
            System.assert(record.Lead_Score_Reset__c, 'Lead Score Reset must be set to true');
        }
    }

    @isTest
    private static void updateLeadScoreResetForCaseTest() {// NOPMD Test class is testing service method no user needed
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new CasesDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        Set<Id> contactIdSet = new Set<Id>{ contactList[0].Id };

        List<Case> caseListDomUG = TestDataFactory.createTestCaseRecords(
            CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID,
            'Test Case',
            3
        );

        for (Case caseRec : caseListDomUG) {
            caseRec.ContactId = contactList[0].Id;
            caseRec.Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC;
        }

        CasesDAO.newInstance().insertRecords(caseListDomUG, true, AccessLevel.SYSTEM_MODE);

        LeadScoreService.updateLeadScoreResetForCase(contactIdSet);

        for (
            Case record : CasesDAO.newInstance()
                .getCasesByContactOrLeadIds(contactIdSet, AccessLevel.SYSTEM_MODE)
        ) {
            System.assert(record.Lead_Score_Reset__c, 'Lead Score Reset must be set to true');
        }
    }

    @isTest
    private static void updateLeadScoreResetForProgEngTest() {// NOPMD Test class is testing service method no user needed
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ProgramEnrollmentsDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        Set<Id> contactIdSet = new Set<Id>{ contactList[0].Id };

        List<hed__Program_Enrollment__c> programEnListWithContact = TestDataFactory.createTestProgramEnrollmentRecords(
            1
        );
        for (hed__Program_Enrollment__c prog : programEnListWithContact) {
            prog.hed__Contact__c = contactList[0].Id;
            prog.Enrollment_Status__c = 'Admitted';
        }

        ProgramEnrollmentsDAO.newInstance()
            .insertRecords(programEnListWithContact, true, AccessLevel.SYSTEM_MODE);

        LeadScoreService.updateLeadScoreResetForProgEng(contactIdSet);

        for (
            hed__Program_Enrollment__c record : ProgramEnrollmentsDAO.newInstance()
                .getAllProgramEnrollmentsByContactId(contactIdSet, AccessLevel.SYSTEM_MODE)
        ) {
            System.assert(record.Lead_Score_Reset__c, 'Lead Score Reset must be set to true');
        }
    }

    @isTest
    private static void getLeadScoreDetailsToUpdateTest() {// NOPMD Test class is testing service method no user needed
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadScoreDetailsDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        Set<Id> contactIdSet = new Set<Id>{ contactList[0].Id };

        List<Lead_Score_Detail__c> leadScoreDetailList = new List<Lead_Score_Detail__c>{
            new Lead_Score_Detail__c(Contact__c = contactList[0].Id)
        };

        LeadScoreDetailsDAO.newInstance()
            .insertRecords(leadScoreDetailList, true, AccessLevel.SYSTEM_MODE);

        LeadScoreService.updateLeadScoreRelatedRecords(contactIdSet);

        for (
            Lead_Score_Detail__c record : LeadScoreDetailsDAO.newInstance()
            .getLeadScoreDetailsByContactOrLeadId(contactIdSet, AccessLevel.SYSTEM_MODE)
        ) {
            System.assertEquals(0, record.Country_Tier__c, 'Lead Score Reset must be set to true');
        }
    }
}
