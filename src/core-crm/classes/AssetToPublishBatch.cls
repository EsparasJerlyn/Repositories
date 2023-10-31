/**
 * @description Batch class to publish related product requests of assets
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin   	       | Aug 11, 2022          | DEPP-3481              | Created file                 | 
 */
public class AssetToPublishBatch implements Database.Batchable<sObject> {
    private static final String PR_PUBLISHED = System.Label.PL_ProductRequest_Published;
    private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
    private static final String PR_NOT_PROCEEDING = System.Label.PL_ProductRequest_Not_Proceeding;

    /**
    * @description to publish Corporate Bundle product requests
    * @param bc - BatchableContext
    * @return query - filtered query of asset records
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        String queryFilter = 
            'SELECT Id, Product_Request__c ' + 
            'FROM Asset ' + 
            'WHERE Publishing_Start_Date__c <= TODAY ' + 
            'And Publishing_End_Date__c > Today '+
            'AND Ready_for_publishing__c = \'Yes\' ' +
            'AND Product_Request__r.Product_Request_Status__c != \''+PR_COMPLETED+'\' ' +
            'AND Product_Request__r.Product_Request_Status__c != \''+PR_PUBLISHED+'\' ' + 
            'AND Product_Request__r.Product_Request_Status__c != \''+PR_NOT_PROCEEDING+'\' ';
        
        return Database.getQueryLocator(queryFilter);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param assetList - List of assets
    */
    public void execute(Database.BatchableContext bc, List<Asset> assetList){
        try{ 
            Map<Id, Product_Request__c> productRequestToPublish = new Map<Id, Product_Request__c>();

            for(Asset a : assetList){
                productRequestToPublish.put(    
                    a.Product_Request__c, 
                    new Product_Request__c( 
                        Id = a.Product_Request__c, 
                        Product_Request_Status__c = PR_PUBLISHED
                    )
                );
            }

            if(!productRequestToPublish.keySet().isEmpty()){
                update productRequestToPublish.values();
            }

        }catch(Exception e){
           Logger.error('Exception caught in method execute in Apex class AssetToPublishBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
       
    } 

    public void finish(Database.BatchableContext bc) {}//NOPMD
}