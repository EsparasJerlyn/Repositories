/**
 * @description Batch class to complete related product requests of assets
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin   	       | Aug. 11, 2022         | DEPP-3481              | Created file                 | 
 */
public class AssetToCompleteBatch implements Database.Batchable<sObject>
{

    private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
    private static final String PR_NOT_PROCEEDING = System.Label.PL_ProductRequest_Not_Proceeding;
    

    /**
    * @description to complete SOA product request
    * @param bc - BatchableContext
    * @return query - filtered query of Asset records
    */
    public Database.QueryLocator start(Database.BatchableContext bc)
    {

        String query = 
        'SELECT Id, Product_Request__c ' + 
        'FROM Asset ' + 
    	'WHERE (End_Date__c <= TODAY  OR Publishing_End_Date__c <= TODAY)' + 
        'AND Product_Request__r.Product_Request_Status__c != \' ' + PR_COMPLETED + '\' ' +
        'AND Product_Request__r.Product_Request_Status__c != \' ' + PR_NOT_PROCEEDING + '\'';
        return Database.getQueryLocator(query);
    }
    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param assetList - List of assets
    */
    public void execute(Database.BatchableContext bc, List<Asset> assetList)
    {
        try{ 
            Set<Id> corporateBundleProductRequestIds = new Set<Id>();
            Map<Id, Product_Request__c> productRequestToComplete = new Map<Id, Product_Request__c>();
            Map<Id, Associated_Products__c> ascProductsToInactive = new Map<Id, Associated_Products__c>();

            for(Asset a: assetList){
                corporateBundleProductRequestIds.add(a.Product_Request__c);
                productRequestToComplete.put(   
                    a.Product_Request__c, 
                    new Product_Request__c( 
                        Id = a.Product_Request__c, 
                        Product_Request_Status__c = PR_COMPLETED
                    ) 
                );
            }

            //deactivate OPE product request linkage
            for(Associated_Products__c ascProd: [
                SELECT Id, IsActive__c
                FROM Associated_Products__c
                WHERE Product_Request__c IN: corporateBundleProductRequestIds
                AND IsActive__c = true
            ]){
                ascProd.IsActive__c = false;
                ascProductsToInactive.put(ascProd.Id,ascProd);
            }

            if(!ascProductsToInactive.keySet().isEmpty()){
                update ascProductsToInactive.values();
            }

            if(!productRequestToComplete.keySet().isEmpty()){
                update productRequestToComplete.values();
            }

        }catch(Exception e){
           Logger.error('Exception caught in AssetToCompleteBatch.cls').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  
    public void finish(Database.BatchableContext bc) {} //NOPMD
}