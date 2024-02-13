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
      | rhea.b.torres             | March 03, 2023        | DEPP-5098| Log DML errors using            |
      |                           |                       |          | NebulaLogger                    |
*/

public with sharing class LoqateMobileValidationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{

    private static final String LEAD_API_NAME = Lead.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
    private static final String CONTACT_API_NAME = Contact.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
    private static final String AU_LOCALE = 'Australia (+61)';
    private static final String NZ_LOCALE = 'New Zealand (+64)';
    private static final String NONE_STATUS = 'None';
    private static final String ENDPOINT_START = '/harmony/rest/';
    private static final String STR_PHONE = '/validate/phone';
    private static final List<String> VALID_RESPONSE = new List<String>{'VALID','Active','connected|Network confirmed connection'};

    private static final Map<String,Map<String,String>> OBJECT_MAP = new Map<String,Map<String,String>>
        {
            LEAD_API_NAME => new Map<String,String>{
                'fields' => 'LeadMobile_Locale__c, Mobile_No_Locale__c, LeadMobile_Validation__c, MobilePhone',
                'mobileLocale' => 'LeadMobile_Locale__c',
                'mobileNoLocale' => 'Mobile_No_Locale__c',
                'validationStatus' => 'LeadMobile_Validation__c',
                'mobilePhone' => 'mobilePhone'
            },
            CONTACT_API_NAME => new Map<String,String>{
                'fields' => 'ContactMobile_Locale__c, Mobile_No_Locale__c, ContactMobile_Validation__c',
                'mobileLocale' => 'ContactMobile_Locale__c',
                'mobileNoLocale' => 'Mobile_No_Locale__c',
                'validationStatus' => 'ContactMobile_Validation__c',
                'mobilePhone' => 'mobilePhone'
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
            ' AND ' + queryMapping.get('mobileNoLocale') + ' != null '  + (Test.isRunningTest()?' LIMIT 10':'LIMIT 5000');
        return Database.getQueryLocator(query);
    }

    /**
     * @description Executes the process and calls the relevant classes.
     *
     * @param context The batch context.
     * @param objectList The objects to process.
     */
    public void execute(Database.BatchableContext context, List<sObject> objectList) {

        String endPointAU;
        String endPointNZ;

        String auResponse;
        String nzResponse;

        endPointAU = ENDPOINT_START;
        endPointAU += 'au' + STR_PHONE;
        endPointNZ = ENDPOINT_START;
        endPointNZ += 'nz' + STR_PHONE;


        String auPayLoadStr;
        String nzPayLoadStr;
        PayLoad auPayLoadClass;
        PayLoad nzPayLoadClass;
        List<Payload> auPayLoadList = new List<PayLoad>();
        List<Payload> nzPayLoadList = new List<PayLoad>();
        List<sObject> auRecords = new List<sObject>();
        List<sObject> nzRecords = new List<sObject>();
        List<sObject> objectsToUpdate = new List<sObject>();

        try{
            //filter nz and au
            for(sObject obj: objectList){
                if(LOCALE_MAP.get((String)obj.get(queryMapping.get('mobileLocale'))) == 'AU'){
                    auRecords.add(obj);
                    auPayLoadClass = new PayLoad();
                    auPayLoadClass.country = 'AU';
                    auPayLoadClass.fullPhone = (String)obj.get(queryMapping.get('mobileNoLocale'));
                    auPayLoadList.add(auPayLoadClass);
                }else{
                    nzRecords.add(obj);
                    nzPayLoadClass = new PayLoad();
                    nzPayLoadClass.country = 'NZ';
                    nzPayLoadClass.fullPhone = (String)obj.get(queryMapping.get('mobileNoLocale'));
                    nzPayLoadList.add(nzPayLoadClass);
                }
            }

            if(!auPayLoadList.isEmpty()){
                auPayLoadStr = '{"payload" :' +  JSON.serialize(auPayLoadList) +'}';
                auResponse = doCallout(endPointAU,'POST',auPayLoadStr);
                Map<String,Object> auResultObjectMap = (Map<String,Object>) JSON.deserializeUntyped(auResponse);  
                ResponseResult auResponseRes = (ResponseResult) JSON.deserialize(JSON.serialize(auResultObjectMap), ResponseResult.class);
                if(!auResponseRes.payload.isEmpty()){
                    objectsToUpdate.addAll(processResponse(auRecords,auResponseRes, queryMapping));
                }
            }

            if(!nzPayLoadList.isEmpty()){
                nzPayLoadStr = '{"payload" :' +  JSON.serialize(nzPayLoadList) +'}';
                nzResponse = doCallout(endPointNZ,'POST',nzPayLoadStr);
                Map<String,Object> auResultObjectMap = (Map<String,Object>) JSON.deserializeUntyped(nzResponse);  
                ResponseResult nzResponseRes = (ResponseResult) JSON.deserialize(JSON.serialize(auResultObjectMap), ResponseResult.class);
                if(!nzResponseRes.payload.isEmpty()){
                    objectsToUpdate.addAll(processResponse(nzRecords,nzResponseRes, queryMapping));
                }
            }

            if(!objectsToUpdate.isEmpty()){
                Database.SaveResult[] srList = Database.update(objectsToUpdate, false);
                for (Database.SaveResult result : srList){
                    if (!result.isSuccess()){
                      Logger.error('Database update error ').setDatabaseResult(result);
                    }
                }
            }
            
        }catch(Exception e){
            Logger.error('Exception caught in execute in class LoqateMobileValidationBatch.')
                .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
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
        if(response.getStatusCode() == 200) {
            return response.getBody();
        }else{
            CalloutException e = new CalloutException();
            e.setMessage('Error Processing Request!');
            throw e;
        }
    }

    /**
    * @description processes response
    * @param loqateRecords - path of the endpoint
    * @param responseList - response from loqate
    * @param queryMapping - field mappings specified for object type
    * @return processResponse - processed reponse contact/lead nz or au phone
    */
    public static List<SObject> processResponse(List<sObject> loqateRecords,ResponseResult responseList, Map<String,String> queryMapping ) {

        if(!responseList.payload.isEmpty()){
            for(Integer i = 0 ; i < responseList.payload.size(); i ++){
                if(responseList.payload[i].phoneStatus != null && VALID_RESPONSE.contains((String)responseList.payload[i].phoneStatus)){
                    loqateRecords[i].put(queryMapping.get('validationStatus'),'Valid');
                    Matcher mobile_NL = Pattern.compile('^0+').matcher((String)loqateRecords[i].get(queryMapping.get('mobileNoLocale'))); 
                    String mobileNoLocaleTemp = mobile_NL.replaceAll('');
                    String localNoLocale = (String)loqateRecords[i].get(queryMapping.get('mobileLocale')) + mobileNoLocaleTemp;
                    loqateRecords[i].put(queryMapping.get('mobilePhone'),localNoLocale);
                    Matcher matcher1 = Pattern.compile('[^0-9]').matcher((String)loqateRecords[i].get('mobilePhone'));
                    String localeStr = (String)loqateRecords[i].get(queryMapping.get('mobileLocale'));
                    String tempLocale = localeStr.subString(localeStr.indexOf('(') + 1, localeStr.indexOf(')'));
                    String locale = tempLocale.replaceAll('\\D', '');
                    String numberField = matcher1.replaceAll('');
                    String mobileNoLocaleCheckerStr = mobileNoLocaleTemp.replaceAll('\\D', '').substring(0,2);
                    numberField = mobileNoLocaleCheckerStr == locale? numberField.removeStart(locale) : numberField;
                    loqateRecords[i].put(queryMapping.get('mobilePhone'), numberField);
                }else{
                    loqateRecords[i].put(queryMapping.get('validationStatus'),'Not Valid');
                }
            }
        }
        return loqateRecords;
    }

    /**
     * @description Finalizer method for the batch process.
     *
     * @param param1 The batch context.
     */
    public void finish(Database.BatchableContext param1) {}//NOPMD


    //for callout response
    public class ResponseResult{
        public String status;
        public List<String> messages;
        public List<PayloadResponse> payload;
    }

    //for payload response
    public class PayLoadResponse{
        //for phone response
        public String fullPhone;
        public String country;
        public String phoneStatus;
    }

    public class PayLoad{
        public String country;
        public String fullPhone;

    }
}