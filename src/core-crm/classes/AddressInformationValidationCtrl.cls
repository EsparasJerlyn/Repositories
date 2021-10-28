/**
 * @description Controller Class for Address Information Validation custom component
 * @see ../lwc/loqateAddressInformationValidation
 * @see ../lwc/searchAddress
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | September 3, 2021     | DEP1-170,169,159,263 | Created file                 | 
      |                           |                       |                      |                              | 
 */
public with sharing class AddressInformationValidationCtrl {

    /**
     * @description get loqate component custom metadata which is used to map object to hed__address__c
     * @param object api name of the current record the lwc is at
     * @return address meta data mapping
     */
    @AuraEnabled(cacheable=true)
    public static AddressMetaData getLoqateMetaData(String objectApiName){
        try {
            AddressMetadata addressMetaData = new AddressMetadata();
            Loqate_Component__mdt loqate = [SELECT Object_Type__c, Field_API_Address_Mapping__c, Country_Mapping__c, Address_Lookup_Field__c FROM loqate_Component__mdt WHERE Object_Type__c =: objectApiName LIMIT 1];
                addressMetaData.fieldApiMapping = loqate.Field_API_Address_Mapping__c;
                addressMetaData.countryMapping = loqate.Country_Mapping__c;
                addressMetaData.addressLookup = loqate.Address_Lookup_Field__c;
            return addressMetaData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description upsert hed__address__c record
     * @param the address info from lwc component
     */
    @AuraEnabled
    public static void upsertHedAddress(hed__address__c addressToUpsert){
        try {
            if(addressToUpsert != null){
                upsert(addressToUpsert);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @description get hed__address__c related to the current record on page
     * @param record id of the current record on the page
     * @param look up api name for the object associated to the hed address
     * @return list of hed__address__c associated to the record on the page
     */
    @AuraEnabled(cacheable=true)
    public static List<hed__Address__c> getHedAddress(String recordId, String lookUpApiName){
        try {
            List<hed__Address__c> addressList = new List<hed__Address__c>();
            String otherFields ='Id, hed__address_type__c,  Validated__c, Unique_ID__c,';
            String addressFields = 'hed__MailingCity__c,hed__MailingCountry__c,hed__MailingCounty__c, hed__MailingState__c, hed__MailingStreet__c, hed__MailingStreet2__c, hed__MailingPostalCode__c,';
            addressList = Database.Query('Select ' + String.escapeSingleQuotes(otherFields) + ' ' 
                                            +String.escapeSingleQuotes(addressFields)+ ' ' + String.escapeSingleQuotes(lookUpApiName) 
                                            +' FROM hed__address__c WHERE ' + String.escapeSingleQuotes(lookUpApiName) 
                                            + '=: recordid AND hed__address_type__c != null');
            return addressList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description search Addresses based on user input
     * @param string user input
     * @param origin country 
     * @return list of addresses from loqate response
     */
    @AuraEnabled(cacheable=true)
    public static List<AddressObject> searchAddress(String searchValue, String country) {
        try {
            return createRequest(searchValue, 'fullAddress', country , 'lookup');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    /**
     * @description get detailed info of address selected
     * @param unique id of selected address from loqate
     * @param origin country 
     * @return an address from loqate response
     */
    @AuraEnabled(cacheable=true)
    public static AddressObject getDetails(String searchValue, String country){
        try {
            return createRequest(searchValue, 'id', country, 'retrieve')[0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description create request to loqate
     * @param input string by user/id of selected address
     * @param type of search (id or fullAddress)
     * @param origin country
     * @param request type (look up/retrieve)
     * @return list of address object response from loqate
     */
    public static List<AddressObject> createRequest(String searchValue, String filter, String country, String requestType){
        try {
            List<AddressObject> addressObjectList = new List<AddressObject>{};
            Wrapper serviceWrapper = new Wrapper();
            if(!String.isEmpty(searchValue) && !String.isEmpty(country)){
                serviceWrapper = createWrapper('searchAddress'); 
                serviceWrapper.body = '{"payload": [{ "'+filter+'": "'+searchValue+'", "country": "'+country+'"} ]}';
                string res = doCallout('/harmony/rest/address/'+requestType+'','POST', serviceWrapper.body);
                Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(res);
                string respStr = JSON.serialize(result);
                serviceWrapper.result = (ResponseResult) JSON.deserialize(respStr, ResponseResult.class);
                addressObjectList.addAll(serviceWrapper.result.payload);
            }
            return addressObjectList;  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    /**
     * @description do callout to loqate
     * @param the endpoint of the callout
     * @param type of callout
     * @param body of request
     * @return string response from loqate
     */
    private static String doCallout(String endpointPath, String type, String payload) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        HTTPResponse response = new HTTPResponse();
        String requestId = null;
        String endpoint = 'callout:LOQATE'+endpointPath;
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
            string res = response.getBody();
            res = res.replace('"_type"','"underscore_type"');
            return res;
        } else {
            throw new AuraHandledException('Error occured while submitting request.');
        }
    }

    //creates a wrapper with service name
    private static Wrapper createWrapper(String serviceName){
        Wrapper serviceWrapper = new Wrapper();
        serviceWrapper.serviceName = serviceName;
        return serviceWrapper;
    }

    //wrapper class, holds the request/response
    private class Wrapper{
        // Authorise request 
        String serviceName {get;set;}
        Boolean AuthRequest {get;set;}
        String Body {get;set;}
        String transmission_datetime {get;set;}
        ResponseResult result {get;set;}

        public Wrapper() {
            this.AuthRequest = true;
            DateTime formattedDateTime = DateTime.now();
            this.transmission_datetime = formattedDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
    }
    
    //holds the response from loqate
    public class ResponseResult {
        public string status;
        public list<string> messages;
        public list<AddressObject> payload;
    }
    
    //holds the address fields in the payload from loqate
    public class AddressObject {
        @AuraEnabled
        public string fullAddress;
        @AuraEnabled
        public string country;
        @AuraEnabled
        public string postcode;
        @AuraEnabled
        public string street;
        @AuraEnabled
        public string street2;
        @AuraEnabled
        public string streetNumber;
        @AuraEnabled
        public string id;
        @AuraEnabled
        public string state;
        @AuraEnabled
        public string city;
        @AuraEnabled
        public string locality;
        @AuraEnabled
        public string province;
        @AuraEnabled
        public string buildingName;
        @AuraEnabled
        public string lotNumber;
        @AuraEnabled
        public string subdwelling;
        @AuraEnabled
        public string postal;
    }

    //holds data to maps sObjects to hed__Address__c from custom meta data
    public class AddressMetadata {
        @AuraEnabled
        public string fieldApiMapping;
        @AuraEnabled
        public string countryMapping;
        @AuraEnabled
        public string addressLookup;
    }
        
}