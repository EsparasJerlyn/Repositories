/**
 * @description Calls ESBEndpointMDMStudent when contact is inserted/updated
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eccarius.munoz            | February 14, 2023     | DEPP-5040    | Created file                                | 
      |                           |                       |              |                                             | 
 */
public with sharing class IntegrationCallOutCtrl implements Database.AllowsCallouts{

    private static final Integer TIMEOUT = 120000;

    /**
     * @description Callouts specified endpoint
     * @param endpoint - path of the endpoint
     * @param httpMethod - http method of request
     * @param payloadRequest - payload request
     * @return HTTPResponse - http response from endpoint
     */
    public static HTTPResponse doCallout(String endpoint, String httpMethod, String payloadRequest) {

        HTTPResponse response = new HTTPResponse();

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(httpMethod);
        request.setbody(payloadRequest); 
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(TIMEOUT);

        Http http = new Http();   
            
        try{
            response = http.send(request);            
        }catch(Exception e){
            throw e;
        }   

        return response;
    }
    
}