/**
 * @description Controller class for Related Child Products LWC
 *
 * @see ../lwc/relatedChildProducts
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary          |
      |---------------------------|-----------------------|--------------|-------------------------|
      | angelika.j.s.galang       | May 5, 2022           | DEPP-2342    | Created file            | 
      |                           |                       |              |                         |
*/
public with sharing class RelatedChildProductsCtrl {
    /**
     * @description queries all related child product requests of prescribed program
     * @param productRequestId - id of product request
     * @return list of related product reuqests
     */
    @AuraEnabled(cacheable=true)    
    public static List<Related_Product_Request__c> getRelatedChildProducts(Id productRequestId){
        return
            [
                SELECT Id, Product_Name__c, Course__c, Course__r.RecordType.Name, Course__r.Product_Request_Status__c
                FROM Related_Product_Request__c 
                WHERE Program__c =: productRequestId
            ];
    }
}
