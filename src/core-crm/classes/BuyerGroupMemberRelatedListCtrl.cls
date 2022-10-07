/**
 * @description Controller Class for buyerGroupMemberRelatedList LWC
 * @see ../lwc/buyerGroupMemberRelatedList
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | alexander.cadalin         | August 02, 2022       | DEPP-2498            | Created file                 |
      | kathy.cornejo             | September 09, 2022    | DEPP-4151            | Updated filter for searched  | 
      |                           |                       |                      |   accounts                   |

 */

public with sharing class BuyerGroupMemberRelatedListCtrl {
    /**
     * @description Retrieves a list of Buyer Group Memebers related to the product request
     * @param recordId - Record Id of the current record in view
     * @return List of Buyer Group Member records
     **/
    @AuraEnabled
    public static List<BuyerGroupMember> getRelatedBuyerGroupMembersList(Id recordId) {
        return [SELECT Id, Buyer.Name FROM BuyerGroupMember WHERE BuyerGroup.Product_Request__c = :recordId];
    }

    /**
     * @description get list of users searched 
     * @param filterString - search string for filter
     * @return list of users formatted for customSearch
     **/
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getSearchedAccounts(String filterString, Id recordId){
        filterString = '%' + filterString + '%';
        List<Map<String,String>> userMap = new List<Map<String,String>>();
        
        for(Account acc : [
            SELECT Id, Name, IsPartner, RecordType.Name
            FROM Account
            WHERE (Name LIKE :filterString OR Name = :filterString) 
            AND Id NOT IN (SELECT BuyerId FROM BuyerGroupMember WHERE BuyerGroup.Product_Request__c = :recordId)
            AND IsPartner = true
        ]){
            userMap.add(new Map<String,String>{
                'id' => acc.Id,
                'label' => acc.Name,
                'meta' => acc.RecordType.Name
            });
        }
        return userMap;
    }
    
    /**
     * @description create a buyer group member record
     * @param buyerId - business organization account id
     * @param buyerGroupId - buyer group id
     **/
    @AuraEnabled
    public static Boolean createBuyerGroupMember(Id buyerId, Id buyerGroupId) {
        try{
            BuyerGroupMember bgm = new BuyerGroupMember();
            bgm.BuyerId = buyerId;
            bgm.BuyerGroupId = buyerGroupId;
            insert bgm;
            return true;
        } catch(Exception e) {
            return false;
        }
    }

    /**
     * @description retrieve the buyer group record of the product request
     * @param recordId - recordId of the product request
     * @return buyergroup recordId
     */
    @AuraEnabled
    public static Id getBuyerGroupRecord(Id recordId){
        List<BuyerGroup> bgList = [SELECT Id FROM BuyerGroup WHERE Product_Request__c = :recordId LIMIT 1];
        return bgList[0].Id;
    }
}