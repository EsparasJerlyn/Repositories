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
 */
public class PublishingEndDateBatch implements Database.Batchable<sObject>
{

    private static final String PR_IN_DELIVERY = System.Label.PL_ProductRequest_InDelivery;
    private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
    private static final String PR_RELEASE = System.Label.PL_ProductRequest_Release;
    private static final String PR_DESIGN = System.Label.PL_ProductRequest_Design;
    private static final String PS_COMPLETE = System.Label.PL_ProductSpecification_Complete;
    private static final String COURSE_OFFERING_API_NAME = hed__Course_Offering__c.SObjectType.getDescribe().getLocalName();
    private static final String PROGRAM_OFFERING_API_NAME = Program_Offering__c.SObjectType.getDescribe().getLocalName();

    /**
    * @description Method to query the product records
    * @param bc - BatchableContext
    * @return query - filtered query of product records
    */
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 
        ' SELECT Id,Course__r.ProductRequestID__c,Program_Plan__r.Product_Request__c, Course__r.ProductRequestID__r.Product_Specification__c,  Program_Plan__r.Program_Delivery_Structure__c,' +
        ' Program_Plan__r.Product_Request__r.Product_Specification__c, Course__r.ProductRequestID__r.Product_Request_Status__c,Program_Plan__r.Product_Request__r.Product_Request_Status__c,' + 
        ' Decommission_Product__c,Publishing_End_date__c,Course__r.End_Date__c, Course__r.Start_Date__c, Program_Plan__r.hed__End_Date__c, Program_Plan__r.hed__Start_Date__c, Available_on_Cart__c' +
        ' FROM Product2' + 
        ' WHERE ((Course__r.End_Date__c <= TODAY OR Program_Plan__r.hed__End_Date__c <= TODAY OR (Decommission_Product__c = true AND Publishing_End_Date__c <= TODAY))' +
        ' AND ((Course__r.ProductRequestID__r.Product_Request_Status__c = \''+PR_IN_DELIVERY + '\' OR Program_Plan__r.Product_Request__r.Product_Request_Status__c = \''+ PR_IN_DELIVERY + '\')' +
        ' OR (Course__r.ProductRequestID__r.Product_Request_Status__c = \''+PR_RELEASE + '\' OR Program_Plan__r.Product_Request__r.Product_Request_Status__c = \''+ PR_RELEASE + '\')' +
        ' OR (Course__r.ProductRequestID__r.Product_Request_Status__c = \''+PR_DESIGN + '\' OR Program_Plan__r.Product_Request__r.Product_Request_Status__c = \''+ PR_DESIGN + '\')))' +
        ' OR (IsActive = true AND Publishing_End_date__c <= TODAY)' +
        ' OR (Course__r.Start_Date__c != null OR Program_Plan__r.hed__Start_Date__c != null)';
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
            Date today = System.today();
            Map<Id,Product_Request__c> productReqToUpdate = new Map<Id,Product_Request__c>();
            List<Product_Specification__c> productSpecsToComplete = new List<Product_Specification__c>();
            Set<Id> parentProdReqIds = new Set<Id>();
            Set<Id> parentProductSpecsIds = new Set<Id>();
            
            //Setting IsActive to false and adding the corresponding product request Id
            for(Product2 product : productList){
                if(product.Publishing_End_date__c <=today){
                    product.IsActive = false;
                }
                //for products with related courses
                if(
                    product.Course__r.ProductRequestID__c != null &&
                    (product.Course__r.ProductRequestID__r.Product_Request_Status__c == PR_IN_DELIVERY ||
                    product.Course__r.ProductRequestID__r.Product_Request_Status__c == PR_RELEASE) &&
                    (product.Course__r.End_Date__c == today ||
                    (product.Decommission_Product__c == True && 
                    product.Publishing_End_date__c == today))
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
                if(product.Course__r.Start_Date__c <= today - 1 && product.Course__r.ProductRequestID__r.Product_Request_Status__c == PR_RELEASE){
                    productReqToUpdate.put(
                    product.Course__r.ProductRequestID__c, 
                        new Product_Request__c
                        (
                            Id = product.Course__r.ProductRequestID__c, 
                            Product_Request_Status__c = PR_IN_DELIVERY
                        )
                    );
                }
                if(product.Course__r.End_Date__c <= today){
                    productReqToUpdate.put(
                    product.Course__r.ProductRequestID__c, 
                        new Product_Request__c
                        (
                            Id = product.Course__r.ProductRequestID__c, 
                            Product_Request_Status__c = PR_COMPLETED
                        )
                    );
                }
                //for products with related program plans
                else if(
                    product.Program_Plan__r.Product_Request__c != null &&
                    (product.Program_Plan__r.Product_Request__r.Product_Request_Status__c == PR_IN_DELIVERY ||
                    product.Program_Plan__r.Product_Request__r.Product_Request_Status__c == PR_RELEASE)  &&
                    ((product.Publishing_End_date__c == today && 
                    product.Decommission_Product__c == True) ||
                    product.Program_Plan__r.hed__End_Date__c == today)
                ){
                    productReqToUpdate.put(
                        product.Program_Plan__r.Product_Request__c,
                        new Product_Request__c
                        (
                            Id = product.Program_Plan__r.Product_Request__c,
                            Product_Request_Status__c = PR_COMPLETED
                        )
                    );
                    if(product.Program_Plan__r.Program_Delivery_Structure__c == 'Prescribed Program'){
                        parentProdReqIds.add(product.Program_Plan__r.Product_Request__c);
                    }
                    if(product.Program_Plan__r.Product_Request__r.Product_Specification__c != null){
                        parentProductSpecsIds.add(product.Program_Plan__r.Product_Request__r.Product_Specification__c);
                    }
                    product.Available_on_Cart__c = false;
                }
                if(product.Program_Plan__r.hed__Start_Date__c < today && product.Program_Plan__r.Product_Request__r.Product_Request_Status__c == PR_RELEASE){
                    productReqToUpdate.put(
                        product.Program_Plan__r.Product_Request__c, 
                        new Product_Request__c
                        (
                            Id = product.Program_Plan__r.Product_Request__c,
                            Product_Request_Status__c = PR_IN_DELIVERY
                        )
                    );
                }
                if(product.Program_Plan__r.hed__End_Date__c <= today){
                    productReqToUpdate.put(
                        product.Program_Plan__r.Product_Request__c, 
                        new Product_Request__c
                        (
                            Id = product.Program_Plan__r.Product_Request__c,
                            Product_Request_Status__c = PR_COMPLETED
                        )
                    );
                }
            }
            update(productList);

            List<Related_Product_Request__c> relatedPR = new List<Related_Product_Request__c>(
                [
                    SELECT Id, Program__c, Course__c
                    FROM Related_Product_Request__c
                    WHERE Course__r.Product_Request_Status__c !=: PR_COMPLETED 
                    AND Program__c IN: parentProdReqIds
                ]
            );
    
            for(Related_Product_Request__c rPR: relatedPR){
                productReqToUpdate.put(rPR.Course__c,new Product_Request__c(Id = rPR.Course__c, Product_Request_Status__c = PR_COMPLETED));
            }
            update(productReqToUpdate.values());

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

            update(productSpecsToComplete);

        }catch(Exception e){
           System.debug(LoggingLevel.WARN, 'PublishingEndDateBatch Error: ' + e.getMessage());//NOPMD
        }
       
    }  
    public void finish(Database.BatchableContext bc) {
        Database.executeBatch(new OfferingStartDateBatch(COURSE_OFFERING_API_NAME));
        Database.executeBatch(new OfferingStartDateBatch(PROGRAM_OFFERING_API_NAME));
    }
}