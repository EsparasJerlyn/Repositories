/**
 * @description Controller Class for productRequestList LWC
 * @see ../lwc/productRequestList
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | angelika.j.s.galang       | September 30, 2021    | DEPP-40,42           | Created file                 |
      |                           |                       |                      |                              | 
 */
public with sharing class ProductRequestListCtrl {
    @AuraEnabled(cacheable=true)    
    public static ProductRequestData getProductRequests(Id programSpecificationId){
        AuraHandledException auraEx = new AuraHandledException('Error Message');  
        auraEx.setMessage('Error while getting product requests.'); 
        try{
            ProductRequestData allProductRequests = new ProductRequestData();
            List<Product_Request__c> parentProductRequestList = new List<Product_Request__c>();
            Map<Id,List<Product_Request__c>> parentChildProductRequestMap = new Map<Id,List<Product_Request__c>>();
            List<Product_Request__c> productRequestList = new List<Product_Request__c>(
                [
                    SELECT Id, Name, RecordType.Name, Product_Request_Name__c, 
                           Parent_Product_Request__r.Program_Specification__c, 
                           Program_Specification__c, OwnerId, Owner.Name, Parent_Product_Request__c
                    FROM Product_Request__c
                    WHERE Program_Specification__c =: programSpecificationId
                    OR Parent_Product_Request__r.Program_Specification__c =: programSpecificationId
                    ORDER BY CreatedDate asc
                ]
            );
            
            if(!productRequestList.isEmpty()){
                for(Product_Request__c prodReq : productRequestList){
                    //collect parent product requests
                    if(prodReq.Program_Specification__c == programSpecificationId && String.isBlank(prodReq.Parent_Product_Request__c)){
                        if(!parentChildProductRequestMap.containsKey(prodReq.Id)){
                            parentChildProductRequestMap.put(prodReq.Id,new List<Product_Request__c>());
                        }
                        parentProductRequestList.add(prodReq);
                    //add child product requests
                    }else{
                        if(parentChildProductRequestMap.containsKey(prodReq.Parent_Product_Request__c)){
                            parentChildProductRequestMap.get(prodReq.Parent_Product_Request__c).add(prodReq);
                        }
                    }
                }
            }
    
            allProductRequests.parentList = parentProductRequestList;
            allProductRequests.parentChildMap = parentChildProductRequestMap;
            
            return allProductRequests;

        }catch(Exception e){ throw auraEx; }
        
    }
    
    public class ProductRequestData{
        @AuraEnabled
        public List<Product_Request__c> parentList;
        @AuraEnabled
        public Map<Id,List<Product_Request__c>> parentChildMap;
    }
}