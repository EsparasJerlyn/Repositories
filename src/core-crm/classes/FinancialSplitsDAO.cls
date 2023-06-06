/**
 * @description DAO Class for Financial Split Object. Contains soql and constants related to the Account object.
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | mark.j.mahilum                 | June 01, 2023         | DEPP-5687              | Created File                               |
 */
public inherited sharing class FinancialSplitsDAO extends DmlBase implements IFinancialSplitsDAO {
    
    public static final String FINANCIAL_SPLIT_API_NAME = Financial_Split__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
    public static final String FINANCIAL_SPLIT_FIELDS = 
        'Id,Account_Code__c,Account_GL_Code__c,Account_Name__c,CreatedDate,RecordTypeId,' +
        'IsActive__c,Participating_School_Name__c,Participating_School_Name__r.Name,' +
        'Percentage_split__c';
    public static final String RECORDTYPE_DEVELOPERNAME = 'Course Financial Split';
    public static final String COURSE_FINANCIAL_SPLIT_RECORDTYPEID = Schema.SObjectType.Financial_Split__c.getRecordTypeInfosByName().get(RECORDTYPE_DEVELOPERNAME).getRecordTypeId();
    public static final String RECORDTYPEID = 'RecordTypeId';
    
    public static IFinancialSplitsDAO newInstance()
    {
        return (IFinancialSplitsDAO) ImplementationSelector.DAO.newInstance(Financial_Split__c.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return Financial_Split__c.SObjectType; 
    }

    public List<Financial_Split__c> getFinancialSplitsRecords(String relatedParentField,Id relatedParentId){
        return Database.query(
            'SELECT ' + String.escapeSingleQuotes(FINANCIAL_SPLIT_FIELDS) + 
            ' FROM ' + String.escapeSingleQuotes(FINANCIAL_SPLIT_API_NAME) + 
            ' WHERE ' + String.escapeSingleQuotes(relatedParentField) + 
            ' = \'' + String.escapeSingleQuotes(relatedParentId) + 
            '\' AND ' + String.escapeSingleQuotes(RECORDTYPEID) + 
            ' = \'' + String.escapeSingleQuotes(COURSE_FINANCIAL_SPLIT_RECORDTYPEID) + 
            '\' ORDER BY CreatedDate ASC'
        );
    }
}