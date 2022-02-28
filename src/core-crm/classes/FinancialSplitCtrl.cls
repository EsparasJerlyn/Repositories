/**
 * @description Controller class for Financial Split LWC
 *
 * @see ../lwc/financialSplit
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | angelika.j.s.galang       | February 3, 2021      | DEPP-1257| Created file                    | 
      |                           |                       |          |                                 | 
*/
public with sharing class FinancialSplitCtrl {
    
    private static final String FINANCIAL_SPLIT_API_NAME = Financial_Split__c.SObjectType.getDescribe().getLocalName();
    private static final String FINANCIAL_SPLIT_FIELDS = 
        'Id,Account_Code__c,Account_GL_Code__c,Account_Name__c,CreatedDate,' +
        'IsActive__c,Participating_School_Name__c,Participating_School_Name__r.Name,' +
        'Percentage_split__c';

    /**
    * @description Method for getting the Id QUTeX Account
    * @param qutex - string literal 'QUTeX'
    * @return Id of QUTeX Account
    */
    @AuraEnabled(cacheable=true)
    public static Id getQutexId(String qutex){
        return [SELECT Id FROM Account WHERE Name =: qutex]?.Id;
    }

    /**
    * @description Method for getting the Id of related child of parent record
    * @param parentId - Id of Parent
    * @param parentField - parent field api name
    * @param childObjectType - object api name of child
    * @param grandChildInfo - map containing info of grandchild
    * @return Id of Child
    */
    @AuraEnabled(cacheable=true)
    public static Id getParentId(
        String parentId,
        String parentField, 
        String childObjectType, 
        Map<String,String> grandChildInfo
    ){  
        return CustomLayoutCtrl.getChildRecordId(
            parentId,
            parentField,
            childObjectType,
            grandChildInfo
        );
    }

    /**
    * @description Method for getting list of Financial Split related to either Course/Program Plan
    * @param relatedParentField - parent field api name either Course/Program Plan
    * @param relatedParentId - id of either Course/Program Plan
    * @return list of Financial Splits
    */
    @AuraEnabled(cacheable=true)
    public static List<Financial_Split__c> getFinancialSplits(String relatedParentField,Id relatedParentId){
        String queryStr = 
            'SELECT ' + FINANCIAL_SPLIT_FIELDS + 
            ' FROM ' + FINANCIAL_SPLIT_API_NAME + 
            ' WHERE ' + relatedParentField + ' = \'' + String.escapeSingleQuotes(relatedParentId) + 
            '\' ORDER BY CreatedDate ASC';
        List<SObject> records = Database.query(queryStr);
        return (List<Financial_Split__c>) records;
    }

    /**
    * @description Upserts financial split records
    * @param financialSplits - list of financial splits
    */
    @AuraEnabled
    public static void upsertFinancialSplits(List<Financial_Split__c> financialSplits){  
        if(!financialSplits.isEmpty()){
            upsert financialSplits;
        }
    }
}
