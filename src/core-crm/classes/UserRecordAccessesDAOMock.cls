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
public inherited sharing class UserRecordAccessesDAOMock extends DmlBaseMock implements IUserRecordAccessesDAO {
    public Map<Id, UserRecordAccess> userRecordAccessMap;

    public Schema.SObjectType getSObjectType() {
        return UserRecordAccess.SObjectType;
    }

    public UserRecordAccessesDAOMock() {
        super(new Map<Id, UserRecordAccess>(), Schema.UserRecordAccess.SObjectType);
        this.userRecordAccessMap = (Map<Id, UserRecordAccess>) super.records;
    }

    public List<UserRecordAccess> getUserRecordAccessesBySetRecordIds(Set<Id> recordIds) {
        List<UserRecordAccess> uerRecordAccessList = new List<UserRecordAccess>();
        for (UserRecordAccess recordAccess : userRecordAccessMap.values()) {
            if (recordIds.contains(recordAccess.RecordId)) {
                uerRecordAccessList.add(recordAccess);
            }
        }
        return uerRecordAccessList;
    }
}
