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
      | angelika.j.s.galang       | September 16, 2021    | DEP1-22      | Added mock response for CLMS                        | 
      | alexander.cadalin         | February 7, 2023      | DEPP-4988    | Added mock response for MDM Lead Persona            | 
      | mark.j.mahilum            | July 27, 2023         | DEPP-6107    | Added mock response for Sales Cadence callout       |
      | kenneth.f.alsay           | August 4, 2024        | DEPP-8279    | Added mock response for PowerBI                     | 
 */
@isTest
public class MockHttpResponseGenerator implements HttpCalloutMock {

    private static final String ENDPOINT_ADDRESS_LOOKUP = 'callout:LOQATE/harmony/rest/address/lookup';
    private static final String ENDPOINT_ADDRESS_RETRIEVE = 'callout:LOQATE/harmony/rest/address/retrieve';
    private static final String ENDPOINT_PHONE_VALIDATE = 'callout:LOQATE/harmony/rest/au/validate/phone';
    private static final String ENDPOINT_PHONE_VALIDATE_NZ = 'callout:LOQATE/harmony/rest/nz/validate/phone';
    private static final String ENDPOINT_COMPANY_LOOKUP = 'callout:LOQATE/harmony/rest/au/companyLookup';
    private static final String ENDPOINT_CLMS_CONTRACT = 'callout:ESB' + System.Label.ESBEndpointCreateContract;
    private static final String ENDPOINT_MDM_CONTACT = 'callout:ESB' + System.Label.ESBEndpointMDMStudent;
    private static final String ENDPOINT_MDM_STUDENTENROLMENT = 'callout:ESB' + System.Label.ESBEndpointMDMStudentEnrolment;
    private static final String ENDPOINT_ASSIGN_TARGET_CADENCE = System.Label.SalesCadenceAssignTargetEndpoint;
    private static final String ENDPOINT_POWERBI_REPORT = 'callout:PowerBI/123456/reports/123456';
    private static final String ENDPOINT_REMOVE_TARGET_CADENCE = System.Label.SalesCadenceRemoveTargetEndpoint;  
    private static final String ENDPOINT_ESB_SAMS_REFRESH_STUDENT = 'callout:ESB' + System.Label.ESBSAMSRefreshStudent;
    private static final String PAYLOAD_CLMS = '{"status":"OK","CLMS_Agreement_Id":"1234","CLMS_Agreement_URL":"5678"}';
    private static final String PAYLOAD_ADDRESS = '{"payload":[{"fullAddress":"testAddress","country":"testCountry"}]}';
    private static final String PAYLOAD_PHONE = '{"payload":[{"fullPhone":"1234","country":"AU","phoneStatus":"connected|Network confirmed connection"}]}';
    private static final String PAYLOAD_COMPANY = '{"payload":[{"abn":"54321","name":"testEntityName"}]}';
    private static final String PAYLOAD_PHONE_NZ = '{"payload":[{"fullPhone":"1234","country":"NZ","phoneStatus":"connected|Network confirmed connection"}]}';  
    private static final String PAYLOAD_POWERBIREPORT = '{"id":"1234567890","reportType":"PowerBiReportType","name":"PowerBiReport","embedUrl":"embedUrl","datasetId":"123456"}';
    private static final String PAYLOAD_ASSIGN_CADENCE = '[{"version" : 1,"outputValues" : { },"isSuccess" : true,"errors" : null,"actionName" : "assignTargetToSalesCadence"}]';
    private static final String PAYLOAD_REMOVE_CADENCE = '[{"errors": [{"statusCode": "UNKNOWN_EXCEPTION","message": "The object needs to be a valid cadence entity.","fields": []}],"isSuccess": false}]';
    
    

    /**
    * @description Implements interface method for HTTP Callout response
    * @param req - HTTP request
    * @return res - mock HTTP response
    */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        
        if(req.getEndpoint() == ENDPOINT_MDM_STUDENTENROLMENT ||
            req.getEndpoint() == ENDPOINT_MDM_CONTACT ||
            req.getEndpoint() == ENDPOINT_ESB_SAMS_REFRESH_STUDENT) {
            res = esbNotFoundMockResponse();
        } else if(req.getEndpoint().contains(ENDPOINT_ASSIGN_TARGET_CADENCE)){
            res = assignTargetCadenceMockResponse(req);
        } else if(req.getEndpoint().contains(ENDPOINT_REMOVE_TARGET_CADENCE)){
            res = removeTargetCadenceMockResponse(req);           
        } else if(req.getEndpoint().contains(ENDPOINT_POWERBI_REPORT)){
            res = powerBiReportMockResponse();
        } else {
            res = loqateMockResponse(req);
        }
        return res;
    }
    
   /**
    * @description Creates a mock HTTP Response for assignTargetCadence
    * @param payload - mock body of the response
    * @return res - mock HTTP response
    */
    private static HttpResponse assignTargetCadenceMockResponse(HTTPRequest req){
        String payload = PAYLOAD_ASSIGN_CADENCE;
        HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
        res.setBody(payload);
        res.setStatusCode(200);

        return res;
    }
    
   /**
    * @description Creates a mock HTTP Response for removeTargetCadence
    * @param payload - mock body of the response
    * @return res - mock HTTP response
    */
    private static HttpResponse removeTargetCadenceMockResponse(HTTPRequest req){
        String payload = PAYLOAD_REMOVE_CADENCE;
		HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(payload);
        res.setStatusCode(404);

        return res;
    }
    
    /**
    * @description Creates a mock HTTP Response
    * @param payload - mock body of the response
    * @return res - mock HTTP response
    */
    private static HttpResponse loqateMockResponse(HTTPRequest req){
        String payload;
		if(req.getEndpoint() == ENDPOINT_ADDRESS_LOOKUP || req.getEndpoint() == ENDPOINT_ADDRESS_RETRIEVE){
            payload = PAYLOAD_ADDRESS;
        }else if(req.getEndpoint() == ENDPOINT_PHONE_VALIDATE){
            payload = PAYLOAD_PHONE;
        }else if(req.getEndpoint() == ENDPOINT_PHONE_VALIDATE_NZ){
            payload = PAYLOAD_PHONE_NZ;
        }else if(req.getEndpoint() == ENDPOINT_COMPANY_LOOKUP){
            payload = PAYLOAD_COMPANY;
        }else if(req.getEndpoint() == ENDPOINT_CLMS_CONTRACT){
            payload = PAYLOAD_CLMS;
        }

        HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
        res.setBody(payload);
        res.setStatusCode(200);

        return res;
    }

    /**
    * @description Creates a mock HTTP Response for ESB
    * @return res - mock HTTP response
    */
    private static HttpResponse esbNotFoundMockResponse() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(404);
        return res;
    }
    
    /**
    * @description Creates a mock HTTP Response for powerBi Report
    * @return res - mock HTTP response
    */
    private static HttpResponse powerBiReportMockResponse() {
        String payload = PAYLOAD_POWERBIREPORT;
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(payload);
        res.setStatusCode(200);
        return res;
    }
}