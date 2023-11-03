/**
 * @description Test Class for LeadScoreResetService
 *
 * @see LeadScoreResetService
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                               |
      |---------------------------|-----------------------|--------------|----------------------------------------------|
      | roy.nino.s.regala         | Nov 03,2023           | DEPP-7145    | Created file                                 |
*/
@isTest
private class LeadScoreResetServiceTest {
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

        LeadScoreResetService.updateLeadScoreResetForMktgInt(contactIdSet);

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

        LeadScoreResetService.updateLeadScoreResetForIndivEmail(contactIdSet);

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
            CasesDAO.DOMESTICFS_RECTYPE_ID,
            'Test Case',
            3
        );

        for (Case caseRec : caseListDomUG) {
            caseRec.ContactId = contactList[0].Id;
        }

        CasesDAO.newInstance().insertRecords(caseListDomUG, true, AccessLevel.SYSTEM_MODE);

        LeadScoreResetService.updateLeadScoreResetForCase(contactIdSet);

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

        LeadScoreResetService.updateLeadScoreResetForProgEng(contactIdSet);

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

        System.assert(
            !LeadScoreResetService.getLeadScoreDetailsToUpdate(contactIdSet).isEmpty(),
            'Lead Score Detaial must exist'
        );
    }
}
