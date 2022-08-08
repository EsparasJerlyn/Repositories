/**
 * @description Before buyers can see products in your store, you must build a search index.
 * Also some store changes in store require an index rebuild.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | November 16, 2021     | DEPP-131               | Created file                 | 
      |                                |                       |                        |                              | 
 */
public with sharing class B2BStoreSearchIndexScheduler implements Schedulable{
    private static final String CLASS_NAME = B2BStoreSearchIndexScheduler.class.getName();
    private static final String COMMUNITY_NAME_CCE = 'CCE';
    private static final String COMMUNITY_NAME_STUDY = 'Study';
    
  
    //Executes
    public void execute(SchedulableContext context){
        postCCESearchIndexRequest();
        postStudySearchIndexRequest();
    }

 	/**
    * @description handle http request for CCE
    * @param  method
    * @return httpRequest
    */
    public static HttpRequest handleCCEStoreRequest(String method){
        Decimal apiVersionApexClass = B2BUtils.getAPIVersion(CLASS_NAME);
        String userSession= UserInfo.getSessionId();
        String communityId= B2BUtils.getCommunityIdByName(COMMUNITY_NAME_CCE);
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
       
        String baseUrl= URL.getOrgDomainUrl().toExternalForm();
        String apiUrl = '/services/data/v'+ apiVersionApexClass +'/commerce/management/webstores/'+ webstoreId +'/search/indexes';
        
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setMethod(method);
        httpRequest.setHeader('Authorization', 'OAuth ' + userSession); 
        httpRequest.setEndpoint(baseUrl + apiUrl);

        return httpRequest;
    }
    
    /**
    * @description handle http request for Study
    * @param  method
    * @return httpRequest
    */
    public static HttpRequest handleStudyStoreRequest(String method){
        Decimal apiVersionApexClass = B2BUtils.getAPIVersion(CLASS_NAME);
        String userSession= UserInfo.getSessionId();
        String communityId= B2BUtils.getCommunityIdByName(COMMUNITY_NAME_STUDY);
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        String baseUrl= URL.getOrgDomainUrl().toExternalForm();
        String apiUrl = '/services/data/v'+ apiVersionApexClass +'/commerce/management/webstores/'+ webstoreId +'/search/indexes';
        
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setMethod(method);
        httpRequest.setHeader('Authorization', 'OAuth ' + userSession); 
        httpRequest.setEndpoint(baseUrl + apiUrl);

        return httpRequest;
    }
    
   /**
   * @description handle get search request index for CCE
   * @return objResponse
   */
    public static Object getCCESearchIndexRequest(){
        Object objResponse;
        try {
         
            HttpRequest httpRequest = handleCCEStoreRequest('GET');
            Http http = new Http();
            
            HttpResponse httpResponse = http.send(httpRequest);
            Integer statusCode = httpResponse.getStatusCode();
            
            if (statusCode >= 200 && statusCode <= 204) {
                objResponse = JSON.deserializeUntyped(httpResponse.getBody());
            }
                
        } catch (Exception e) { 
             System.debug('getCCESearchIndexRequest ERROR: ' + e.getMessage());
        }

        return objResponse;
    }
    
    /**
   * @description handle get search request index for Study
   * @return objResponse
   */
    public static Object getStudySearchIndexRequest(){
        Object objResponse;
        try {
         
            HttpRequest httpRequest = handleStudyStoreRequest('GET');
            Http http = new Http();
            
            HttpResponse httpResponse = http.send(httpRequest);
            Integer statusCode = httpResponse.getStatusCode();
            
            if (statusCode >= 200 && statusCode <= 204) {
                objResponse = JSON.deserializeUntyped(httpResponse.getBody());
            }
                
        } catch (Exception e) { 
             System.debug('getStudySearchIndexRequest ERROR: ' + e.getMessage());
        }

        return objResponse;
    }

   /**
   * @description handle post search index request for CCE
   *
   */
	@future(callout=true)
    public static void postCCESearchIndexRequest(){
        try {
               
            Object searchIndexResponse = getCCESearchIndexRequest();
            
            HttpRequest httpRequest = handleCCEStoreRequest('POST');             
            httpRequest.setBody(JSON.serializePretty(searchIndexResponse));
            
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            Integer statusCode = httpResponse.getStatusCode();
            
            if (statusCode >= 200 && statusCode <= 204) {
                JSON.deserializeUntyped(httpResponse.getBody());
            }
           
        } catch (Exception e) { 
             System.debug('postCCESearchIndexRequest ERROR: ' + e.getMessage());
        }


    }
    
    /**
   * @description handle post search index request for Study
   *
   */
	@future(callout=true)
    public static void postStudySearchIndexRequest(){
        try {
            
            Object searchIndexResponse = getStudySearchIndexRequest();
           
            HttpRequest httpRequest = handleStudyStoreRequest('POST'); 
            httpRequest.setBody(JSON.serializePretty(searchIndexResponse));
            
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            Integer statusCode = httpResponse.getStatusCode();
            
            if (statusCode >= 200 && statusCode <= 204) {
                JSON.deserializeUntyped(httpResponse.getBody());
            }
           
        } catch (Exception e) { 
            System.debug('postStudySearchIndexRequest ERROR: ' + e.getMessage());
        }


    }
}