public with sharing class ListCtrl {
     /**
     * @description get list of list searched 
     * @param filterString - search string for filter
     * @return list of list formatted for customSearch
     **/
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getSearchedLists(String filterString, Id recordId){
        filterString = '%' + filterString + '%';
        List<Map<String,String>> listMap = new List<Map<String,String>>();
        
        String meta = '';
        for(List__c varList: [
            SELECT Id, Name, List_Name__c, Column_1__c, Column_2__c, Column_3__c, Column_4__c, Column_5__c,
            Column_6__c, Column_7__c, Column_8__c, Column_9__c, Column_10__c
            FROM List__c
            WHERE (Name LIKE :filterString OR Name = :filterString)
            AND Id != :recordId
            WITH SECURITY_ENFORCED
        ]){
            listMap.add(new Map<String,String>{
                'id' => varList.Id,
                'label' => varList.Name,
                'meta' => meta
            });
         }
            return listMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<List__c> getSearchedList() {
        return [SELECT Id, Name, List_Name__c, Column_1__c, Column_2__c, Column_3__c, Column_4__c, Column_5__c,
        Column_6__c, Column_7__c, Column_8__c, Column_9__c, Column_10__c 
        FROM List__c
        WITH SECURITY_ENFORCED]; // Adjust the query based on your requirements
    }
}