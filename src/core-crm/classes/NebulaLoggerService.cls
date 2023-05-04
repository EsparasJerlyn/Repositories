/**
 * @description service class for product request. contains reusable methods related to the product request object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 01, 2023          | DEPP-5567              | Created file
 */
public with sharing class NebulaLoggerService {
    public static void logExceptionDetails(String errorMessage, Exception errorDetails) {
        Logger.error(errorMessage).setExceptionDetails(errorDetails);
        if (Logger.getBufferSize() > 0) {
            Logger.saveLog();
        }
    }
}
