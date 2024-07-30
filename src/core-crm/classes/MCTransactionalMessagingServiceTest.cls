/**
 * @description test class for MCTransactionalMessagingService
 * 
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | roy.nino.s.regala              | July 25, 2024         | DEPP-8551              | Created file                                      |
 */
@isTest
public with sharing class MCTransactionalMessagingServiceTest {
    @isTest
    public static void sendBulkSMSTest() {

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<MCTransactionalMessagingService.SMSRecipient> recipientList = new List<MCTransactionalMessagingService.SMSRecipient>();
        MCTransactionalMessagingService.Content content = new MCTransactionalMessagingService.Content(
            '%%message%%'
        );
        
        MCTransactionalMessagingService.SMSRequest requestPayload;

        Map<String, String> attributes;
        Set<String> numbers = new Set<String>{ '1234566', '1234567' };

        String messageKey;

        for (String mobile : numbers) {
            messageKey = mobile;
            attributes = new Map<String, String>{ 'message' => 'Test Message' };

            recipientList.add(
                new MCTransactionalMessagingService.SMSRecipient(mobile, messageKey, attributes)
            );
        }

        requestPayload = new MCTransactionalMessagingService.SMSRequest(
            'TestDefinitionKey', // MC Definition Key
            recipientList,
            content
        );

        // bulk mc messaging
        MCTransactionalMessagingService.SMSResponse smsResponse = MCTransactionalMessagingService.sendBulkSMS(
            requestPayload
        );

        System.debug(JSON.serializePretty(smsResponse));
    }

    @isTest
    public static void sendBulkSMSExceptionTest() {
        List<MCTransactionalMessagingService.SMSRecipient> recipientList = new List<MCTransactionalMessagingService.SMSRecipient>();
        MCTransactionalMessagingService.Content content = new MCTransactionalMessagingService.Content(
            '%%message%%'
        );
        MCTransactionalMessagingService.SMSRequest requestPayload;

        Map<String, String> attributes;
        Set<String> numbers = new Set<String>{ '1234566', '1234567' };

        String messageKey;

        for (String mobile : numbers) {
            messageKey = mobile;
            attributes = new Map<String, String>{ 'message' => 'Test Message' };

            recipientList.add(
                new MCTransactionalMessagingService.SMSRecipient(mobile, messageKey, attributes)
            );
        }

        requestPayload = new MCTransactionalMessagingService.SMSRequest(
            'TestDefinitionKey', // MC Definition Key
            recipientList,
            content
        );

        // bulk mc messaging
        MCTransactionalMessagingService.SMSResponse smsResponse = MCTransactionalMessagingService.sendBulkSMS(
            requestPayload
        );

        System.assertEquals(
            'Methods defined as TestMethod do not support Web service callouts',
            smsResponse.message,
            'Error message should match'
        );
    }
}
