/**
 * @description Class for generating Mock HTTP responses
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                      |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------|
      | roy.nino.s.regala         | September 3, 2021     | DEP1-159     | Created file                                        |
      | angelika.j.s.galang       | September 8, 2021     | DEP1-157     | Added mock response for email,phone,company callout | 
      |                           |                       |              |                                                     | 
 */
@IsTest
global class MockHttpResponseGenerator implements HttpCalloutMock {

    private static final String ENDPOINT_ADDRESS_LOOKUP = 'callout:LOQATE/harmony/rest/address/lookup';
    private static final String ENDPOINT_ADDRESS_RETRIEVE = 'callout:LOQATE/harmony/rest/address/retrieve';
    private static final String ENDPOINT_EMAIL_VALIDATE = 'callout:LOQATE/harmony/rest/au/validate/email';
    private static final String ENDPOINT_PHONE_VALIDATE = 'callout:LOQATE/harmony/rest/au/validate/phone';
    private static final String ENDPOINT_COMPANY_LOOKUP = 'callout:LOQATE/harmony/rest/au/companyLookup';
    private static final String PAYLOAD_ADDRESS = '{"payload":[{"fullAddress":"testAddress","country":"testCountry"}]}';
    private static final String PAYLOAD_EMAIL = '{"payload":[{"address":"test@test.com","domainValidated":true}]}';
    private static final String PAYLOAD_PHONE = '{"payload":[{"fullPhone":"1234","phoneStatus":"connected|Network confirmed connection"}]}';
    private static final String PAYLOAD_COMPANY = '{"payload":[{"abn":"54321","name":"testEntityName"}]}';

    /**
    * @description Implements interface method for HTTP Callout response
    * @param req - HTTP request
    * @return res - mock HTTP response
    */
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String payload;

        if(req.getEndpoint() == ENDPOINT_ADDRESS_LOOKUP || req.getEndpoint() == ENDPOINT_ADDRESS_RETRIEVE){
            payload = PAYLOAD_ADDRESS;
        }else if(req.getEndpoint() == ENDPOINT_EMAIL_VALIDATE){
            payload = PAYLOAD_EMAIL;
        }else if(req.getEndpoint() == ENDPOINT_PHONE_VALIDATE){
            payload = PAYLOAD_PHONE;
        }else if(req.getEndpoint() == ENDPOINT_COMPANY_LOOKUP){
            payload = PAYLOAD_COMPANY;
        }

        res = loqateMockResponse(payload);
        return res;
    }
    
    /**
    * @description Creates a mock HTTP Response
    * @param payload - mock body of the response
    * @return res - mock HTTP response
    */
    public static HttpResponse loqateMockResponse(String payload){
        HttpResponse res = new HttpResponse();

        res.setHeader('Content-Type', 'application/json');
        res.setBody(payload);
        res.setStatusCode(200);

        return res;
    }

}
