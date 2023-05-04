/**
 * @description testclass for NebulaLoggerService
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 1, 2023           | DEPP-5567              | Created file
 */
@isTest
private class NebulaLoggerServiceTest {
    @isTest
    // prettier-ignore
    private static void logExceptionDetailsTest(){//NOPMD Service class no need for specific run as user
        Exception e = new TestClassException('test custom error');
        NebulaLoggerService.logExceptionDetails('test error message',e);
    }

    private class TestClassException extends Exception {
    }
}
