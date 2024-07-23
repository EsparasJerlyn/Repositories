/**
 * @description Interface for ProgramOfferingsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | julie.jane.alegre              | January 02,2024       | ApexCRUDViolationFix   | Created file                 |
 */
public interface IProgramOfferingsDAO extends DmlInterface{
    List<Program_Offering__c> getProgramOfferingByRecordIds(
          Set<Id> programOfferIdSet,
          AccessLevel accessLevel
     ); 
}
