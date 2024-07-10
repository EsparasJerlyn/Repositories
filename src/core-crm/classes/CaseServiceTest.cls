/**
 * @description Test Class for CaseService
 *
 * @see CaseService
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
      | arsenio.jr.dayrit              | Sept 27,2023          | DEPP-6720              | Created file                                          |
      | roy.nino.s.regala              | Oct 5, 2023           | DEPP-6425              | updated to use DAO Mock                               |
      | johanna.a.gibas                | Nov 24, 2023          | DEPP-7143              | Removed references to Priority on International Tier  |
      | gabriel.p.ventayen             | April 22, 2024        | DEPP-8544	            | change rectype to inbound enquiry and add case type   | 
      | gabriel.p.ventayen             | April 29, 2024        | DEPP-8614	            | add test testInsertEngagementListConfigurationCases   |
      | eccarius.munoz                 | May 21, 2024          | DEPP-8484	            | removed insertEngagementListConfigurationCases        |
 */
@isTest
private class CaseServiceTest {


    @isTest
    private static void testmapExistingContactMatchToCase() {//NOPMD Test method is mocked user not needed

        ImplementationSelector.DAO.setMock(new ContactsDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].MobilePhone = '090909';
        ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
        Test.startTest();
        System.assert(
            !CaseService.mapExistingContactMatchToCase(new Set<String>{ '090909' }).isEmpty(),
            'was not able to get mobile to contacts map'
        );
        Test.stopTest();
    }

    @isTest
    private static void testmapExistingLeadMatchToCase() {//NOPMD Test method is mocked user not needed

        ImplementationSelector.DAO.setMock(new LeadsDAOMock());
        List<Lead> leadList = TestDataFactory.createTestLeadRecords(0, 1);
        leadList[0].MobilePhone = '090909';
        LeadsDAO.newInstance().insertRecords(leadList, false, AccessLevel.USER_MODE);
        Test.startTest();
        System.assert(
            !CaseService.mapExistingLeadMatchToCase(new Set<String>{ '090909' }).isEmpty(),
            'was not able to get mobile to lead map'
        );
        Test.stopTest();
    }

    @isTest
    private static void testUpdateCase() {//NOPMD Test method is mocked user not needed

        ImplementationSelector.DAO.setMock(new CasesDAOMock());
        List<Case> cases = new List<Case>();
        cases.add(new Case(Auto_Priority_Assignment__c = true));
        CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.USER_MODE);
        Test.startTest();
        cases[0].Auto_Priority_Assignment__c = false;
        CaseService.updateCases(cases, AccessLevel.USER_MODE);
        Test.stopTest();
        System.assertEquals(
            false,
            CasesDAO.newInstance()
                    .getCasesByIds(new Set<Id>{ cases[0].Id }, AccessLevel.USER_MODE)[0]
                .Auto_Priority_Assignment__c,
            'case not updated'
        );
    }

    @isTest
    private static void testgetInnerFieldsOfListCases(){//NOPMD Test method is mocked user not needed
        ImplementationSelector.DAO.setMock(new CasesDAOMock());
        List<Case> cases = new List<Case>();
        cases.add(new Case(Auto_Priority_Assignment__c = true));
        CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.USER_MODE);
        Test.startTest();
        cases[0].Auto_Priority_Assignment__c = false;
        System.assert(
            CaseService.getInnerFieldsOfListCases(cases, AccessLevel.USER_MODE) != null,
            'was not able to get case records'
        );
        Test.stopTest();
    }

    @isTest
    private static void testEnqueueCasesToPrioritize() {//NOPMD Test method is mocked user not needed
        
        ImplementationSelector.DAO.setMock(new CasesDAOMock());
        ImplementationSelector.DAO.setMock(new InternationalTiersDAOMock());
        ImplementationSelector.DAO.setMock(new CasePriorityConfigurationsDAOMock());

        CasePriorityConfigurationsDAO.newInstance()
            .insertRecords(
                TestDataFactory.createCasePrioConfigRecords(),
                false,
                AccessLevel.USER_MODE
            );
        InternationalTiersDAO.newInstance()
            .insertRecords(
                TestDataFactory.createInternationalTierRecords(
                    new List<String>{ 'Wales', 'Australia' },
                    'Tier 1',
                    true
                ),
                false,
                AccessLevel.USER_MODE
            );

        List<Case> cases = new List<Case>();
        cases.add(
            new Case(
                Status = 'Created',
                Auto_Priority_Assignment__c = true,
                SuppliedPhone = '090909',
                Origin = CasesDAO.ORIGIN_WHATSAPP,
                RecordTypeId = CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID,
                Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
            )
        );

        CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.USER_MODE);

        Test.startTest();
        CaseService.enqueueCasesToPrioritize(cases, AccessLevel.USER_MODE);
        Test.stopTest();

        System.assertEquals(
            'High',
            CasesDAO.newInstance()
                    .getCasesByIds(new Set<Id>{ cases[0].Id }, AccessLevel.USER_MODE)[0]
                .Priority,
            'Case was not updated'
        );
    }

}
