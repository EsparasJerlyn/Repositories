/**
 * @description DAO Class for Account Object. Contains soql and constants related to the Account object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | roy.nino.s.regala              | April 24, 2023        | DEPP-5567              | Created File                               |
 *    | mark.j.mahilum                 | June 1, 2023          | DEPP-5687              | Added getAccountBySetNamesWithLimit method |
 *    | ryan.j.a.dela.cruz             | June 5, 2023          | DEPP-5385              | Added getAccountIdByABN method             |
 */
public inherited sharing class AccountsDAO extends DmlBase implements IAccountsDAO {
    public static final String ACCT_BUSINESS_ORG = System.label.RT_Account_Business_Org;
    public static final Id ACCT_BUSINESS_ORG_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(ACCT_BUSINESS_ORG)
        .getRecordTypeId();
    public static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    public static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(ACCT_UNIV_DEP)
        .getRecordTypeId();

    public static IAccountsDAO newInstance() {
        return (IAccountsDAO) ImplementationSelector.DAO.newInstance(Account.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public List<Account> getAccountsBySetIds(Set<Id> accountIds) {
        return [
            SELECT Id, Name
            FROM Account
            WHERE Id IN :accountIds
            WITH USER_MODE
        ];
    }

    public List<Account> getAccountsBySetNames(Set<String> accountNames) {
        return [
            SELECT Id, Name
            FROM Account
            WHERE Name IN :accountNames
            WITH USER_MODE
        ];
    }

    public List<Account> getAccountBySetNamesWithLimit(
        Set<String> accountNames,
        Integer recordsCount
    ) {
        return [
            SELECT Id, Name
            FROM Account
            WHERE Name IN :accountNames
            WITH USER_MODE
            LIMIT :recordsCount
        ];
    }

    public Account getAccountIdByABN(String abn) {
        return [
            SELECT Id
            FROM Account
            WHERE ABN__c = :abn AND RecordTypeId = :ACCT_BUSINESS_ORG_ID
            WITH USER_MODE
            LIMIT 1
        ];
    }
}
