/**
 * @description Mock DAO Class for UserAppInfo Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
public inherited sharing class UserAppInfosDAOMock extends DmlBaseMock implements IUserAppInfosDAO {
    public Map<Id, UserAppInfo> userAppInfosMap;

    public Schema.SObjectType getSObjectType() {
        return UserAppInfo.SObjectType;
    }

    public UserAppInfosDAOMock() {
        super(new Map<Id, UserAppInfo>(), Schema.UserAppInfo.SObjectType);
        this.userAppInfosMap = (Map<Id, UserAppInfo>) super.records;
    }

    public List<UserAppInfo> getUserAppInfoRecordByUserIds(Set<String> userIdSet) {
        List<UserAppInfo> userAppInfoList = new List<UserAppInfo>();
        for (UserAppInfo userAppI : userAppInfosMap.values()) {
            if (userIdSet.contains(userAppI.UserId)) {
                userAppInfoList.add(userAppI);
            }
        }
        return userAppInfoList;
    }
}
