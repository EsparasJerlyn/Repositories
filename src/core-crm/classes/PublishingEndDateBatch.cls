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
      |                                |                       |                        |                              | 
 */
global class PublishingEndDateBatch implements Database.Batchable<sObject>
{

    private static final String PR_IN_DELIVERY = System.Label.PL_ProductRequest_InDelivery;
    private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
    private static final String COURSE_OFFERING_API_NAME = hed__Course_Offering__c.SObjectType.getDescribe().getLocalName();
    private static final String PROGRAM_OFFERING_API_NAME = Program_Offering__c.SObjectType.getDescribe().getLocalName();

    /**
    * @description Method to query the product records
    * @param BC - BatchableContext
    * @return query - filtered query of product records
    */
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 
            'SELECT Id,Course__r.ProductRequestID__c,Program_Plan__r.Product_Request__c,' +
            'Course__r.ProductRequestID__r.Product_Request_Status__c,Program_Plan__r.Product_Request__r.Product_Request_Status__c' +
            ' FROM Product2' +
            ' WHERE IsActive = True' +
            ' AND Decommission_Product__c = True' +
            ' AND Publishing_End_date__c <= TODAY' +
            ' AND (Course__r.ProductRequestID__r.Product_Request_Status__c = \'' + PR_IN_DELIVERY + '\'' +
            ' OR Program_Plan__r.Product_Request__r.Product_Request_Status__c = \'' + PR_IN_DELIVERY + '\')';
        return Database.getQueryLocator(query);
    }

    /**
    * @description Method to execute the batch
    * @param BC - BatchableContext
    * @param productList - List of Products
    * @return query - filtered query of product records
    */
    global void execute(Database.BatchableContext BC, List<Product2> productList)
    {
        try{ 
            Set<Id> productRequestIDs = new Set<Id>();
            
            //Setting IsActive to false and adding the corresponding product request Id
            for(Product2 product : productList){
                product.IsActive = false;
                //for products with related courses
                if(
                    product.Course__r.ProductRequestID__c != null &&
                    product.Course__r.ProductRequestID__r.Product_Request_Status__c == PR_IN_DELIVERY
                ){
                    productRequestIDs.add(product.Course__r.ProductRequestID__c);
                }
                //for products with related program plans
                else if(
                    product.Program_Plan__r.Product_Request__c != null &&
                    product.Program_Plan__r.Product_Request__r.Product_Request_Status__c == PR_IN_DELIVERY
                ){
                    productRequestIDs.add(product.Program_Plan__r.Product_Request__c);
                }
            }
            update(productList);

            List<Product_Request__c> productRequestList = new List<Product_Request__c>(
                [
                    SELECT Id 
                    FROM Product_Request__c
                    WHERE Id IN :productRequestIDs
                ]
            );     
            
            if(!productRequestList.isEmpty()){
                //Setting Product Request Status to Completed
                for(Product_Request__c productRequest : productRequestList){
                    productRequest.Product_Request_Status__c = PR_COMPLETED;
                }
                update(productRequestList);
            }
        }catch(Exception e){
           System.debug('PublishingEndDateBatch Error: ' + e.getMessage());
        }
       
    }  
    global void finish(Database.BatchableContext BC) {
        Database.executeBatch(new OfferingStartDateBatch(COURSE_OFFERING_API_NAME));
        Database.executeBatch(new OfferingStartDateBatch(PROGRAM_OFFERING_API_NAME));
    }
}