/**
 * @description Interface for CourseOfferingsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                         |
      |--------------------------------|-----------------------|------------------------|----------------------------------------|
      | eugene.andrew.abuan            | July 10, 2023         | DEPP-5483              | Created file                           |
      | kenneth.f.alsay                | September 25, 2023    | DEPP-6629              | added getRecordsLikeName               |
      | sebastianne.k.trias            | January 25, 2024      | DEPP-7481              | added queryLocatorGetPastActiveRecords |
 */
public interface ICourseOfferingsDAO extends DmlInterface {
     List<hed__Course_Offering__c> getRecordsLikeName(
          String name
     );
     Database.QueryLocator queryLocatorGetPastActiveRecords();
}