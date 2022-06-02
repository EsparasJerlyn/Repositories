/**
 * @description  trigger for product request
 * @see ProductRequestTrigger
 *
 * @author Accenture
 *
  * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | roy.nino.s.regala         | June 02, 2022         | DEPP-2863 | Created file                    |
*/

public without sharing class ProductRequestTriggerHandler implements Disableable, AfterUpdate {


    private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
    private static final String PR_NOT_PROCEEDING = System.Label.PL_ProductRequest_Not_Proceeding;

    public static Boolean isRunning = false;
    
    /**
     * @description call method to validate related Facilitator Contacts if Image is uploaded on Contact Image
     * @param newItems - List of Product2.Trigger.new
     * @param oldItems - List of Product2.Trigger.old
     */
    public void AfterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
        ) {

        Map<Id, Product2> productToUpdateMap = new Map<Id,Product2>();
        Map<Id, Product2> productToDeactivate = new Map<Id,Product2>();

        Map<Id, Product_Request__c> prodReqNew = (Map<Id, Product_Request__c>)newItems;
        Map<Id, Product_Request__c> prodReqOld = (Map<Id, Product_Request__c>)oldItems;

        List<Id> completedOrNotProceedingPRs = new List<Id>();  
        if(!isRunning){
            isRunning = true;

            //check if status is updated and is not proceeding or completed
            for(Id prId: prodReqNew.keySet()){
                if(prodReqNew.get(prId).Product_Request_Status__c != prodReqOld.get(prId).Product_Request_Status__c 
                    && (prodReqNew.get(prId).Product_Request_Status__c == PR_NOT_PROCEEDING || 
                    prodReqNew.get(prId).Product_Request_Status__c == PR_COMPLETED)){
                        //store all productrequests that are updated to completed or not completed
                        completedOrNotProceedingPRs.add(prId);
                    }
            } 

            if(!completedOrNotProceedingPRs.isEmpty()){
                productToDeactivate.putALL(deactivateRelatedProduct(
                    completedOrNotProceedingPRs
                ));
            }
            
            if(!productToDeactivate.keySet().isEmpty()){
                productToUpdateMap.putALL(productToDeactivate);
            }

            if(!productToUpdateMap.keySet().isEmpty()){
                update productToUpdateMap.values();
            }
        }
    }

    /**
     * @description deactive related products
     * @param completedOrNotProceedingPRs - ids of completed and not proceeding PRs
     * @return map of products to be deactivated
     */
    public static Map<Id, Product2> deactivateRelatedProduct(
        List<Id> completedOrNotProceedingPRs 
        ){

        Map<Id,Product2> relatedProductMap = new Map<Id,Product2>();  
        List<Product2> productsList = new List<Product2>();

        //query products to be deactivated
        if(!completedOrNotProceedingPRs.isEmpty()){
            productsList =  [   
                    SELECT Id, Course__r.ProductRequestID__c, Program_Plan__r.Product_Request__c
                    FROM Product2 
                    WHERE IsActive = true 
                    AND (Course__r.ProductRequestID__c IN: completedOrNotProceedingPRs 
                    OR Program_Plan__r.Product_Request__c IN: completedOrNotProceedingPRs) 
                    ];
        }

        //deactivate products
        for(Product2 prod: productsList){
            prod.IsActive = false;
            relatedProductMap.put(prod.Id,prod);
        }

        return relatedProductMap;   
    }
      
    /**
     * @description indicates it the trigger is disabled
     * @return disabled bypass
     */
      public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
      }
      
    }