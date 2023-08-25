/**
 * @description DAO Class for UserRecordAccess Object. Contains soql and constants related to the UserAccessRecord object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Aug 25, 2023          | DEPP-6348              | Created file
 */
public inherited sharing class UserRecordAccessesDAO extends DmlBase implements IUserRecordAccessesDAO {
    public Schema.SObjectType getSObjectType() {
        return UserRecordAccess.SObjectType;
    }

    public static IUserRecordAccessesDAO newInstance() {
        return (IUserRecordAccessesDAO) ImplementationSelector.DAO.newInstance(
            UserRecordAccess.SObjectType
        );
    }

    public List<UserRecordAccess> getUserRecordAccessesBySetRecordIds(Set<Id> recordIds) {
        return [
            SELECT HasEditAccess, HasReadAccess, RecordId
            FROM UserRecordAccess
            WHERE RecordId IN :recordIds AND UserId = :UserInfo.getUserId()
			WITH USER_MODE
        ];
    }
}
