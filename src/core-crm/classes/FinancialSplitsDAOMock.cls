/**
 * @description Mock DAO Class for Action Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | mark.j.mahilum                 | June 01, 2023         | DEPP-5687              | Created File                               |
 */
@isTest
public inherited sharing class FinancialSplitsDAOMock extends DmlBaseMock implements IFinancialSplitsDAO {
    public Map<Id, Financial_Split__c> financialSplitMap;
	
    public Schema.SObjectType getSObjectType() {
        return Financial_Split__c.SObjectType;
    }

    public FinancialSplitsDAOMock() {
        super(new Map<Id, Financial_Split__c>(), Schema.Financial_Split__c.SObjectType);
        this.financialSplitMap = (Map<Id, Financial_Split__c>) super.records;
    }

    //create financialSplit DAO mock data
    public List<Financial_Split__c> getFinancialSplitsRecords(String relatedParentField,Id relatedParentId){
        
        List<Financial_Split__c> financialSplitList = new List<Financial_Split__c>();
        
        for (Financial_Split__c record : financialSplitMap.values()) {
            if (record.RecordTypeId == FinancialSplitsDAO.COURSE_FINANCIAL_SPLIT_RECORDTYPEID &&
                (relatedParentField == (record.Course__c))
            ) {
                financialSplitList.add(record);
            }
        }
        
        return financialSplitList;
    }

}