/**
 * @description Interface for Account DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                 |
 *    | mark.j.mahilum                 | June 1, 2023          | DEPP-5687              | Added new list method        |
 *    | ryan.j.a.dela.cruz             | June 5, 2023          | DEPP-5385              | Added getAccountIdByABN      |
 */
public interface IAccountsDAO extends DmlInterface {
    List<Account> getAccountsBySetIds(Set<Id> accountIds);
    List<Account> getPartnerAccountsByIds(Set<Id> recordIds, AccessLevel accessLevel);
    List<Account> getAccountsBySetIds(Set<Id> accountIds, List<String> fields, AccessLevel accessLevel);
    List<Account> getAccountsBySetNames(Set<String> accountNames);
    List<Account> getAccountBySetNamesWithLimit(Set<String> accountNames, Integer recordsCount);
    Account getAccountIdByABN(String abn);
}
