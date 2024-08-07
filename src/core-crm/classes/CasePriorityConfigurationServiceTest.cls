/**
 * @description Test Class for CasePriorityConfigurationService
 *
 * @see CasePriorityConfigurationService
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
      | roy.nino.s.regala              | Oct 5, 2023           | DEPP-6425              | Created file                                          |
      | johanna.a.gibas                | Nov 24, 2023          | DEPP-7143              | Removed references to Priority on International Tier  |
      | eccarius.munoz                 | February 16, 2024     | DEPP-7714	            | Added test method of case prio with sub category      | 
      | eccarius.munoz                 | February 19, 2024     | DEPP-7867	            | Added test method of case prio with lead src category | 
      | gabriel.p.ventayen             | April 22, 2024        | DEPP-8544	            | change rectype to inbound enquiry and add case type   | 
 */
@isTest
private class CasePriorityConfigurationServiceTest {
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

    @isTest
    private static void testEnqueueCasesToPrioritizeWithTierSubCateg() {//NOPMD Test method is mocked user not needed
        
        ImplementationSelector.DAO.setMock(new CasesDAOMock());
        ImplementationSelector.DAO.setMock(new InternationalTiersDAOMock());
        ImplementationSelector.DAO.setMock(new CasePriorityConfigurationsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].Citizenship_Country__c = 'Yemen';
        contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        CasePriorityConfigurationsDAO.newInstance()
            .insertRecords(
                TestDataFactory.createCasePrioConfigRecords(),
                false,
                AccessLevel.USER_MODE
            );

        List<International_Tier__c> internationalTiers = new List<International_Tier__c>();
        International_Tier__c internationalTiersWithSubCateg = TestDataFactory.createInternationalTierRecords(
            new List<String>{ 'Yemen' },
            'Untiered',
            true
        )[0];
        internationalTiersWithSubCateg.Tier_Subcategory__c = 'Unrestricted';
        internationalTiers.add(internationalTiersWithSubCateg);

        InternationalTiersDAO.newInstance().insertRecords(internationalTiers, false, AccessLevel.USER_MODE);
        
        List<Case> cases = new List<Case>();
        cases.add(
            new Case(
                Status = 'Created',
                Auto_Priority_Assignment__c = true,
                Origin = CasesDAO.ORIGIN_WHATSAPP,
                Priority = 'Low',
                ContactId = contactList[0].Id,
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

    @isTest
    private static void testEnqueueCasesToPrioritizeWithLeadSourceCategory() {//NOPMD Test method is mocked user not needed
        
        ImplementationSelector.DAO.setMock(new CasesDAOMock());
        ImplementationSelector.DAO.setMock(new InternationalTiersDAOMock());
        ImplementationSelector.DAO.setMock(new CasePriorityConfigurationsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        contactList[0].Lead_Source_Category__c = 'Partner Sourced';
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);

        CasePriorityConfigurationsDAO.newInstance()
            .insertRecords(
                TestDataFactory.createCasePrioConfigRecords(),
                false,
                AccessLevel.USER_MODE
            );

        
        List<Case> cases = new List<Case>();
        cases.add(
            new Case(
                Status = 'Created',
                Auto_Priority_Assignment__c = true,
                Category__c = 'Student Life',
                Origin = CasesDAO.ORIGIN_WHATSAPP,
                Priority = 'Low',
                ContactId = contactList[0].Id,
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