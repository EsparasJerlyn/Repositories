/**
 * @description et4ae5__IndividualEmailResult__c for Case DAO framework
  *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                              |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------|
 *    | eccarius.munoz                 | October 26, 2023      | DEPP-5866              | created file                                |
 */
public interface IIndividualEmailResultsDAO extends DmlInterface{

    List<et4ae5__IndividualEmailResult__c> getIndivEmailResultsByContactOrLeadIds(
        Set<Id> contactLeadIds,
        AccessLevel accessLevel
    );
}