/**
 * @description Test Class for InternationalTierService
 *
 * @see InternationalTierService
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
      | roy.nino.s.regala              | Oct 5, 2023           | DEPP-6425              | Created File                                          |
 */
@isTest
private class InternationalTierServiceTest {
    @isTest
    private static void getCountryTierMapTest() {//NOPMD Test method is mocked user not needed

        ImplementationSelector.DAO.setMock(new InternationalTiersDAOMock());

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

        Test.startTest();
        System.assert(
            !InternationalTierService.getCountryTierMap(AccessLevel.USER_MODE).isEmpty(),
            'was not able to get international tier service'
        );
        Test.stopTest();
    }
}
