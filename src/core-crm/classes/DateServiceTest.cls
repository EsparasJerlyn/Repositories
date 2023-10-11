/**
 * @description Test Class for DateService
 *
 * @see DateService
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
private class DateServiceTest {
    @isTest
    private static void isDateWithinRangeTest() {
        //NOPMD Test method is mocked user not needed

        ImplementationSelector.DAO.setMock(new CasesDAOMock());

        List<Case> cases = new List<Case>();
        cases.add(
            new Case(
                Status = 'Created',
                Auto_Priority_Assignment__c = true,
                RecordTypeId = CasesDAO.INTERNATIONALFS_RECTYPE_ID
            )
        );

        CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.USER_MODE);
        Case caseRecord = CasesDAO.newInstance()
            .getCasesByIds(new Set<Id>{ cases[0].Id }, AccessLevel.USER_MODE)[0];

        System.assertEquals(
            true,
            DateService.isDateWithinRange(
                System.today().addDays(-2),
                System.today().addDays(2),
                date.newinstance(
                    caseRecord.CreatedDate.year(),
                    caseRecord.CreatedDate.month(),
                    caseRecord.CreatedDate.day()
                )
            ),
            'Date is not within range'
        );
    }
}
