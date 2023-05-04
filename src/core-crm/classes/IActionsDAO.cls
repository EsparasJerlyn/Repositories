/**
 * @description Interface for Action DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public interface IActionsDAO extends DmlInterface {
    List<Action__c> getActionsByProductRequestAndRecordType(
        Set<Id> productRequestIds,
        Id recordTypeId
    );
}
