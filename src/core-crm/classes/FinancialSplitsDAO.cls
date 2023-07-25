/**
 * @description DAO Class for Financial Split Object. Contains soql and constants related to the Account object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                             |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------------------|
 *    | mark.j.mahilum                 | June 01, 2023         | DEPP-5687              | Created File                                               |
 *    | kenneth.f.alsay                | June 14, 2023         | DEPP-5434              | Added all other record types                               |
 *    | ryan.j.a.dela.cruz             | July 18, 2023         | DEPP-5457/DEPP-5468    | Added getActiveOpportunityFinancialSplitsRecords method    |
 */
public inherited sharing class FinancialSplitsDAO extends DmlBase implements IFinancialSplitsDAO {
    public static final String FINANCIAL_SPLIT_API_NAME = Financial_Split__c.SObjectType.getDescribe(
            SObjectDescribeOptions.DEFERRED
        )
        .getLocalName();
    public static final String FINANCIAL_SPLIT_FIELDS =
        'Id,Account_Code__c,Account_GL_Code__c,Account_Name__c,CreatedDate,RecordTypeId,' +
        'IsActive__c,Participating_School_Name__c,Participating_School_Name__r.Name,' +
        'Percentage_split__c';
    public static final String RECORDTYPE_DEVELOPERNAME = 'Course Financial Split';
    public static final String COURSE_FINANCIAL_SPLIT_RECORDTYPEID = Schema.SObjectType.Financial_Split__c.getRecordTypeInfosByName()
        .get(RECORDTYPE_DEVELOPERNAME)
        .getRecordTypeId();
    public static final String OPPORTUNITY_FUNDING_BODY_RECORDTYPEID = Schema.SObjectType.Financial_Split__c.getRecordTypeInfosByDeveloperName()
        .get('Opportunity_Funding_Body')
        .getRecordTypeId();
    public static final String OPPORTUNITY_OUTCOME_FUNDING_BODY_RECORDTYPEID = Schema.SObjectType.Financial_Split__c.getRecordTypeInfosByDeveloperName()
        .get('Opportunity_Outcome_Funding_Body')
        .getRecordTypeId();
    public static final String OPPORTUNITY_OUTCOME_CONTACT_REVENUE_FINANCIAL_SPLIT_RECORDTYPEID = Schema.SObjectType.Financial_Split__c.getRecordTypeInfosByDeveloperName()
        .get('Opportunity_Outcome_Contact_Revenue_Financial_Split')
        .getRecordTypeId();
    public static final String OPPORTUNITY_OUTCOME_ACCOUNT_REVENUE_FINANCIAL_SPLIT_RECORDTYPEID = Schema.SObjectType.Financial_Split__c.getRecordTypeInfosByDeveloperName()
        .get('Opportunity_Outcome_Account_Revenue_Financial_Split')
        .getRecordTypeId();
    public static final String RECORDTYPEID = 'RecordTypeId';

    public static IFinancialSplitsDAO newInstance() {
        return (IFinancialSplitsDAO) ImplementationSelector.DAO.newInstance(
            Financial_Split__c.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return Financial_Split__c.SObjectType;
    }

    public List<Financial_Split__c> getFinancialSplitsRecords(
        String relatedParentField,
        Id relatedParentId
    ) {
        return Database.query(
            'SELECT ' +
                String.escapeSingleQuotes(FINANCIAL_SPLIT_FIELDS) +
                ' FROM ' +
                String.escapeSingleQuotes(FINANCIAL_SPLIT_API_NAME) +
                ' WHERE ' +
                String.escapeSingleQuotes(relatedParentField) +
                ' = \'' +
                String.escapeSingleQuotes(relatedParentId) +
                '\' AND ' +
                String.escapeSingleQuotes(RECORDTYPEID) +
                ' = \'' +
                String.escapeSingleQuotes(COURSE_FINANCIAL_SPLIT_RECORDTYPEID) +
                '\' ORDER BY CreatedDate ASC'
        );
    }

    public List<Financial_Split__c> getActiveOpportunityFinancialSplitsRecords(
        Set<Id> opportunityIds
    ) {
        return [ // NO PMD
            SELECT Id, Opportunity__c, Funding_Body__c, Participating_School_Name__c, Percentage_split__c, Revenue_Split_Account__c, Revenue_Split_Contact__c, Funding_Body_Contribution_Amount__c
            FROM Financial_Split__c
            WHERE Opportunity__c IN :opportunityIds AND isActive__c = true
            WITH USER_MODE
        ];
    }
}