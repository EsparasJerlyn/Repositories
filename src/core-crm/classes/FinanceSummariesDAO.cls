/**
 * @description DAO Class for Finance Summary Object. Contains soql and constants related to the Finance Summary object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | July 12, 2023         | DEPP-5473              | Created file
 */
public inherited sharing class FinanceSummariesDAO extends DmlBase implements IFinanceSummariesDAO {
    public static final Id DIVIDEND_SUMMARY_RECTYPE_ID = Schema.SObjectType.Finance_Summary__c.getRecordTypeInfosByDeveloperName()
        .get('Dividend_Summary')
        .getRecordTypeId();
    public static final Id QUT_FINANCE_SYSTEM_RECTYPE_ID = Schema.SObjectType.Finance_Summary__c.getRecordTypeInfosByDeveloperName()
        .get('QUT_Finance_System')
        .getRecordTypeId();
    public static final Id VALUATION_RECTYPE_ID = Schema.SObjectType.Finance_Summary__c.getRecordTypeInfosByDeveloperName()
        .get('Valuation')
        .getRecordTypeId();

    public Schema.SObjectType getSObjectType() {
        return Finance_Summary__c.SObjectType;
    }

    public static IFinanceSummariesDAO newInstance() {
        return (IFinanceSummariesDAO) ImplementationSelector.DAO.newInstance(
            Finance_Summary__c.SObjectType
        );
    }
}
