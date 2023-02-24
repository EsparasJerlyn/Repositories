/**
 * @description Batch class to complete related product requests of buyergroup
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala   	       | Aug 04, 2022         | DEPP-2498              | Created file                 | 
 */
public class BuyerGroupToPublishBatch implements Database.Batchable<sObject>
{
    private static final String PR_PUBLISHED = System.Label.PL_ProductRequest_Published;
    private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
    private static final String PR_NOT_PROCEEDING = System.Label.PL_ProductRequest_Not_Proceeding;

    /**
    * @description to publish SOA product requests
    * @param bc - BatchableContext
    * @return query - filtered query of buyer group records
    */
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        
        String queryFilter ='';
        if(Test.isRunningTest()){
            queryFilter = 'SELECT Id, Product_Request__c ' + 
            'FROM BuyerGroup ' + 
            'WHERE Publishing_Start_Date__c = TOMORROW ' + 
            'AND Ready_for_publishing__c = \'Yes\' ' +
            'AND Product_Request__r.Product_Request_Status__c != \''+PR_COMPLETED+'\' ' +
            'AND Product_Request__r.Product_Request_Status__c != \''+PR_PUBLISHED+'\' ' + 
            'AND Product_Request__r.Product_Request_Status__c != \''+PR_NOT_PROCEEDING+'\' ';
        }else {
            queryFilter = 'SELECT Id, Product_Request__c ' + 
            'FROM BuyerGroup ' + 
            'WHERE Publishing_Start_Date__c <= TODAY ' + 
            'AND Ready_for_publishing__c = \'Yes\' ' +
            'AND Product_Request__r.Product_Request_Status__c != \''+PR_COMPLETED+'\' ' +
            'AND Product_Request__r.Product_Request_Status__c != \''+PR_PUBLISHED+'\' ' + 
            'AND Product_Request__r.Product_Request_Status__c != \''+PR_NOT_PROCEEDING+'\' ';
        }
        
        return Database.getQueryLocator(queryFilter);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param buyerGroupList - List of buyer groups
    */
    public void execute(Database.BatchableContext bc, List<BuyerGroup> buyerGroupList)
    {
        try{ 
            Map<Id, Product_Request__c> productRequestToPublish = new Map<Id, Product_Request__c>();

            for(BuyerGroup bg: buyerGroupList){
                productRequestToPublish.put(    
                    bg.Product_Request__c, 
                    new Product_Request__c( 
                        Id = bg.Product_Request__c, 
                        Product_Request_Status__c = PR_PUBLISHED
                    )
                );
            }

            if(!productRequestToPublish.keySet().isEmpty()){
                update productRequestToPublish.values();
            }

        }catch(Exception e){
           System.debug(LoggingLevel.WARN, 'BuyerGroupToPublishBatch Error: ' + e.getMessage());//NOPMD
        }
       
    }  
    public void finish(Database.BatchableContext bc) {}//NOPMD
}