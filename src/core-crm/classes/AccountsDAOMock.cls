/**
 * @description Mock DAO Class for Account Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                     |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------|
 *    | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created File                       |
 *    | mark.j.mahilum                 | June 1, 2023          | DEPP-5687              | Added new account method           |
 *    | ryan.j.a.dela.cruz             | June 5, 2023          | DEPP-5385              | Added getAccountIdByABN method     |
 */
@isTest
public inherited sharing class AccountsDAOMock extends DmlBaseMock implements IAccountsDAO {
    public Map<Id, Account> accountMap;

    public AccountsDAOMock() {
        super(new Map<Id, Account>(), Schema.Account.SObjectType);
        this.accountMap = (Map<Id, Account>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public List<Account> getAccountsBySetIds(Set<Id> accountIds) {
        List<Account> accountList = new List<Account>();

        for (Account record : accountMap.values()) {
            if (accountIds.contains(record.Id)) {
                accountList.add(record);
            }
        }

        return accountList;
    }

    public List<Account> getAccountsBySetIds(Set<Id> accountIds, List<String> fields, AccessLevel accessLevel) {
        List<Account> accountList = new List<Account>();

        for (Account record : accountMap.values()) {
            if (accountIds.contains(record.Id)) {
                accountList.add(record);
            }
        }

        return accountList;
    }

    public List<Account> getPartnerAccountsByIds(Set<Id> recordIds, AccessLevel accessLevel) {
        List<Account> accounts = new List<Account>();
        for(Account account : accountMap.values()) {
            if(recordIds.contains(account.Id) && account.IsPartner == true) {
                accounts.add(account);
            }
        }
        return accounts;
    }

    public List<Account> getAccountsBySetNames(Set<String> accountNames) {
        List<Account> accountList = new List<Account>();

        for (Account record : accountMap.values()) {
            if (accountNames.contains(record.Name)) {
                accountList.add(record);
            }
        }

        return accountList;
    }

    public List<Account> getAccountBySetNamesWithLimit(
        Set<String> accountNames,
        Integer recordsCount
    ) {
        List<Account> accountList = new List<Account>();

        for (Account record : accountMap.values()) {
            if (accountNames.contains(record.Name)) {
                accountList.add(record);
            }
            if (accountList.size() == recordsCount) {
                break;
            }
        }

        return accountList;
    }

    public Account getAccountIdByABN(String abn) {
        for (Account account : accountMap.values()) {
            if (abn.contains(account.ABN__c)) {
                return account;
            }
        }

        return new Account();
    }
}
