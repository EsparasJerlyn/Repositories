/**
 * @description Handler for B2BStoreSearchIndexScheduler
 * @see CallBuildSearchIndex Trigger
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | November 22, 2021     | DEPP-131               | Created file                 | 
      |                                |                       |                        |                              | 
 */
public with sharing class B2BStoreSearchIndexHandler {
     

    /**
    * @description Method for calling the store search index
    */
     public void buildSearchIndex(){
         
      B2BStoreSearchIndexScheduler.postCCESearchIndexRequest();
      B2BStoreSearchIndexScheduler.postStudySearchIndexRequest();
         
    }
}