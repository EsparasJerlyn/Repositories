/**
 * @description Demonstrates how to make REST calls to ConnectApi.CommerceSearch class
 * to perform Search and Category browsing
 *
 * @see ../core-crm/classes/B2BUtils
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | October 27, 2021      | DEPP-174               | Created file                 | 
      |                                |                       |                        |                              | 
 */
public without sharing class B2BSearchCtrl {
    // Cached API version of this apex class.
    private static Decimal apiVersionApexClass = [
        SELECT ApiVersion
        FROM ApexClass
        WHERE Name = 'B2BSearchCtrl'
        LIMIT 1
    ]
    .ApiVersion;

    /**
     * @description Demonstrates how to call ConnectApi.CommerceSearch.productSearch
     * @param communityId The Id of the community from which the call originated
     * @param searchQuery The search query parameters which includes searchTerm, categoryId, refinements, page and includePrices
     * @param @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
     */
    @AuraEnabled(cacheable=true)
    public static Object productSearch(
        String communityId,
        String searchQuery,
        String effectiveAccountId
    ) {
       	AuraHandledException auraEx = new AuraHandledException('Error Message');  
        auraEx.setMessage('Error while getting response.'); 
        
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(
            communityId
        );

        HttpRequest httpRequest = new HttpRequest();
        Object response;
  
        // As per the Salesforce documentation
        // "By security policy, sessions created by Lightning components aren’t
        //  enabled for API access. This prevents even your Apex code from
        //  making API calls to Salesforce. Using a named credential for
        //  specific API calls allows you to carefully and selectively bypass
        // this security restriction."
        // - https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/apex_api_calls.htm
        //
        // So the following section that takes the OAuth is commented out and
        // used the named credential callout 'CallMeBack' below.
        // The steps to create named credentials are documented the repo here
        // docs/NamedCredentials.md

         String UserSession = UserInfo.getSessionId();
         httpRequest.setMethod('POST');
         httpRequest.setHeader('Content-Type', 'application/json');
         httpRequest.setHeader('Authorization', 'OAuth ' + UserSession);

         String baseUrl = URL.getOrgDomainUrl().toExternalForm();
         String apiUrl = '/services/data/v' + apiVersionApexClass + '/commerce/webstores/' + webstoreId + '/search/product-search?effectiveAccountId='+effectiveAccountId;
         httpRequest.setEndpoint(baseUrl + apiUrl);
         httpRequest.setBody(searchQuery);
        
        try{
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            Integer statusCode = httpResponse.getStatusCode();

            if(statusCode >= 200 && statusCode <= 204){
                response = JSON.deserializeUntyped(httpResponse.getBody());
            }else{
                throw new CalloutException(httpResponse.getBody());
            }
        }catch(System.Exception e){
           	throw auraEx;	
        }
        return response;
    }

    /**
     * @description Will get sort collections.
     * @param communityId The Id of the community from which the call originated
     */
    @AuraEnabled(cacheable=true)
    public static Object getSortCollections( String communityId ) {
        AuraHandledException auraEx = new AuraHandledException('Error Message');  
        auraEx.setMessage('Error while getting sort collections response.'); 
        
        String UserSession = UserInfo.getSessionId();
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(
            communityId
        );

        HttpRequest httpRequest = new HttpRequest();
        Object response;

        httpRequest.setMethod('GET');
        httpRequest.setHeader('Authorization', 'OAuth ' + UserSession); 

        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String apiUrl = '/services/data/v'+ apiVersionApexClass +'/commerce/webstores/'+ webstoreId +'/search/sort-rules';
        httpRequest.setEndpoint(baseUrl + apiUrl);
		
        try{
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            Integer statusCode = httpResponse.getStatusCode();

            if(statusCode >= 200 && statusCode <= 204){
                response = JSON.deserializeUntyped(httpResponse.getBody());
            }else{
                throw new CalloutException(httpResponse.getBody());
            }
        }catch(System.Exception e){
           throw auraEx;	
        }
        return response;
    }
}