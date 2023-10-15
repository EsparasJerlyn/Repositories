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
    private static void isDateWithinRangeTest() {//NOPMD Test method is for service class and user is not needed

        System.assertEquals(
            true,
            DateService.isDateWithinRange(
                System.today().addDays(-2),
                System.today().addDays(2),
                System.today()
            ),
            'Date is not within range'
        );
    }

    @isTest
    private static void isDateWithinRangeDefaultFalseTest() {//NOPMD Test method is for service class and user is not needed

        System.assertEquals(
            false,
            DateService.isDateWithinRange(
                System.today(),
                System.today().addDays(-2),
                System.today().addDays(2)
            ),
            'Date is within range'
        );
    }
}
