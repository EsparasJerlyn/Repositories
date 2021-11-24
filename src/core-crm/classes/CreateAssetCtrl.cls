/**
 * @description Controller class for createAsset LWC
 *
 * @see ../lwc/createAsset
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | adrian.c.habasa           | November 11, 2021     | DEPP-664 | Created file                    | 
      |                           |                       |          |                                 | 
*/

public with sharing class CreateAssetCtrl {
    
    /**
    * @description Method for getting the metadata of given object api name set in Field Layout Setting
    * @param objApiName - API name of object passed from component
    * @return list of Field Layout Setting records
    */
    @AuraEnabled(cacheable=true)
    public static List<Field_Layout_Setting__mdt> getLayoutMapping(String objApiName){
        return [
            SELECT  MasterLabel, Left_Column_Long__c, Right_Column_Long__c, Single_Column_Long__c
            FROM Field_Layout_Setting__mdt
            WHERE Record_Type_Setting__r.Object_Type__c =: objApiName
        ];
    }

    /**
    * @description Method for getting the related Asset Id and Account Id of Product Request
    * @param productRequestId - Id of the Product Request Record
    * @param productSpecificationId - Id of the Related Product Specification Record
    * @return Map of Id
    */
    @AuraEnabled(cacheable=true)
    public static Map<String,Id> getRelatedRecords(Id productRequestId,Id productSpecificationId)
    {
        Map<String,Id> relatedRecords = new Map<String,Id>();
        List<Asset> assetList = new List<Asset>([SELECT Id FROM Asset WHERE Product_Request__c =: productRequestId]);
        List<Product_specification__c> accountList = new List<Product_specification__c>([SELECT Opportunity_Name__r.AccountId from Product_specification__c where Id =: productSpecificationId]);

        if(!assetList.isEmpty())
        {
            relatedRecords.put('assetId', assetList[0].Id);
        }
        if(!accountList.isEmpty())
        {
            relatedRecords.put('accountId', accountList[0].Opportunity_Name__r.AccountId);
        }

        return relatedRecords;

    }
    

}