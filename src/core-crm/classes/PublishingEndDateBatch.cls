/**
 * @description Batch class that Changes the Active Status of the Product and Completes the Product Request
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan		       | February 28, 2022     | DEPP-1256              | Created file                 | 
      | rhea.b.torres   		       | January 17, 2023      | DEPP-4909              | Added criteria for when a    | 
      |                                |                       |                        | a Product Request is set to  |
      |                                |                       |                        | "Published" and refactored   |
      |                                |                       |                        | methods for PMD fixes        |
      | rhea.b.torres                  | February 14, 2023     | DEPP-5182              | Updated QueryLocator query   | 
      |                                |                       |                        | and added Logger             | 
 */
public class PublishingEndDateBatch implements Database.Batchable<sObject>
{

    private static final String PR_PUBLISHED = System.Label.PL_ProductRequest_InDelivery;
    private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
    private static final String PR_RELEASE = System.Label.PL_ProductRequest_Release;
    private static final String PR_DESIGN = System.Label.PL_ProductRequest_Design;
    private static final String PS_COMPLETE = System.Label.PL_ProductSpecification_Complete;
    private String originalTransactionId;

    /**
    * @description Method to query the product records
    * @param bc - BatchableContext
    * @return query - filtered query of product records
    */
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        //store the first transaction ID to later relate the other transactions
        this.originalTransactionId = Logger.getTransactionId();
        Logger.info('Starting PublishingEndDateBatch');
        Logger.saveLog();

        String query = 
        ' SELECT Id,Course__r.ProductRequestID__c,Program_Plan__r.Product_Request__c, Course__r.ProductRequestID__r.Product_Specification__c,  Program_Plan__r.Program_Delivery_Structure__c,' +
        ' Program_Plan__r.Product_Request__r.Product_Specification__c, Course__r.ProductRequestID__r.Product_Request_Status__c,Program_Plan__r.Product_Request__r.Product_Request_Status__c,' + 
        ' Decommission_Product__c,Publishing_End_date__c,Course__r.End_Date__c, Course__r.Start_Date__c, Program_Plan__r.hed__End_Date__c, Program_Plan__r.hed__Start_Date__c, Available_on_Cart__c,' +
        ' Ready_for_publishing__c, Publishing_Start_date__c' +
        ' FROM Product2' + 
        ' WHERE IsActive = true AND ((Course__r.End_Date__c <= TODAY OR Program_Plan__r.hed__End_Date__c <= TODAY) OR (Decommission_Product__c = true AND Publishing_End_Date__c <= TODAY)' +
        ' OR (Course__r.ProductRequestID__r.Product_Request_Status__c = \''+PR_RELEASE + '\' OR Program_Plan__r.Product_Request__r.Product_Request_Status__c = \''+ PR_RELEASE + '\'))';

        return Database.getQueryLocator(query);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param productList - List of Products
    * @return query - filtered query of product records
    */
    public void execute(Database.BatchableContext bc, List<Product2> productList)
    {
        try{
            Logger.setParentLogTransactionId(this.originalTransactionId);
            Logger.saveLog();

            Map<Id,Product_Request__c> productReqToUpdate = new Map<Id,Product_Request__c>();
            Set<Id> parentProdReqIds = new Set<Id>();
            Set<Id> parentProductSpecsIds = new Set<Id>();
            
            //Setting IsActive to false and adding the corresponding product request Id
            for(Product2 product : productList){
                /** Decommision the Product */
                if(product.Decommission_Product__c == True && product.Publishing_End_date__c <= System.today()){
                    product.IsActive = false;
                }

                /** Transition Product Request to Release stage when product is ready for publishig and publishing start date is equal to
                 * today or in the past */
                publishProductRequestRelatedToCourse(product, productReqToUpdate);

                /** Transition Program Plan to Release stage when product is ready for publishig and publishing start date is equal to
                 * today or in the past*/
                publishProductRequestRelatedToProgramPlan(product, productReqToUpdate);
                
                /** Processing related Courses of the Product.
                 * Transition Product Request to Complete stage */
                completeProductRequestRelatedToCourse(product, productReqToUpdate, parentProductSpecsIds);
                
                /** Processing related Program Plans of the Product
                 * Transition Program Plan Program Plan to Complete stage */
                Boolean result = completeProductRequestRelatedToProgramPlan(product, productReqToUpdate);
                if(result){
                    parentProdReqIds.add(getParentProductRequestForPrescibedProgram(product));
                    parentProductSpecsIds.add(getParentProductSpecificationOfProgramPlan(product));
                }
            }
            Database.SaveResult[] srList=  Database.update(productList, false);
            logDatabaseResultToLogger(srList, 'execute()');

            /** Update related Product Requests of a Program Plan*/
            updateRelatedProductRequests(parentProdReqIds, productReqToUpdate);

             /** Updating Product Specification stage to Complete when all related Product Requests status is Completed */
            updateProductSpecification(parentProductSpecsIds);

        }catch(Exception e){
            Logger.error('Executing execute() method of PublishingEndDateBatch with Exception:').setExceptionDetails(e);
        }
       
    }  
    public void finish(Database.BatchableContext bc) {} //NOPMD

    private void updateProductSpecification(Set<Id> parentProductSpecsIds){
        List<Product_Specification__c> productSpecsToComplete = new List<Product_Specification__c>();
        List<Product_Specification__c> productSpecificationList = new List<Product_Specification__c>(
            [
                SELECT Id, Status__c,
                (SELECT Id FROM Product_Requests__r WHERE Product_Request_Status__c !=: PR_COMPLETED)
                FROM Product_Specification__c
                WHERE Id =: parentProductSpecsIds
            ]
        );  

        for(Product_Specification__c prodSpec : productSpecificationList){
            if(prodSpec.Product_Requests__r.isEmpty()){
                prodSpec.Stage__c = PS_COMPLETE;
                productSpecsToComplete.add(prodSpec);
            }
        }

        Database.SaveResult[] srList=  Database.update(productSpecsToComplete, false);
        logDatabaseResultToLogger(srList, 'updateProductSpecification()');
    }

    private void updateRelatedProductRequests(Set<Id> parentProdReqIds, Map<Id,Product_Request__c> productReqToUpdate){
        List<Related_Product_Request__c> relatedPR = new List<Related_Product_Request__c>(
            [
                SELECT Id, Program__c, Course__c
                FROM Related_Product_Request__c
                WHERE Course__r.Product_Request_Status__c !=: PR_COMPLETED 
                AND Program__c IN: parentProdReqIds
            ]
        );

        for(Related_Product_Request__c rPR: relatedPR){
            productReqToUpdate.put(rPR.Course__c, new Product_Request__c(Id = rPR.Course__c, Product_Request_Status__c = PR_COMPLETED));
        }

        Database.SaveResult[] srList=  Database.update(productReqToUpdate.values(), false);
        logDatabaseResultToLogger(srList, 'updateRelatedProductRequests()');
    }

    private void publishProductRequestRelatedToCourse(Product2 product, Map<Id,Product_Request__c> productReqToUpdate){
        if(product.Course__r.Start_Date__c < System.today()
            && product.Course__r.ProductRequestID__r.Product_Request_Status__c == PR_RELEASE
            && product.Ready_for_publishing__c == 'Yes'
            && product.Publishing_Start_date__c <= Date.today()){

            productReqToUpdate.put(
                product.Course__r.ProductRequestID__c, 
                    new Product_Request__c
                    (
                        Id = product.Course__r.ProductRequestID__c, 
                        Product_Request_Status__c = PR_PUBLISHED
                    )
                );
        }
    }

    private void publishProductRequestRelatedToProgramPlan(Product2 product, Map<Id,Product_Request__c> productReqToUpdate){
        if(product.Program_Plan__r.hed__Start_Date__c < System.today()
            && product.Program_Plan__r.Product_Request__r.Product_Request_Status__c == PR_RELEASE
            && product.Ready_for_publishing__c == 'Yes'
            && product.Publishing_Start_date__c <= Date.today()){

            productReqToUpdate.put(
                product.Program_Plan__r.Product_Request__c, 
                new Product_Request__c
                (
                    Id = product.Program_Plan__r.Product_Request__c,
                    Product_Request_Status__c = PR_PUBLISHED
                )
            );
        }
    }

    private void completeProductRequestRelatedToCourse(Product2 product, Map<Id,Product_Request__c> productReqToUpdate, Set<Id> parentProductSpecsIds){
        if(product.Course__r.ProductRequestID__c != null
            && ((product.Course__r.End_Date__c <= System.today())
                || (product.Decommission_Product__c == True && product.Publishing_End_date__c <= System.today())
                )
        ){

            productReqToUpdate.put(
                product.Course__r.ProductRequestID__c, 
                new Product_Request__c
                (
                    Id = product.Course__r.ProductRequestID__c, 
                    Product_Request_Status__c = PR_COMPLETED
                )
            );

            if(product.Course__r.ProductRequestID__r.Product_Specification__c != null){
                parentProductSpecsIds.add(product.Course__r.ProductRequestID__r.Product_Specification__c);
            }

            product.Available_on_Cart__c = false;
        }
    }

    private Boolean completeProductRequestRelatedToProgramPlan(Product2 product,
                                                            Map<Id,Product_Request__c> productReqToUpdate){
        Boolean isProductRequestSetToComplete = false;
        if(product.Program_Plan__r.Product_Request__c != null 
            && (product.Program_Plan__r.hed__End_Date__c <= System.today()
                ||(product.Decommission_Product__c == True && product.Publishing_End_date__c <= System.today()))){

            productReqToUpdate.put(
                product.Program_Plan__r.Product_Request__c,
                new Product_Request__c
                (
                    Id = product.Program_Plan__r.Product_Request__c,
                    Product_Request_Status__c = PR_COMPLETED
                )
            );

            isProductRequestSetToComplete = true;
            product.Available_on_Cart__c = false;
        }

        return isProductRequestSetToComplete;
    }

    private Id getParentProductRequestForPrescibedProgram(Product2 product){
        Id parentProdRequestId =  null;
        if(product.Program_Plan__r.Program_Delivery_Structure__c == 'Prescribed Program'){
            parentProdRequestId = product.Program_Plan__r.Product_Request__c;
        }
        return parentProdRequestId;
    }

    private Id getParentProductSpecificationOfProgramPlan(Product2 product){
        Id parentProductSpecsId =  null;
        if(product.Program_Plan__r.Product_Request__r.Product_Specification__c != null){
            parentProductSpecsId = product.Program_Plan__r.Product_Request__r.Product_Specification__c;
        }
        return parentProductSpecsId;
    }

    private void logDatabaseResultToLogger(Database.SaveResult[] srList, String methodName){
        for (Database.SaveResult sr : srList) {
            if(!sr.isSuccess()){
                Logger.error('[PublishEndDateBatch.'+ methodName + '] Database Result: ').setDatabaseResult(sr);
            }
        }
        if(Logger.getBufferSize() <0){
            Logger.saveLog();
        }
    }
}