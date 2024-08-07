/**
 * @description Controller Class for Address Information Validation custom component
 * @see ../lwc/loqateAddressInformationValidation
 * @see ../lwc/searchAddress
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | September 3, 2021     | DEP1-170,169,159,263 | Created file                 | 
      | sebastianne.k.trias       | February 5, 2024      | DEPP-7870            | Add a Metadata for OIE       | 
      | julie.jane.alegre         | June 22, 2024         | DEPP-9490            | Update getHedAddress         |
 */
public with sharing class AddressInformationValidationCtrl {

    /**
     * @description get loqate component custom metadata which is used to map object to hed__address__c
     * @param objectApiName - object api name of the current record the lwc is at
     * @return address meta data mapping
     */
    @AuraEnabled(cacheable=true)
    public static AddressMetaData getLoqateMetaData(String objectApiName){
        try {
            AddressMetadata addressMetaData = new AddressMetadata();
            Loqate_Component__mdt loqate;
            String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name; 
            List<Loqate_Component__mdt> loqateComponentList = [ 
                SELECT Object_Type__c, Field_API_Address_Mapping__c, Country_Mapping__c, 
                Address_Lookup_Field__c, Profile__c 
                FROM loqate_Component__mdt 
                WHERE Object_Type__c =: objectApiName ];
            for(Loqate_Component__mdt loq : loqateComponentList){
                if(loq.Profile__c == profileName){
                    loqate = loq;
                    break;
                }else if(loq.Profile__c == null){
                    loqate = loq;
                }
            }
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
     * @param addressToUpsert - the address info from lwc component
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
     * @param recordId - record id of the current record on the page
     * @param lookUpApiName - look up api name for the object associated to the hed address
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
                                            + '=: recordid AND hed__address_type__c != null Order By LastModifiedDate DESC');
            
            Map<String, hed__Address__c> addressMap = new Map<String, hed__Address__c>();

            for(hed__Address__c address: addressList){
                if(!addressMap.containsKey(address.hed__address_type__c)){
                    addressMap.put(address.hed__address_type__c,address);
                }
            }

            return addressMap.values();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description search Addresses based on user input
     * @param searchValue - string user input
     * @param country - origin country 
     * @return list of addresses from loqate response
     */
    @AuraEnabled(cacheable=true)
    public static List<AddressObject> searchAddress(String searchValue, String country) {
        Request r = new Request();
        r.searchValue = searchValue;
        r.filter = 'fullAddress';
        r.country = country;
        r.requestType = 'lookup';
        return createRequest(r); 
    }

    /**
     * @description get detailed info of address selected
     * @param searchValue - unique id of selected address from loqate
     * @param country - origin country 
     * @return an address from loqate response
     */
    @AuraEnabled(cacheable=true)
    public static AddressObject getDetails(String searchValue, String country){
        Request r = new Request();
        r.searchValue = searchValue;
        r.filter = 'id';
        r.country = country;
        r.requestType = 'retrieve';
        return createRequest(r)[0];
    }

    /**
     * @description create request to loqate
     * @param searchValue - input string by user/id of selected address
     * @param filter - type of search (id or fullAddress)
     * @param country - rigin country
     * @param requestType - request type (look up/retrieve)
     * @return list of address object response from loqate
     */
    public static List<AddressObject> createRequest(Request req){
        try {
            List<AddressObject> addressObjectList = new List<AddressObject>{};
            Wrapper serviceWrapper = new Wrapper();
            if(!String.isEmpty(req.searchValue) && !String.isEmpty(req.country)){
                serviceWrapper = createWrapper('searchAddress'); 
                serviceWrapper.body = '{"payload": [{ "'+req.filter+'": "'+req.searchValue+'", "country": "'+req.country+'"} ]}';
                string res = doCallout('/harmony/rest/address/'+req.requestType+'','POST', serviceWrapper.body);
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
     * @param endpointPath - the endpoint of the callout
     * @param type - type of callout
     * @param payload - body of request
     * @return string response from loqate
     */
    private static String doCallout(String endpointPath, String type, String payload) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        HTTPResponse response = new HTTPResponse();
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

    /**
     * @description creates a wrapper with service 
     * @param serviceName - service name
     * @return service wrapper
     */
    private static Wrapper createWrapper(String serviceName){
        Wrapper serviceWrapper = new Wrapper();
        serviceWrapper.serviceName = serviceName;
        return serviceWrapper;
    }

    /**
     * @description wrapper for request and response
     */
    private class Wrapper{
        // Authorise request 
        String serviceName {get;set;}
        Boolean authRequest {get;set;}
        String body {get;set;}
        String transmissionDateTime {get;set;}
        ResponseResult result {get;set;}

        public Wrapper() {
            this.authRequest = true;
            DateTime formattedDateTime = DateTime.now();
            this.transmissionDateTime = formattedDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
    }
    
    /**
     * @description wrapper for result
     */
    public class ResponseResult {
        public string status;
        public list<string> messages;
        public list<AddressObject> payload;
    }
    
    /**
     * @description wrapper for address object
     */
    public class AddressObject {
        @AuraEnabled public string fullAddress;
        @AuraEnabled public string country;
        @AuraEnabled public string postcode;
        @AuraEnabled public string street;
        @AuraEnabled public string street2;
        @AuraEnabled public string streetNumber;
        @AuraEnabled public string id;
        @AuraEnabled public string state;
        @AuraEnabled public string city;
        @AuraEnabled public string locality;
        @AuraEnabled public string province;
        @AuraEnabled public string buildingName;
        @AuraEnabled public string lotNumber;
        @AuraEnabled public string subdwelling;
        @AuraEnabled public string postal;
    }

    /**
     * @description olds data to maps sObjects to hed__Address__c from custom meta data
     */
    public class AddressMetadata {
        @AuraEnabled public string fieldApiMapping;
        @AuraEnabled public string countryMapping;
        @AuraEnabled public string addressLookup;
    }
    
    private class Request {
        public String searchValue { get; set; }
        public String filter { get; set; }
        public String country { get; set; }
        public String requestType { get; set; }
    }
}