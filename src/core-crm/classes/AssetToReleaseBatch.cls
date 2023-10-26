/**
 * @description Batch class to return to release related product requests of assets
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | sebastianne.k.trias            | August 11, 2023       | DEPP-6240              | Created file                 |
 */
public class AssetToReleaseBatch implements Database.Batchable<sObject> {
    private static final String PR_RELEASE = System.Label.PL_ProductRequest_Release;
    private static final String PR_PUBLISHED = System.Label.PL_ProductRequest_Published;
    private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
    private static final String PR_NOT_PROCEEDING = System.Label.PL_ProductRequest_Not_Proceeding;
   

    /**
    * @description return to release if published Corporate Bundle product requests Publishing End Date has ended and End Date has not yet ended
    * @param bc - BatchableContext
    * @return query - filtered query of asset records
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        String queryFilter = 
            'SELECT Id, Product_Request__c ' + 
            'FROM Asset ' + 
            'WHERE Publishing_End_Date__c <= TODAY ' +
            'AND End_Date__c >= TODAY ' +
            'AND Product_Request__r.Product_Request_Status__c = \''+PR_PUBLISHED+'\' ';
        
        return Database.getQueryLocator(queryFilter);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param assetList - List of assets
    */
    public void execute(Database.BatchableContext bc, List<Asset> assetList){
        try{ 
            Map<Id, Product_Request__c> productRequestToRelease = new Map<Id, Product_Request__c>();

            for(Asset a : assetList){
                productRequestToRelease.put(    
                    a.Product_Request__c, 
                    new Product_Request__c( 
                        Id = a.Product_Request__c, 
                        Product_Request_Status__c = PR_RELEASE
                    )
                );
            }

            if(!productRequestToRelease.keySet().isEmpty()){
                update productRequestToRelease.values();
            }

        }catch(Exception e){
           System.debug(LoggingLevel.WARN, 'AssetToReleaseBatch Error: ' + e.getMessage());//NOPMD
        }
       
    }

    public void finish(Database.BatchableContext bc) {}//NOPMD
}