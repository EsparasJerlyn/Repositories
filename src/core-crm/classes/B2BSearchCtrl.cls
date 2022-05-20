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
      | roy.nino.s.regala              | February 04, 2022     | DEPP-213               | Updated to use API Methods   | 
 */
public without sharing class B2BSearchCtrl {
 
    /**
     * @description method to call ConnectApi.CommerceSearch.searchProducts
    * @param communityId The Id of the community from which the call originated
    * @param producteffectiveAccountIdId 
    * @param  ConnectApi.ProductSearchInput searchQuery
    */  
    @AuraEnabled
    public static ConnectApi.ProductSearchResults searchProducts(
    String communityId,
    String effectiveAccountId,
    ConnectApi.ProductSearchInput searchQuery
    ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    if(Test.isRunningTest()){
        return null;
    }else{
        //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods
        return ConnectApi.CommerceSearch.searchProducts( webstoreId, effectiveAccountID, searchQuery );
    }

    }

    /**
     * @description Will get sort collections.
     * @param communityId The Id of the community from which the call originated
     * @return ConnectApi.SortRulesCollection
     */
    @AuraEnabled(cacheable=true)
    public static ConnectApi.SortRulesCollection getSortRules(
        String communityId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

        if(Test.isRunningTest()){
        return null;
        }else{
        return ConnectApi.CommerceSearch.getSortRules( webstoreId );
        }
    }

}