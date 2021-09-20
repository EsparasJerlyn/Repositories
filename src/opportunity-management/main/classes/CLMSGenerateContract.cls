/**
 * @description Class used by flow to generate and retrieve Contract Information from CLMS
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | angelika.j.s.galang       | September 14, 2021    | DEP1-22      | Created file                                | 
      |                           |                       |              |                                             | 
 */

public with sharing class CLMSGenerateContract{
    private static final String ENDPOINT_MOCK = '/consumer/dep/v1/opportunity/createContract';
    private static final String ERROR_MSG = 'Error occured while submitting request.';

    /**
    * @description Invocable method for the flow to generate contract
    * @param contractRequestList - list of contract requests
    * @return contractResponseList
    */
    @InvocableMethod(Callout=true Label='Generate Contract' Description='Retrieve Contract Id and URL for Opportunity')
    public static List<ContractResponse> generateContract(List<ContractRequest> contractRequestList){
        List<ContractResponse> contractResponseList = new List<ContractResponse>();
        Map<String,Object> result = new Map<String,Object>();
        String res;
        String respStr;

        for(ContractRequest contractReq : contractRequestList){
            res = doCallout(ENDPOINT_MOCK,'POST', JSON.serialize(contractReq));
            result = (Map<String,Object>) JSON.deserializeUntyped(res);
            respStr = JSON.serialize(result);
            contractResponseList.add((ContractResponse) JSON.deserialize(respStr, ContractResponse.class));
        }

        return contractResponseList;
    }

    /**
    * @description Performs necessary callout
    * @param endpointPath - path of the endpoint
    * @param type - type of request
    * @param payload - payload request
    * @return callout response
    */
    private static String doCallout(String endpointPath, String type, String payload) {
        String endpoint = 'callout:ESB'+endpointPath;
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        HTTPResponse response = new HTTPResponse();

        request.setEndpoint(endpoint);
        request.setMethod(type);
        request.setbody(payload); 
        request.setTimeout(120000);
        request.setHeader('Content-Type', 'application/json');

        if(Test.isRunningTest()){
            MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
            response = mock.respond(request);
        }else{
            response = http.send(request);
        }
        System.debug('HTTP REQUEST: '+payload);
        System.debug('HTTP RESPONSE: '+response.getBody());
        if(response.getStatusCode() == 200) {
            return response.getBody();
        }else{
            throw new AuraHandledException(ERROR_MSG);
        }
    }

    public class ContractRequest{
        @InvocableVariable
        public String Opportunity_Id;
    }

    public class ContractResponse{
        @InvocableVariable
        public String status;
        @InvocableVariable
        public String CLMS_Agreement_Id;
        @InvocableVariable
        public String CLMS_Agreement_URL;

        //for error response
        @InvocableVariable
        public String errorType;
        @InvocableVariable
        public String errorMessage;
    }
}
