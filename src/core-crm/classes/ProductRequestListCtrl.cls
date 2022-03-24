/**
 * @description Controller Class for productRequestList LWC
 * @see ../lwc/productRequestList
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | angelika.j.s.galang       | September 30, 2021    | DEPP-40,42           | Created file                 |
      | roy.nino.s.regala         | March 10, 2022        | DEPP-1747            | Updated to suit new datamodel| 
      | eccarius.karl.munoz       | March 23, 2022        | DEPP-1888            | Added update method for      |
      |                           |                       |                      | Not Proceeding               | 
 */
public with sharing class ProductRequestListCtrl {
    private static string PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    
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
            ProductRequestData finalProductRequests = new ProductRequestData();
            List<Product_Request__c> parentProductRequestList = new List<Product_Request__c>();
            Map<Id,List<Product_Request__c>> parentChildProductRequestMap = new Map<Id,List<Product_Request__c>>();
            Set<Id> childProductRequestIds = new Set<Id>();
            Set<Id> courseProdRequestIds = new Set<Id>();

            //get all related product request records where program is related to the product specification
            List<Related_Product_Request__c> relatedProductRequestList = new List<Related_Product_Request__c>(
                [
                    SELECT Id, Program__c, Course__c
                    FROM Related_Product_Request__c
                    WHERE Program__r.Product_Specification__c =: productSpecificationId
                    ORDER BY LastModifiedDate asc
                ]
            );

            for(Related_Product_Request__c relatedPR: relatedProductRequestList){
                courseProdRequestIds.add(relatedPR.Course__c);
            }

            //get all product request related to the product specification and NOT a child of program
            //all non children product request
            Map<Id,Product_Request__c> productRequestMap = new Map<Id,Product_Request__c>(
                [
                    SELECT Id, Name, RecordType.Name, Product_Request_Name__c, Not_Proceeding_Comments__c,
                           Product_Request_Status__c,RecordType.DeveloperName,  
                           Product_Specification__c, OwnerId, Owner.Name, 
                           Product_Specification__r.RecordType.DeveloperName,
                           Product_Specification__r.Stage__c,
                           (SELECT Id, Name, Program_Delivery_Structure__c FROM Program_Plans__r),
                           (SELECT Id, Name FROM Courses__r)
                    FROM Product_Request__c
                    WHERE Product_Specification__c =: productSpecificationId
                    AND ID NOT IN:courseProdRequestIds
                    ORDER BY LastModifiedDate asc
                ]
            );

            //get all course product request related to the program
            //all children
            Map<Id,Product_Request__c> courseProductRequestMap = new Map<Id,Product_Request__c>(
                [
                    SELECT Id, Name, RecordType.Name, Product_Request_Name__c, Not_Proceeding_Comments__c,
                           Product_Request_Status__c,RecordType.DeveloperName,   
                           Product_Specification__c, OwnerId, Owner.Name, 
                           Product_Specification__r.RecordType.DeveloperName,
                           Product_Specification__r.Stage__c,
                           (SELECT Id, Name, Program_Delivery_Structure__c FROM Program_Plans__r),
                           (SELECT Id, Name FROM Courses__r)
                    FROM Product_Request__c
                    WHERE ID IN: courseProdRequestIds 
                    ORDER BY LastModifiedDate asc
                ]
            );

            for(Related_Product_Request__c relatedPR: relatedProductRequestList){
                //create a map where key is the parent program and the values are the child courses
                if(!parentChildProductRequestMap.containsKey(relatedPR.Program__c)){
                    parentChildProductRequestMap.put(relatedPR.Program__c,new List<Product_Request__c>()); 
                }
                parentChildProductRequestMap.get(relatedPR.Program__c).add(courseProductRequestMap.get(relatedPR.Course__c));
            }

            //make a list of parent product requests
            if(!productRequestMap.isEmpty()){
                parentProductRequestList.addAll(productRequestMap.values());
            }

            finalProductRequests.parentList = parentProductRequestList;
            finalProductRequests.parentChildMap = parentChildProductRequestMap;
            
            return finalProductRequests;

        }catch(Exception e){ throw auraEx; }
        
    }
    
    /**
     * @description Updates Registration details of students
    * @param id - id of product request selected
    * @param recordType - record type of product request selected
    * @param notProceedingComments - not proceeding comments inputted from modal
    * @param ifFlexibleProgram - determines flexible program
    * @return String
    */
    @AuraEnabled
    public static String updateProdReqToNotProceeding(String id, String recordType, String notProceedingComment, Boolean ifFlexibleProgram){
        String response='';
        List<Product_Request__c> productRequestsToUpdate = new List<Product_Request__c>();    
        Product_Request__c productRequest = new Product_Request__c();
        productRequest.id = id;
        productRequest.Not_Proceeding_Comments__c = notProceedingComment;
        productRequest.Product_Request_Status__c = 'Not Proceeding';
        productRequestsToUpdate.add(productRequest);

        if(recordType == PR_PROGRAM && !ifFlexibleProgram){
            List<Related_Product_Request__c> relatedProducts = [SELECT Id, Course__c FROM Related_Product_Request__c where Program__c =: id];            
            for(Related_Product_Request__c relatedProduct : relatedProducts){
                Product_Request__c prodReq = new Product_Request__c();
                prodReq.Id = relatedProduct.Course__c;
                prodReq.Product_Request_Status__c = 'Not Proceeding';
                productRequestsToUpdate.add(prodReq);
            }
        }

        try{
            update productRequestsToUpdate;
            response = 'Success';
        }catch(Exception e){
            response = 'The following exception has occurred: ' + e.getMessage();
        }

        return response;
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