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
      | eugene.andrew.abuan            | March 02, 2022        | DEPP-1256              | Added if statement to check  |
      |                                |                       |                        | if it is called from batch   |
      |                                |                       |                        |                              |     
 */
public with sharing class B2BStoreSearchIndexHandler {
     

    /**
    * @description Method for calling the store search index
    */
     public void buildSearchIndex(){
         if(!System.isBatch()){
            B2BStoreSearchIndexScheduler.postCCESearchIndexRequest();
          	B2BStoreSearchIndexScheduler.postStudySearchIndexRequest();
         }
    }
}