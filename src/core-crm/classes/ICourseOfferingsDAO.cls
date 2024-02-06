/**
 * @description Interface for CourseOfferingsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
      | eugene.andrew.abuan            | July 10, 2023         | DEPP-5483              | Created file                                          |
      | kenneth.f.alsay                | September 25, 2023    | DEPP-6629              | added getRecordsLikeName                              |
      | julie.jane.alegre              | January 02, 2024      | ApexCRUDViolationFix   | added getCourseOfferingByRecordIds                    |
      | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCourseOfferingByProgramOfferingId |
      | sebastianne.k.trias            | January 25, 2024      | DEPP-7481              | added queryLocatorGetPastActiveRecords | 
 */
public interface ICourseOfferingsDAO extends DmlInterface {
     List<hed__Course_Offering__c> getRecordsLikeName(
          String name
     );

     List<hed__Course_Offering__c> getCourseOfferingByProgramOfferingId(
        Set<Id> programOfferingIds,
        AccessLevel accessLevel
    );
     
     List<hed__Course_Offering__c> getCourseOfferingByRecordIds(
          Set<Id> courseOfferIdSet,
          AccessLevel accessLevel
     );

     Database.QueryLocator queryLocatorGetPastActiveRecords();
}
