/**
 * @description Handler for PublishingEndDateScheduler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan		       | February 14, 2022     | DEPP-1256              | Created file                 | 
      |                                |                       |                        |                              | 
 */

public with sharing class PublishingEndDateScheduler implements Schedulable {
    
    //Executes
    public void execute (SchedulableContext context){
        isPublishingDate();
    }
    
 	/**
 	* 
    * @description Checks the Publishing End Date is equal or less than the current date at 12AM
    * Updates the IsActive to True and Product Request to Completed
    * 
    */    
    public void isPublishingDate (){
        List<Product2> listProductsActive = new List<Product2>();
        listProductsActive = [SELECT Id,Name,IsActive, 
                        Publishing_End_date__c, Course__r.ProductRequestID__r.Product_Request_Status__c 
                        FROM Product2 WHERE IsActive= TRUE];
        
        List<hed__Course__c> listCourses  = new List<hed__Course__c>();
        listCourses = [SELECT Id, ProductRequestID__c  from hed__Course__c];
        
        List<Product_Request__c> listProductRequests = new List<Product_Request__c>();
        listProductRequests = [SELECT Id, Product_Request_Status__c from Product_Request__c];

                              
        //Setting Product to Inactive and Updating Product Request to Complete
        for(Product2 p: listProductsActive){
            if(p.Publishing_End_date__c <= date.today()){
				p.IsActive = false;
                for(hed__Course__c c: listCourses){
                    if(c.Id == p.Course__c){
                        for(Product_Request__c pr:listProductRequests){
                            if(pr.Id == c.ProductRequestID__c){
                                pr.Product_Request_Status__c = 'Completed';
                            }
                    	}
                    }
                }
            }
        }
       update (listProductsActive);
       update (listProductRequests);
    }
}