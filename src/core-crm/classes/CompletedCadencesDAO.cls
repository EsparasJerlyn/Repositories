/**
 * @description DAO Completed Cadence Object. Contains soql and constants related to the custom object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                               |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | Created file                                 |
      | roy.nino.s.regala              | Aug 9, 2023           | DEPP-5677              | added new query                              |
 */
public inherited sharing class CompletedCadencesDAO extends DmlBase implements ICompletedCadencesDAO {
    public static ICompletedCadencesDAO newInstance() {
        return (ICompletedCadencesDAO) ImplementationSelector.DAO.newInstance(
            Completed_Cadence__c.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return Completed_Cadence__c.SObjectType;
    }

    public List<Completed_Cadence__c> getCompletedCadenceByContactIds(
        Set<Id> contactIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Application__c, Contact__c, Lead__c, Nurture_Track_Configuration__c, Nurture_Track_Configuration__r.Cadence_Name__c ' +
            'FROM Completed_Cadence__c ' +
            'WHERE Contact__c IN:contactIds '+
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<Completed_Cadence__c> getCompletedCadenceByLeadIds(
        Set<Id> leadIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Application__c, Contact__c, Lead__c, Nurture_Track_Configuration__c ' +
                'FROM Completed_Cadence__c ' +
                'WHERE Lead__c IN:leadIds ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<Completed_Cadence__c> getCompletedCadenceByTargetIdsAndCadenceName(
        Set<Id> targetIds,
        Set<String> cadenceNames
    ) {
        return [//NOPMD
            SELECT Id, Contact__c, Lead__c, Completed_Cadence_Status__c
            FROM Completed_Cadence__c
            WHERE
                Nurture_Track_Configuration__r.Cadence_Name__c IN :cadenceNames
                AND Completed_Cadence_Status__c = 'Unsuccessful'
                AND (Contact__c IN :targetIds
                OR Lead__c IN :targetIds)
            WITH USER_MODE
            ORDER BY CreatedDate ASC
        ];
    }
}
