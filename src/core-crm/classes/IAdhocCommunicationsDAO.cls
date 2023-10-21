/**
 * @description Interface for Adhoc Communication DAO framework
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | eugene.andrew.abuan            | October 10, 2023      | DEPP-6612              | Created File                               |
 */
public interface IAdhocCommunicationsDAO extends DmlInterface{
     List<Adhoc_Communication__c> getAdhocCommunicationsByOfferingFieldAndProductOfferingId(
        String productOfferingId, 
        String offeringField,
        AccessLevel accessLevel
    );

     Database.QueryLocator getAdhocCommunicationsByDate(
     Date todayDate
     );
}
