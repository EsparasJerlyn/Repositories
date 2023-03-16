/**
 * @description An apex page controller that takes the user to the right start page based on credentials or lack thereof
 * @see ../
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | marygrace.li@qut.edu.au   | August 16, 2022       | DEPP-3676            | Created file                 |
      |                           |                       |                      |                              | 
 */

public with sharing class CustomCommunitiesLandingController {
   /**
    * @description Method that will invoke on page load
    * @return landingUrl - returns the landing page URL
    */
    public PageReference forwardToCustomStartPage() {
      
        String communityUrl = Site.getBaseUrl();
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        if (startUrl == null) startUrl = '';
        if (UserInfo.getUserType().equals('Guest')) {
            return new PageReference(EncodingUtil.urlEncode(communityUrl + '/s/login', 'UTF-8'));
        } else {
            return Network.communitiesLanding(); 
        }   
    }

     public CustomCommunitiesLandingController() {}//NOPMD

}