/**
 * @description Controller class for Contact Information Validation custom component
 *
 * @see ../lwc/contactInformationValidation
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | angelika.j.s.galang       | September 3, 2021     | DEP1-156     | Created file                                | 
      | angelika.j.s.galang       | September 8, 2021     | DEP1-157     | Added methods for validation and callouts   | 
 */

public with sharing class ContactInformationValidationCtrl {
   
    private static final String ENDPOINT_START = '/harmony/rest/';
    private static final String STR_PHONE = '/validate/phone';
    private static final String STR_COMPANY_LOOKUP = '/companyLookup';
    private static final String STR_AU = 'AU';
    private static final String STR_NZ = 'NZ';
    private static final String LOQ_PHONE = 'fullPhone';
    private static final String LOQ_ABN = 'name';
    private static final String ERROR_MSG = 'Error occured while submitting request.';

    private static Wrapper requestToValidate;
    private static List<PayloadResponse> payloadList = new List<PayloadResponse>();

    /**
    * @description Method for getting the Field Mapping set in Loqate Component metadata
    * @param objApiName - API name of object passed from component
    * @param fieldToQuery - metadata field to query
    * @return mapping - the JSON string of field mapping 
    */
    @AuraEnabled(cacheable=true)
    public static String getMapping(String objApiName, String fieldToQuery){
        String mapping;

        try{
            String query = 'SELECT ' + fieldToQuery + ' FROM Loqate_Component__mdt WHERE Object_Type__c=:objApiName LIMIT 1';
            mapping = (String) Database.query(query).iterator().next().get(fieldToQuery);
        }catch(Exception ex){
            AuraHandledException auraEx = new AuraHandledException(ex.getMessage());
            auraEx.setMessage('Error while getting field mapping.');
            throw auraEx;
        }

        return mapping;
    }


    /**
    * @description Collates all fields to be validated
    * @param validateRequestList - serialized list of fields to be validated
    * @return serialized list of payload responses
    */
    @AuraEnabled(cacheable=true)
    public static String validateFields(String validateRequestList){
        List<ValidateRequest> parsedValidateRequestList = (List<ValidateRequest>) JSON.deserialize(validateRequestList, List<ValidateRequest>.class);
        Map<String,List<PhoneRequest>> phoneCountryMapping = new Map<String,List<PhoneRequest>>();

        //build request payload per necessary field
        for(ValidateRequest valObj : parsedValidateRequestList){
            if(valObj.loqateRequest == LOQ_PHONE){
                PhoneRequest phoneObj = new PhoneRequest(valObj.value, valObj.locale);
                if(!phoneCountryMapping.containsKey(valObj.locale)){
                    phoneCountryMapping.put(valObj.locale,new List<PhoneRequest>{phoneObj});
                }else{
                    phoneCountryMapping.get(valObj.locale).add(phoneObj);
                }
            }else if(valObj.loqateRequest == LOQ_ABN){
                CompanyRequest abnObj = new CompanyRequest(valObj.value);
                createRequest(LOQ_ABN, JSON.serialize(abnObj));
            }
        }
        
        for(String phoneCountry : phoneCountryMapping.keySet()){
           createRequest(phoneCountry, JSON.serialize(phoneCountryMapping.get(phoneCountry)));
        }
        
        return JSON.serialize(payloadList);
    }

    /**
    * @description Creates a request for the callout
    * @param loqateKey - field being validated
    * @param payloadString - serialized payload request
    */
    private static void createRequest(String loqateKey, String payloadString){
        Map<String,Object> result = new Map<String,Object>();
        String endpoint;
        String res;
        String respStr;
        
        //create wrapper
        requestToValidate = new Wrapper();
        requestToValidate.serviceName = 'validateContactInformation';
        requestToValidate.body = '{"payload":' + payloadString;
        if(loqateKey == LOQ_ABN){
            requestToValidate.body += ',"apiName": "SearchByABNv201408"';
        }
        requestToValidate.body += '}';
        
        endpoint = ENDPOINT_START;
        if(loqateKey == STR_AU){
            endpoint += STR_AU.toLowerCase() + STR_PHONE;
        }else if(loqateKey == STR_NZ){
            endpoint += STR_NZ.toLowerCase() + STR_PHONE;
        }else if(loqateKey == LOQ_ABN){
            endpoint += STR_AU.toLowerCase() + STR_COMPANY_LOOKUP;
        }
        
        //perform callout and process results
        res = doCallout(endpoint,'POST', requestToValidate.body);
        result = (Map<String,Object>) JSON.deserializeUntyped(res);
        respStr = JSON.serialize(result);
        requestToValidate.result = (ResponseResult) JSON.deserialize(respStr, ResponseResult.class);

        System.debug('CALLOUT DATETIME: '+requestToValidate.transmissionDateTime);
        payloadList.addAll(requestToValidate.result.payload);
    }

    /**
    * @description Performs necessary callout
    * @param endpointPath - path of the endpoint
    * @param type - type of request
    * @param payload - payload request
    * @return callout response
    */
    private static string doCallout(String endpointPath, String type, String payload) {
        String endpoint = 'callout:LOQATE'+endpointPath;
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

    //for request authorization
    private class Wrapper{ 
        String serviceName {get;set;}
        Boolean authRequest {get;set;}
        String authErrorMessage{get;set;}
        String body {get;set;}
        String transmissionDateTime {get;set;}
        ResponseResult result {get;set;}

        public Wrapper() {
            this.authRequest = true;
            DateTime formattedDateTime = DateTime.now();
            this.transmissionDateTime = formattedDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
    }

    //for callout response
    public class ResponseResult{
        public String status;
        public List<String> messages;
        public List<PayloadResponse> payload;
    }

    //for payload response
    public class PayloadResponse{
        //for phone response
        public String fullPhone;
        public String country;
        public String phoneStatus;

        //for company response
        public String name;
        public String abn;
        public String status;
    }
    
    //for phone request payload formatting
    public class PhoneRequest{
        public String fullPhone;
        public String country;

        public PhoneRequest(String fullPhone, String country){
            this.fullPhone = fullPhone;
            this.country = country;
        }
    }

    //for company request payload formatting
    public class CompanyRequest{
        public String name;

        public CompanyRequest(String name){
            this.name = name;
        }
    }

    //for request values passed from LWC JS
    public class ValidateRequest{
        @AuraEnabled 
        public String loqateRequest;
        @AuraEnabled 
        public String loqateResponse;
        @AuraEnabled 
        public String locale;
        @AuraEnabled 
        public String statusValidationField;
        @AuraEnabled 
        public String value;
    }

}