/**
 * @description Controller Class for productmanagement LWC
 * @see ../lwc/productmanagement
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                       |
      |---------------------------|-----------------------|----------------------|------------------------------------------------------|
      | roy.nino.s.regala         | March 10, 2022        | DEPP-1747            | Created file                                         |
      | roy.nino.s.regala         | May 23, 2022          | DEPP-2663            | Added checking of Availabl on Cart field of Product  |
 */
public with sharing class ProductManagementCtrl {
    /**
     * @description do callout to loqate
     * @param productRequestId - id of product request
     * @return boolean that tells  whether a parent is prescribed or not
     */
    @AuraEnabled(cacheable=true)    
    public static boolean checkParentProgramType(Id productRequestId){
        if(
            [
            SELECT Id, Program__r.OPE_Program_Plan_Type__c 
            FROM Related_Product_Request__c 
            WHERE Course__c =: productRequestId 
            AND Program__r.OPE_Program_Plan_Type__c = 'Prescribed Program'
            LIMIT 1
            ].isEmpty()
        ){
            return true;
        } else{
            return false;
        }
    }


    /**
     * @description do callout to loqate
     * @param productRequestId - id of product request
     * @return boolean that tells  whether a parent is prescribed or not
     */
    @AuraEnabled(cacheable=true)
    public static boolean checkAvailableOnCart(Id productRequestId){
        if(
            ![
            SELECT Id
            FROM Product2
            WHERE Available_on_Cart__c = true
            AND (Course__r.ProductRequestID__c =: productRequestId
            OR Program_Plan__r.Product_Request__c =: productRequestId)
            LIMIT 1
            ].isEmpty()
        ){
            return true;
        } else{
            return false;
        }
    }
}