/**
 * @description DAO Class for UserAppInfosDAO Object. Contains soql and constants related to the UserAppInfo
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 13, 2023         | DEPP-5391              | Created file
 */
public inherited sharing class UserAppInfosDAO extends DmlBase implements IUserAppInfosDAO {
    public Schema.SObjectType getSObjectType() {
        return UserAppInfo.SObjectType;
    }

    public static IUserAppInfosDAO newInstance() {
        return (IUserAppInfosDAO) ImplementationSelector.DAO.newInstance(UserAppInfo.SObjectType);
    }

    public List<UserAppInfo> getUserAppInfoRecordByUserIds(Set<String> userIdSet) {
        return [
            SELECT Id, AppDefinitionId, UserId
            FROM UserAppInfo
            WHERE UserId IN :userIdSet
            WITH USER_MODE
        ];
    }
}
