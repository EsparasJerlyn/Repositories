/**
 * @description Calls Marketing Cloud Transactional Messaging OTP
 * @see ../lwc/registrationForm
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                    |
      |---------------------------|-----------------------|----------------------|-----------------------------------|
      | john.bo.a.pineda          | June 01, 2022         | DEPP-1661            | Created file                      |
      |                           |                       |                      |                                   |
 */
public with sharing class MCTransactionalMessagingOTP {

  private static final MC_Messaging_OTP_Setting__c OTP_CREDENTIAL = MC_Messaging_OTP_Setting__c.getOrgDefaults();

  /**
   * @description sends SMS OTP to mobile
   * @param mobile - mobile to receive OTP
   * @return retOTP - OTP sent to mobile
   */
  public static String sendSMSOTP(String mobile) {
    // Init
    Map<String, Object> resultSendSMSOTP = new Map<String, Object>();
    String accessToken = getAccessToken();
    String retOTP;
    Http http = new Http();

    // Generate OTP
    String randNum = string.valueof(Math.abs(Crypto.getRandomLong()));
    retOTP = randNum.substring(0, 6);

    // Set Payload
    Map<String, Object> recipient = new Map<String, Object>();
    recipient.put('to', mobile);
    recipient.put(
      'attributes',
      new Map<String, Object>{
        OTP_CREDENTIAL.Attributes__c => retOTP
      }
    );

    Map<String, Object> subscriptions = new Map<String, Object>{
      'resubscribe' => true
    };

    Map<String, Object> content = new Map<String, Object>{
      'message' => OTP_CREDENTIAL.Message__c
    };

    Map<String, Object> smsOTPPayload = new Map<String, Object>();
    smsOTPPayload.put('definitionKey',OTP_CREDENTIAL.DefinitionKey__c);
    smsOTPPayload.put('recipient', recipient);
    smsOTPPayload.put('subscriptions', subscriptions);
    smsOTPPayload.put('content', content);

    // Format Request
    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setEndpoint(OTP_CREDENTIAL.SMS_EndPoint_URL__c +
      mobile +
      '-' +
      retOTP
    );
    httpRequest.setMethod('POST');
    httpRequest.setHeader('Authorization', 'Bearer ' + accessToken);
    httpRequest.setHeader('Content-Type', 'application/json');
    httpRequest.setBody(JSON.serializePretty(smsOTPPayload));

    // Send Request
    HttpResponse httpResponse = http.send(httpRequest);

    // Validate Response
    Integer statusCode = httpResponse.getStatusCode();

    if (statusCode >= 200 && statusCode <= 204) {
      resultSendSMSOTP = (Map<String, Object>) JSON.deserializeUntyped(
        httpResponse.getBody()
      );
    }

    return retOTP;
  }

  /**
   * @description retrieves MC Transactional API Access Token
   * @return accessToken - MC Transactional API Access Token
   */
  public static String getAccessToken() {
    // Init
    Map<String, Object> resultGetAccessToken = new Map<String, Object>();
    String accessToken;
    Http http = new Http();

    // Set Payload
    Map<String, String> authPayload = new Map<String, String>();
    authPayload.put('grant_type', OTP_CREDENTIAL.GrantType__c);
    authPayload.put('client_id', OTP_CREDENTIAL.Client_Id__c);
    authPayload.put('client_secret', OTP_CREDENTIAL.Client_Secret__c);
    authPayload.put('account_id', OTP_CREDENTIAL.Account_Id__c);

    // Format Request
    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setEndpoint(OTP_CREDENTIAL.Access_Token_EndPoint_URL__c);
    httpRequest.setMethod('POST');
    httpRequest.setHeader('Content-Type', 'application/json');
    httpRequest.setBody(JSON.serializePretty(authPayload));

    // Send Request
    HttpResponse httpResponse = http.send(httpRequest);

    // Validate Response
    Integer statusCode = httpResponse.getStatusCode();

    if (statusCode >= 200 && statusCode <= 204) {
      resultGetAccessToken = (Map<String, Object>) JSON.deserializeUntyped(
        httpResponse.getBody()
      );
      accessToken = (String) resultGetAccessToken.get('access_token');
    }

    return accessToken;
  }
}
