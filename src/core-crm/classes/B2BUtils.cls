/**
 * @description Util methods for B2B commerce
 * @see ../core-crm/classes/B2BUtils
 * @see ../core-crm/classes/B2BStoreSearchIndexScheduler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | November 16, 2021     | DEPP-131               | Created file                 | 
      | rhea.b.torres                  | June 17, 2022         | DEPP-3095              | Add @TestVisible to private  | 
      |                                |                       |                        | class member                 | 
      |                                |                       |                        |                              | 
 */
public with sharing class B2BUtils {

  // A cache which maps community Ids to WebStore Ids
  @TestVisible private static Map<String, String> communityIdToWebStoreIdCache = new Map<String, String>();

  /**
   * @description Given a community ID, returns the relavent webstore ID for use in B2B Commerce on lightning
   * @param  communityId The Id of the community from which the call originated
   * @return weStoreId The webStoreId corresponding to the community Id.
   * @example
   * String webStoreId = B2BUtils.resolveCommunityIdToWebstoreId('0DB2D0000004Xz7');
   */
  public static String resolveCommunityIdToWebstoreId(String communityId) {
    if(communityIdToWebStoreIdCache.containsKey(communityId)) {
      return communityIdToWebStoreIdCache.get(communityId);
    }else{
      List<WebStoreNetwork> webStoreNetwork = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1];
      if(!webStoreNetwork.isEmpty()){
        communityIdToWebStoreIdCache.put(communityId, webStoreNetwork[0].WebStoreId);
        return webStoreNetwork[0].WebStoreId;
      }else{
        return null;
      }
    }
  }

   /**
   * @description get Community Id by name
   * @param communityName A string representing a community/store name
   * return community id or null
   **/
   
   public static String getCommunityIdByName(String communityName) {
    List<Network> networkList = [SELECT Id, Name FROM Network WHERE Name = :communityName  WITH SECURITY_ENFORCED LIMIT 1];
    
    return (networkList.size() > 0) ? networkList.get(0).Id : null;
  }
    
   /**
   * @description get API version of an Apex Class
   * @param className A string representing a Apex classname.
   * return apiVersion
   **/
   public static Decimal getAPIVersion(String className) {
    Decimal apiVersionApexClass = 53.0; // Set default

    List<ApexClass> results = [SELECT ApiVersion FROM ApexClass WHERE Name = :className  WITH SECURITY_ENFORCED LIMIT 1];
    
    return (results.size() > 0) ? results.get(0).ApiVersion : apiVersionApexClass;
  }

}