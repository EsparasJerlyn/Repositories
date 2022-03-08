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
    /**
    * @description Method to query the product records
    * @param BC - BatchableContext
    * @return query - filtered query of product records
    */
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Date today = System.today();
        String query = 'SELECT Id, Course__r.ProductRequestID__r.Product_Request_Status__c, Publishing_End_date__c,';
			   query += 'Course__r.ProductRequestID__c, IsActive ';
               query += 'FROM Product2 ' ;
               query += 'WHERE IsActive = True ';
               query += 'AND Course__r.ProductRequestID__r.Product_Request_Status__c !=\'Completed\' ';
               query += 'AND Publishing_End_date__c <= today ';
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
            Set<Id> prId = new Set<Id>();
        
            //Setting IsActive to false and adding the corresponding product request Id
            for(product2 p : productList){
                p.IsActive = false;
                prId.add(p.Course__r.ProductRequestID__c);
            }
            
            List<Product_Request__c> listProductRequests = new List<Product_Request__c>();      
            listProductRequests = [SELECT Id from Product_Request__c WHERE Id IN :prId];
            
            //Setting Product Request Status to Complete
            for(Product_Request__c pr :listProductRequests){
                pr.Product_Request_Status__c = 'Completed';
            }
            
            update(productList);
            update(listProductRequests);
        }catch(Exception e){
           System.debug('ERROR: ' + e.getMessage());

        }
       
    }  
    global void finish(Database.BatchableContext BC) {}
}