/**
 * @description Class for generating Mock HTTP response for Qualtric Survey - Process Survey Distribution
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                      |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------|
      | eccarius.munoz            | May 28, 2024          | DEPP-8840    | Created file                                        |
 */
@isTest
public with sharing class ESBProcessSurveyDistributionMock implements HttpCalloutMock {

    private static final String ENDPOINT = 'callout:ESB' + System.Label.ESBEndpointSurveyContact;

    /**
    * @description Creates a mock HTTP Response for ESB
    * @return res - mock HTTP response
    */
    public HTTPResponse respond(HTTPRequest req) {

        System.assertEquals(ENDPOINT, req.getEndpoint(), 'Incorrect Endpoint.');
        System.assertEquals('POST', req.getMethod(), 'Incorrect API Method');

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status": "OK"}');
        res.setStatusCode(200);

        return res;
    }

}