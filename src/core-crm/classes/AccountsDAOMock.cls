/**
 * @description Mock DAO Class for Account Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created File                 | 
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

    public List<Account> getAccountsBySetNames(Set<String> accountNames) {
        List<Account> accountList = new List<Account>();

        for (Account record : accountMap.values()) {
            if (accountNames.contains(record.Name)) {
                accountList.add(record);
            }
        }

        return accountList;
    }
}
