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
    /**
     * @description do callout to loqate
     * @param productSpecificationId - id of productSpecification
     * @return parent and child product requests
     */
    @AuraEnabled(cacheable=true)    
    public static ProductRequestData getProductRequests(Id productSpecificationId){
        AuraHandledException auraEx = new AuraHandledException('Error Message');  
        auraEx.setMessage('Error while getting product requests.');
        try{
            ProductRequestData allProductRequests = new ProductRequestData();
            List<Product_Request__c> parentProductRequestList = new List<Product_Request__c>();
            Map<Id,List<Product_Request__c>> parentChildProductRequestMap = new Map<Id,List<Product_Request__c>>();
            List<Product_Request__c> productRequestList = new List<Product_Request__c>(
                [
                    SELECT Id, Name, RecordType.Name, Product_Request_Name__c, 
                           Parent_Product_Request__r.Product_Specification__c, 
                           Product_Specification__c, OwnerId, Owner.Name, 
                           Parent_Product_Request__c, Product_Specification__r.RecordType.DeveloperName,
                           RecordType.DeveloperName
                    FROM Product_Request__c
                    WHERE Product_Specification__c =: productSpecificationId
                    OR Parent_Product_Request__r.Product_Specification__c =: productSpecificationId
                    ORDER BY CreatedDate asc
                ]
            );
            
            if(!productRequestList.isEmpty()){
                for(Product_Request__c prodReq : productRequestList){
                    //collect parent product requests
                    if(prodReq.Product_Specification__c == productSpecificationId && String.isBlank(prodReq.Parent_Product_Request__c) && !parentChildProductRequestMap.containsKey(prodReq.Id)){
                        parentChildProductRequestMap.put(prodReq.Id,new List<Product_Request__c>());
                        parentProductRequestList.add(prodReq);
                    //add child product requests
                    }else if(parentChildProductRequestMap.containsKey(prodReq.Parent_Product_Request__c)){
                        parentChildProductRequestMap.get(prodReq.Parent_Product_Request__c).add(prodReq);
                    }
                }
            }
    
            allProductRequests.parentList = parentProductRequestList;
            allProductRequests.parentChildMap = parentChildProductRequestMap;
            
            return allProductRequests;

        }catch(Exception e){ throw auraEx; }
        
    }
    
    /**
     * @description wrapper that contains the list parent and map of child product requests
     */
    public class ProductRequestData{
        @AuraEnabled
        public List<Product_Request__c> parentList;
        @AuraEnabled
        public Map<Id,List<Product_Request__c>> parentChildMap;
    }
}