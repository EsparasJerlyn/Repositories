/**
 * @description DAO Class for et4ae5__IndividualEmailResult__c Object. 
 * Contains soql and constants related to the et4ae5__IndividualEmailResult__c object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                              |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------|
 *    | eccarius.munoz                 | October 26, 2023      | DEPP-5866              | created file                                |
 */
public inherited sharing class IndividualEmailResultsDAO extends DmlBase implements IIndividualEmailResultsDAO {

    public static IIndividualEmailResultsDAO newInstance() {
        return (IIndividualEmailResultsDAO) ImplementationSelector.DAO.newInstance(
            et4ae5__IndividualEmailResult__c.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return et4ae5__IndividualEmailResult__c.SObjectType;
    }

    public List<et4ae5__IndividualEmailResult__c> getIndivEmailResultsByContactOrLeadIds(
        Set<Id> contactLeadIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, et4ae5__Contact__c, et4ae5__Lead__c, et4ae5__Opened__c, et4ae5__Clicked__c, et4ae5__DateOpened__c ' +
              'FROM et4ae5__IndividualEmailResult__c ' +
             'WHERE et4ae5__Contact__c IN :contactLeadIds OR et4ae5__Lead__c IN :contactLeadIds',
            accessLevel
        );
    }
}