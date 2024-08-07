/**
 * @description Interface for Completed Cadences
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | created file                               |
      | roy.nino.s.regala              | Aug 9, 2023           | DEPP-5677              | added new query                            |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added filter condition                     |
      | eccarius.munoz                 | April 30, 2024        | DEPP-8041              | Added methods for                          |
      |                                |                       |                        | outreach case.                             |
      | julie.jane.alegre              | May 06, 2024          | DEPP-8490              | Add access level on findByCriteria method  |
      | eugene.andrew.abuan            | August 05, 2024       | DEPP-8255              | Added methodd to get CC by Id and Status   |

 */
public interface ICompletedCadencesDAO extends DmlInterface {
    List<Completed_Cadence__c> getCompletedCadenceByContactIds(
        Set<Id> contactIds,
        String accessLevel
    );
    List<Completed_Cadence__c> getCompletedCadenceByLeadIds(
        Set<Id> leadIds,
        String accessLevel
    );
    List<Completed_Cadence__c> getCompletedCadenceByTargetIdsAndCadenceName(
        Set<String> targetIds,
        Set<String> cadenceNames,
        String accessLevel
    );
    List<Completed_Cadence__c> getCompletedCadenceByTargetIds(
        Set<Id> targetIds,
        Set<String> cadenceNames,
        String accessLevel
    );
    
    String getWhereClauseByCriteria(
        CompletedCadencesDAO.Criteria completedCadenceCriteria, 
        ContactsDAO.Criteria contactCriteria
    );

    String getContactQueryByCriteria(
         CompletedCadencesDAO.Criteria completedCadenceCriteria, 
         ContactsDAO.Criteria contactCriteria
    );

    String getQueryByCriteria(
        CompletedCadencesDAO.Criteria completedCadenceCriteria, 
        ContactsDAO.Criteria contactCriteria
    );

    List<Completed_Cadence__c> findByCriteria(
        CompletedCadencesDAO.Criteria completedCadenceCriteria, 
        ContactsDAO.Criteria contactCriteria,
        AccessLevel AccessLevel
    );

    List<Completed_Cadence__c> getCompletedCadencebyRecordId(
        Set<Id> completedCadenceIdSet,
        AccessLevel accessLevel
    );

    List<Completed_Cadence__c> getCompletedCadenceByStatus(
        String status,
        AccessLevel accessLevel
    );
} 