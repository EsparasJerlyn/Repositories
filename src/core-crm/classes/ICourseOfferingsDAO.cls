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
      | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCourseOfferingByProgramOfferingId |
 */
public interface ICourseOfferingsDAO extends DmlInterface {
     List<hed__Course_Offering__c> getRecordsLikeName(
          String name
     );

     List<hed__Course_Offering__c> getCourseOfferingByProgramOfferingId(
        Set<Id> programOfferingIds,
        AccessLevel accessLevel
    );
}
