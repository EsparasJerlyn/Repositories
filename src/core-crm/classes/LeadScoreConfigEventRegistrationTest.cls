/**
 * @description Test class for LeadScoreConfigEventRegistration
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
private class LeadScoreConfigEventRegistrationTest {
    @isTest
    private static void leadScoreConfigEventRegistrationTest() {//NOPMD test class for getter setter, user not needed

        LeadScoreConfigEventRegistration data = new LeadScoreConfigEventRegistration();

        data.setEventRegOpenDayReg(10);
        data.setEventRegOtherEventAttendance(10);
        data.setEventRegOtherEventReg(10);

        System.assertEquals(10, data.getEventRegOpenDayReg(), 'value did not match');
        System.assertEquals(10, data.getEventRegOtherEventAttendance(), 'value did not match');
        System.assertEquals(10, data.getEventRegOtherEventReg(), 'value did not match');
    }
}
