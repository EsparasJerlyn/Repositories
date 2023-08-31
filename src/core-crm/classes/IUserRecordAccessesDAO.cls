/**
 * @description Interface for UserRecordAccess DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Aug 25, 2023          | DEPP-6348             | Created file
 */
public interface IUserRecordAccessesDAO extends DmlInterface {
     List<UserRecordAccess> getUserRecordAccessesBySetRecordIds(Set<Id> recordIds);
}
