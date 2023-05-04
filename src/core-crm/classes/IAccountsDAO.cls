/**
 * @description Interface for Account DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public interface IAccountsDAO extends DmlInterface {
    List<Account> getAccountsBySetIds(Set<Id> accountIds);
    List<Account> getAccountsBySetNames(Set<String> accountNames);
}
