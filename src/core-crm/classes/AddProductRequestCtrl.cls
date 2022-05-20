/**
 * @description Controller Class for addProductRequest LWC
 * @see ../lwc/addProductRequest
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                       |
      |---------------------------|-----------------------|----------------------|--------------------------------------|
      | roy.nino.s.regala         | September 28, 2021    | DEPP-40,42           | Created file                         | 
      | angelika.j.s.galang       | December 17, 2021     | DEPP-1088,1096       | Modified to handle OPE records       | 
      | adrian.c.habasa           | January  20, 2022     | DEPP-1471            | Added method to get QUTeX Account Id | 
      | roy.nino.s.regala         | March 10, 2022        | DEPP-1747            | Added search method                  |

 */
public with sharing class AddProductRequestCtrl {

    /**
     * @description get list of users searched 
     * @param filterString - search string for filter
     * @return list of users formatted for customSearch
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getSearchedUsers(String filterString){
        filterString = '%' + filterString + '%';
        List<Map<String,String>> userMap = new List<Map<String,String>>();
        
        for(User usr : [
            SELECT Id, Name, Division
            FROM User
            WHERE (
                Name LIKE :filterString OR
                Name = :filterString
            )
        ]){
            userMap.add(new Map<String,String>{
                'id' => usr.Id,
                'label' => usr.Name,
                'meta' => usr.Division
            });
        }
        return userMap;
    }   

    /**
     * @description get record type settings and field layout settings 
     * @param filterString - search string for filter
     * @param filterPRList - all current children of program
     * @param prodSpecRecordType - recordtype of program
     * @return list product request
     */
    @AuraEnabled(cacheable=true)
    public static List<Product_Request__c> getSearchedCourseProductRequests(String filterString, List<Product_Request__c> filterPRList, String prodSpecRecordType){
        filterString = '%' + filterString + '%';
        
        List<Id> productRequestIds = new List<Id>();

        for(Product2 product: [ SELECT Id, Course__c, Course__r.ProductRequestID__c, IsActive
                                FROM Product2 
                                WHERE (Course__r.Name LIKE :filterString 
                                OR Course__r.Name =:filterString)
                                AND Course__r.ProductRequestID__c NOT IN: filterPRList
                                AND Course__r.ProductRequestID__r.Product_Specification__r.RecordType.DeveloperName =: prodSpecRecordType
                                AND Course__r.ProductRequestID__r.OPE_Program_Plan_Type__c != 'Prescribed Program'
                                AND IsActive = true
                                ]){

            productRequestIds.add(product.Course__r.ProductRequestID__c);
        }
        
        List<Product_Request__c> productRequestResults = new List<Product_Request__c>([SELECT ID,Name,
                                                                                        (SELECT Id, Name FROM Courses__r), RecordType.Name 
                                                                                        FROM Product_Request__c 
                                                                                        WHERE ID IN: productRequestIds]);
        return productRequestResults;
    }

    /**
     * @description get record type settings and field layout settings 
     * @param objectType - object api name of the current record the lwc is at
     * @param filter - id of record types to query
     * @return list of record type mapping
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getRecordTypes(String objectType){
        List<Map<String,String>> recordTypeMap = new List<Map<String,String>>();
        
        for(RecordType rec : [
            SELECT Id, Name, Description
            FROM RecordType
            WHERE SobjectType =: objectType
        ]){
            recordTypeMap.add(new Map<String,String>{
                'label' => rec.Name,
                'description' => rec.Description,
                'value' => rec.Id
            });
        }
        return recordTypeMap;
    }   

     /**
     * @description gets id of QUTeX Account
     */
    @AuraEnabled(cacheable=true)
    public static String getAccountId(){
      Account acct = [Select Id from Account WHERE Name ='QUTeX Products' LIMIT 1];
      return acct.Id;
   }
}