/**
 * @description Controller class for Financial Split LWC
 *
 * @see ../lwc/financialSplit
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | angelika.j.s.galang            | February 3, 2021      | DEPP-1257              | Created File                 |
      | mark.j.mahilum                 | June 01,2023          | DEPP-5687              | Methods converted to DAO     |              
 */
public with sharing class FinancialSplitCtrl {

    /**
    * @description Method for getting the Id QUTeX Account
    * @param qutex - string literal 'QUTeX'
    * @return Id of QUTeX Account
    */
    @AuraEnabled(cacheable=true)
    public static Id getQutexId(String qutex){ 
        
        return AccountsDAO.newInstance()
            .getAccountBySetNamesWithLimit(new Set<String>{ (String) qutex },1)
            .iterator()
            .next()
            ?.Id;
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
    public static Id getParentId(CustomLayoutCtrl.GetRecordFilter filter){  
        filter.fields = 'Id ';
        return CustomLayoutCtrl.getParentRecord(filter)?.Id;
    }

    /**
    * @description Method for getting list of Financial Split related to either Course/Program Plan
    * @param relatedParentField - parent field api name either Course/Program Plan
    * @param relatedParentId - id of either Course/Program Plan
    * @return list of Financial Splits
    */
    @AuraEnabled(cacheable=true)
    public static List<Financial_Split__c> getFinancialSplits(String relatedParentField,Id relatedParentId){
        
        List<SObject> records = FinancialSplitsDAO.newInstance().getFinancialSplitsRecords(relatedParentField,relatedParentId);
        return (List<Financial_Split__c>) records;
    }

    /**
    * @description Upserts financial split records
    * @param financialSplits - list of financial splits
    */
    @AuraEnabled
    public static void upsertFinancialSplits(List<Financial_Split__c> financialSplits){  
        
        if(!financialSplits.isEmpty()){          
            for(Financial_Split__c record : financialSplits){
                record.RecordTypeId = FinancialSplitsDAO.COURSE_FINANCIAL_SPLIT_RECORDTYPEID;
            }
            FinancialSplitsDAO.newInstance().upsertRecords(financialSplits,false,AccessLevel.USER_MODE);
        }
    }
}