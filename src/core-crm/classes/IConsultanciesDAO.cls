/**
 * @description Interface for Consultancy DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public interface IConsultanciesDAO extends DmlInterface {
    List<Consultancy__c> getConsultanciesWithActionsBySetProductRequestIds(
        Set<Id> productRequestIds
    );
    List<Consultancy__c> getConsultanciesBySetNames(Set<String> consultancyNames);
}
