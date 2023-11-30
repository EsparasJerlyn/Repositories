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
                    'High',
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
                RecordTypeId = CasesDAO.INTERNATIONALFS_RECTYPE_ID
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

