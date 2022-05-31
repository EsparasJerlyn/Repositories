/**
 * @description Batch Class to validate mobile field
 *
 * @see LoqateMobileValidationBatch
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | roy.nino.s.regala         | May 31, 2022          | DEPP-2105| Created file                    | 
*/

public with sharing class LoqateMobileValidationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{

    private static final String LEAD_API_NAME = Lead.SObjectType.getDescribe().getLocalName();
    private static final String CONTACT_API_NAME = Contact.SObjectType.getDescribe().getLocalName();
    private static final String AU_LOCALE = 'Australia (+61)';
    private static final String NZ_LOCALE = 'New Zealand (+64)';
    private static final String NONE_STATUS = 'None';
    private static final String ENDPOINT_START = '/harmony/rest/';
    private static final String STR_PHONE = '/validate/phone';
    private static final List<String> VALID_RESPONSE = new List<String>{'VALID','Active','connected|Network confirmed connection'};

    private static final Map<String,Map<String,String>> OBJECT_MAP = new Map<String,Map<String,String>>
        {
            LEAD_API_NAME => new Map<String,String>{
                'fields' => 'LeadMobile_Locale__c, Mobile_No_Locale__c, LeadMobile_Validation__c',
                'mobileLocale' => 'LeadMobile_Locale__c',
                'mobileNoLocale' => 'Mobile_No_Locale__c',
                'validationStatus' => 'LeadMobile_Validation__c'
            },
            CONTACT_API_NAME => new Map<String,String>{
                'fields' => 'ContactMobile_Locale__c, Mobile_No_Locale__c, ContactMobile_Validation__c',
                'mobileLocale' => 'ContactMobile_Locale__c',
                'mobileNoLocale' => 'Mobile_No_Locale__c',
                'validationStatus' => 'ContactMobile_Validation__c'
            }
    };

    private static final Map<String,String> LOCALE_MAP = new Map<String,String>{
        AU_LOCALE => 'AU', NZ_LOCALE => 'NZ'
    };

    private String objectType;
    private Map<String,String> queryMapping; 

    /**
    * @description constructor for batch class
    * @param objectType - either course offering or program offering api name
    */
    public LoqateMobileValidationBatch(String objType){
        objectType = objType;
        queryMapping = OBJECT_MAP.get(objectType);
    }

    /**
    * @description Method to query the product offering records
    * @param bc - BatchableContext
    * @return query - filtered query of product offering records
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 
            'SELECT Id, ' + queryMapping.get('fields') + 
            ' FROM ' + objectType +
            ' WHERE (' + queryMapping.get('mobileLocale') + ' = \'' + AU_LOCALE + '\' ' +
            ' OR ' + queryMapping.get('mobileLocale') + ' = \'' + NZ_LOCALE + '\' ' +
            ') AND ' + queryMapping.get('validationStatus') + ' = \'' + NONE_STATUS + '\' ' +
            ' AND ' + queryMapping.get('mobileNoLocale') + ' != null '  + (Test.isRunningTest()?' LIMIT 1':'LIMIT 5000');
        return Database.getQueryLocator(query);
    }

    /**
     * @description Executes the process and calls the relevant classes.
     *
     * @param context The batch context.
     * @param batchObjects The objects to process.
     */
    public void execute(Database.BatchableContext context, List<sObject> objectList) {
        try{
            String payLoadString;
            String endPoint;
            Map<String,Object> resultObjectMap = new Map<String,Object>();
            ResponseResult responseRes = new ResponseResult();

            for(sObject obj: objectList){
                payLoadString =  '{"payload" : [{"country":"' ;
                payLoadString += LOCALE_MAP.get((String)obj.get(queryMapping.get('mobileLocale')));
                payLoadString += '","fullPhone":"' + obj.get(queryMapping.get('mobileNoLocale')) + '"}]}';

                endPoint = ENDPOINT_START;  
                endPoint += LOCALE_MAP.get((String)obj.get(queryMapping.get('mobileLocale'))).toLowerCase() + STR_PHONE;

                String responseString = doCallout(endPoint,'POST',payLoadString);

                resultObjectMap = (Map<String,Object>) JSON.deserializeUntyped(responseString);  
                responseRes = (ResponseResult) JSON.deserialize(JSON.serialize(resultObjectMap), ResponseResult.class);

                if(!responseRes.payload.isEmpty() && responseRes.payload[0].phoneStatus != null && VALID_RESPONSE.contains((String)responseRes.payload[0].phoneStatus)){
                    obj.put(queryMapping.get('validationStatus'),'Valid');
                }else{
                    obj.put(queryMapping.get('validationStatus'),'Not Valid');
                }
            }     
            update objectList;
            
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'Error Processing Request!E: '+ e);//NOPMD
        }
        
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
        System.debug(LoggingLevel.DEBUG, 'HTTP REQUEST: '+payload);//NOPMD
        System.debug(LoggingLevel.DEBUG, 'HTTP RESPONSE: '+response.getBody());//NOPMD
        if(response.getStatusCode() == 200) {
            return response.getBody();
        }else{
            CalloutException e = new CalloutException();
            e.setMessage('Error Processing Request!');
            throw e;
        }
    }

    /**
     * @description Finalizer method for the batch process.
     *
     * @param param1 The batch context.
     */
    public void finish(Database.BatchableContext param1) {
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
}