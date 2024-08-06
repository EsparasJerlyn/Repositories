/**
 * @description Interface for Operating Hours DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | john.aldric.s.seril            | Jul 26, 2024          | DEPP-9834              | Created file                                   |
*/
public interface IOperatingHoursDAO extends DmlInterface {
	Database.QueryLocator queryLocatorGetVoiceOperatingHours();
}