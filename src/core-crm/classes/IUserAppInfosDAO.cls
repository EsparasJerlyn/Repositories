/**
 * @description Interface for UseAppInfo DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 13, 2023         | DEPP-5391              | Created file
 */
public interface IUserAppInfosDAO extends DmlInterface {
     List<UserAppInfo> getUserAppInfoRecordByUserIds(Set<String> userIdSet);
}
