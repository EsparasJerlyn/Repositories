/**
 * @description Service Class for MC Transaction Messaging 
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | roy.nino.s.regala              | July 25, 2024         | DEPP-8551              | Created file                                      |
 */
public with sharing class MCTransactionalMessagingService{

    public class SMSRecipient {
        public String contactKey;
        public String to;
        public String messageKey;
        public Map<String, String> attributes;
    }

    public class SMSRequest {
        public String definitionKey;
        public List<SMSRecipient> recipients;
        public Map<String, String> attributes;
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