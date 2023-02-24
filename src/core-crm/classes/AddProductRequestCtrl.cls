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
      | john.m.tambasen           | July 07, 2022         | DEPP-2590            | Added search method with Program     |
      | john.m.tambasen           | July 28, 2022         | DEPP-3480            | for creation of needed records       |
      | alexander.cadalin         | August 04, 2022       | DEPP-2498            | appened to above for SOA             |
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
    public static List<Product_Request__c> getSearchedProductRequests(String filterString, List<Product_Request__c> filterPRList, String prodSpecRecordType, Boolean isSOA){
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

        //add the programs only if searching for SOA
        if(isSOA){
            for(Product2 product: [ SELECT Id, Name, IsActive, Program_Plan__r.Product_Request__c, Program_Plan__r.Product_Request__r.Id, Program_Plan__r.Product_Request__r.Product_Specification__r.RecordType.DeveloperName
                                    FROM Product2 
                                    WHERE (Name LIKE :filterString 
                                    OR Name =:filterString)
                                    AND Program_Plan__r.Product_Request__r.Id NOT IN: filterPRList
                                    AND Program_Plan__r.Product_Request__r.Product_Specification__r.RecordType.DeveloperName =: prodSpecRecordType
                                    AND IsActive = true 
                                    ]){

                productRequestIds.add(product.Program_Plan__r.Product_Request__c);
            }
        }
        
        List<Product_Request__c> productRequestResults = new List<Product_Request__c>([SELECT ID,Name,
                                                                                        (SELECT Id, Name FROM Courses__r), 
                                                                                        (SELECT Id, Name FROM Program_Plans__r),
                                                                                        RecordType.Name 
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

    /**
     * 
     *  @description upsert hed__address__c record
     * @param accountId - Primary account Id
     * @param accountName - Primary account name
     */
    @AuraEnabled
    public static void createBuyerGroupAndEntitlement(
        Id productRequestId,
        String accountId, 
        String accountName,
        Boolean isCorporateBundle,
        Boolean isSoa
    ){
        BuyerGroup bg = new BuyerGroup();

        if(isCorporateBundle) {
            //create BuyerGroup
            BuyerGroup bgInsert = new BuyerGroup();
            String accName = accountName;

            if(accName.length() > 80) {
                accName = accName.substring(0, 80);
            }

            bgInsert.Name = accName + ' ' + String.valueofGmt(System.now());
            bgInsert.Product_Request__c = productRequestId;
            insert bgInsert;
            bg = bgInsert;
        } else if(isSoa) {
            BuyerGroup bgQuery = [SELECT Id FROM BuyerGroup WHERE Product_Request__c = :productRequestId];
            bg = bgQuery;
        }

        List<BuyerGroupMember> currentBgMemberList =[SELECT 
                                                        Id, Name, BuyerGroupId, BuyerId
                                                    FROM 
                                                        BuyerGroupMember 
                                                    WHERE BuyerId =: accountId
                                                        AND BuyerGroupId = :bg.Id];
        //if BuyerGroupMember doesnt exist
        if(currentBgMemberList.size() == 0){
            //insert BuyerGroupMember
            BuyerGroupMember bgMemberInsert = new BuyerGroupMember();
            bgMemberInsert.BuyerGroupId = bg.Id;
            bgMemberInsert.BuyerId = accountId;
            insert bgMemberInsert;
        }

        //get the CCE store
        WebStore webStoreCCE = [SELECT Id From WebStore WHERE Name = 'CCE' LIMIT 1];

        //insert WebStoreBuyerGroup
        WebStoreBuyerGroup webStoreBgInsert = new WebStoreBuyerGroup();
        webStoreBgInsert.BuyerGroupId = bg.Id;
        webStoreBgInsert.WebStoreId = webStoreCCE.Id;
        insert webStoreBgInsert;

        //insert CommerceEntitlementPolicy
        CommerceEntitlementPolicy commerceEntitlementInsert = new CommerceEntitlementPolicy();
        commerceEntitlementInsert.CanViewPrice = true;
        commerceEntitlementInsert.CanViewProduct = true;
        commerceEntitlementInsert.IsActive = true;
        commerceEntitlementInsert.Name = accountName + ' ' + String.valueofGmt(System.now());
        insert commerceEntitlementInsert;

        //insert CommerceEntitlementBuyerGroup
        CommerceEntitlementBuyerGroup commerceEntitlementBgInsert = new CommerceEntitlementBuyerGroup();
        commerceEntitlementBgInsert.BuyerGroupId = bg.Id;
        commerceEntitlementBgInsert.PolicyId = commerceEntitlementInsert.Id;
        insert commerceEntitlementBgInsert;
    }
}