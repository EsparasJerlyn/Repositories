/**
 * @description An apex page controller that takes the user to the right start page based on credentials or lack thereof
 * @see ../
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | marygrace.li@qut.edu.au   | May 26, 2022          | DEPP-2757            | Created file                 |
      |                           |                       |                      |                              | 
 */

public with sharing class CommunitiesLandingController {
   /**
    * @description Method that will invoke on page load
    * @return landingUrl - returns the landing page URL
    */
    public PageReference forwardToStartPage() {
        String cId = null;
        String landingUrl;
        String categoryName=null;
        
        Site site = [SELECT Id FROM Site WHERE UrlPathPrefix = 'study' LIMIT 1];
        String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;

       	ProductCategory categoryId = [SELECT Id, Name FROM ProductCategory WHERE Name = 'Products' AND Catalog.Name = 'Study Catalog'];
        cId = categoryId.Id;

        if(cId !=null ){
            landingUrl= communityUrl + '/s/category/products/'+cId;
        }else{
            landingUrl = communityUrl + '/s/';
        }
        System.Debug(landingUrl);
    
        return new PageReference (landingUrl);
    } 
}