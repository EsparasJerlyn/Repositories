/**
 * @description Batch class to complete related product requests of buyergroup
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala   	       | Aug 04, 2022          | DEPP-2498              | Created file                 | 
 */
public class BuyerGroupToCompleteBatch implements Database.Batchable<sObject>
{

    private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
    private static final String PR_NOT_PROCEEDING = System.Label.PL_ProductRequest_Not_Proceeding;
    

    /**
    * @description to complete SOA product request
    * @param bc - BatchableContext
    * @return query - filtered query of BuyerGroup records
    */
    public Database.QueryLocator start(Database.BatchableContext bc)
    {

        String query = 
        'SELECT Id, Product_Request__c ' + 
        'FROM BuyerGroup ' + 
    	'WHERE (End_Date__c <= TODAY  OR Publishing_End_Date__c <= TODAY)' + 
        'AND Product_Request__r.Product_Request_Status__c != \' ' + PR_COMPLETED + '\' ' +
        'AND Product_Request__r.Product_Request_Status__c != \' ' + PR_NOT_PROCEEDING + '\'';
        return Database.getQueryLocator(query);
    }
    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param buyerGroupList - List of buyer groups
    */
    public void execute(Database.BatchableContext bc, List<BuyerGroup> buyerGroupList)
    {
        try{ 
            Set<Id> SOAProductRequestIds = new Set<Id>();
            Set<Id> childCCEProductRequest = new Set<Id>();
            Map<Id, Product_Request__c> productRequestToComplete = new Map<Id, Product_Request__c>();
            Map<Id,Associated_Products__c> ascProductsToInactive = new Map<Id,Associated_Products__c>();

            for(BuyerGroup bg: buyerGroupList){
                SOAProductRequestIds.add(bg.Product_Request__c);
                productRequestToComplete.put(   
                    bg.Product_Request__c, 
                    new Product_Request__c( 
                        Id = bg.Product_Request__c, 
                        Product_Request_Status__c = PR_COMPLETED
                    ) 
                );
            }

            for(Related_Product_Request__c rpr: [ 
                SELECT Id, Program__c, Course__c
                FROM Related_Product_Request__c 
                WHERE Program__c IN: SOAProductRequestIds
                AND Course__c != null]){
                    childCCEProductRequest.add(rpr.Course__c);
            }

            //complete child cce product requests
            for(Id cceChild: childCCEProductRequest){
                productRequestToComplete.put(
                    cceChild, 
                    new Product_Request__c( 
                        Id = cceChild, 
                        Product_Request_Status__c = PR_COMPLETED
                    )
                );
            }
            
            //deactivate OPE product request linkage
            for(Associated_Products__c ascProd: [
                SELECT Id, IsActive__c
                FROM Associated_Products__c
                WHERE Product_Request__c IN: SOAProductRequestIds
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
           System.debug(LoggingLevel.WARN, 'BuyerGroupToCompleteBatch Error: ' + e.getMessage());//NOPMD
        }
       
    }  
    public void finish(Database.BatchableContext bc) {}//NOPMD
}