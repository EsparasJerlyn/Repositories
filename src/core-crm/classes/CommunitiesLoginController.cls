/**
 * @description An apex page controller that exposes the site login functionality
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li                   | January 3, 2023       | N/A                    | Fix PMD issue,               |
      |                                |                       |                        | removed empty block statement|
      |                                |                       |                        |                              |
 */
public with sharing class CommunitiesLoginController {
    
    // Code we will invoke on page load.
    public PageReference forwardToAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        String displayType = System.currentPageReference().getParameters().get('display');
        return Network.forwardToAuthPage(startUrl, displayType);
    }
}
