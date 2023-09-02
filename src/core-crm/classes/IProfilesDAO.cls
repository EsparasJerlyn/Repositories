/**
 * @description Interface for Profile DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 26, 2023         | DEPP-5411,DEPP-5369    | Created file                 |
 */
public interface IProfilesDAO extends DmlInterface {
    List<Profile> getProfileRecordsBySetIds(Set<Id> profileIdSet);
}
