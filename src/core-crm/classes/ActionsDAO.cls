/**
 * @description DAO Class for Action Object. Contains soql and constants related to the Action object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2023        | DEPP-5567              | Created File                 | 
 */
public inherited sharing class ActionsDAO extends DmlBase implements IActionsDAO {
    /**
     * Action__c Constants
     */
    public static final String ACTIVITY_RECORDTYPE = System.Label.RT_Action_Activity;
    public static final Id ACTIVITY_RECORDTYPE_ID = Schema.SObjectType.Action__c.getRecordTypeInfosByDeveloperName()
        .get(ACTIVITY_RECORDTYPE)
        .getRecordTypeId();
    public static final String INVESTIGATION_RECORDTYPE = System.Label.RT_Action_Investigation;
    public static final Id INVESTIGATION_RECORDTYPE_ID = Schema.SObjectType.Action__c.getRecordTypeInfosByDeveloperName()
        .get(INVESTIGATION_RECORDTYPE)
        .getRecordTypeId();

    public static IActionsDAO newInstance() {
        return (IActionsDAO) ImplementationSelector.DAO.newInstance(Action__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Action__c.SObjectType;
    }

    public List<Action__c> getActionsByProductRequestAndRecordType(
        Set<Id> productRequestIds,
        Id recordTypeId
    ) {
        return [
            SELECT
                Consultancy__r.Id,
                Name,
                Activity_Name__c,
                Activity_Method__c,
                Start_Date__c,
                End_Date__c,
                Investigation_Name__c,
                Investigation_Method__c,
                Is_Complete__c,
                Summary__c
            FROM Action__c
            WHERE
                Consultancy__r.Product_Request__r.Id IN :productRequestIds
                AND RecordTypeId = :recordTypeId
            WITH USER_MODE
        ];
    }
}
