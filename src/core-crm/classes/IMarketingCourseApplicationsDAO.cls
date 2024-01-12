/**
 * @description Interface for MarketingCourseApplication DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 02, 2024          | n/a                    | Created file
*/
public interface IMarketingCourseApplicationsDAO extends DmlInterface {
    List<Marketing_Course_Application__c> getMrktngCourseAppsByLeadIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ); 
}
