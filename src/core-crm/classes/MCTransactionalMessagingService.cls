/**
 * @description Service Class for MC Transaction Messaging 
 * 
 * @see https://developer.salesforce.com/docs/marketing/marketing-cloud/references/mc_rest_transactional_messaging_sms/
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | roy.nino.s.regala              | July 25, 2024         | DEPP-8551              | Created file                                      |
 */
public with sharing class MCTransactionalMessagingService {
    public static SMSResponse sendSMS(String endPoint, SMSRequest requestPayload) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:MCTransactionalMessaging' + endPoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(JSON.serialize(requestPayload));

            Http http = new Http();
            HttpResponse res = http.send(request);

            if (res.getStatusCode() >= 200 && res.getStatusCode() <= 204) {
                return (SMSResponse) JSON.deserialize(res.getBody(), SMSResponse.class);
            } else {
                SMSResponse errorResponse = new SMSResponse();
                errorResponse.errorcode = res.getStatusCode();
                errorResponse.message = res.getStatus();
                errorResponse.responses = new List<SMSMessageResponse>();
                return errorResponse;
            }
        } catch (Exception e) {
            NebulaLoggerService.logExceptionDetails(
                'Callout Exception caught in method sendSMS in Apex class MCTransactionalMessagingService.',
                e
            );
            SMSResponse errorResponse = new SMSResponse();
            errorResponse.message = e.getMessage();
            errorResponse.responses = new List<SMSMessageResponse>();
            return errorResponse;
        }
    }

    public class SMSRecipient {
        public String to;
        public String messageKey;
        public Map<String, String> attributes;

        public SMSRecipient(String to, String messageKey, Map<String, String> attributes) {
            this.to = to;
            this.messageKey = messageKey;
            this.attributes = attributes;
        }
    }

    public class SMSRequest {
        public String definitionKey;
        public List<SMSRecipient> recipients;
        public Content content;

        public SMSRequest(String definitionKey, List<SMSRecipient> recipients, Content content) {
            this.definitionKey = definitionKey;
            this.recipients = recipients;
            this.content = content;
        }
    }

    public class Content {
        public String message;

        public Content(String message) {
            this.message = message;
        }
    }

    public class SMSResponse {
        public String requestId;
        public Integer errorcode;
        public String message;
        public List<SMSMessageResponse> responses;
    }

    public class SMSMessageResponse {
        public String messageKey;
        public Integer errorcode;
        public String message;
    }
}
