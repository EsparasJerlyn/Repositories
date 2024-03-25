/**
 * @description DAO Class for Designation Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | March 14, 2024        | DEPP-8210              | Created file                                   |
      | eugene.andrew.abuan            | March 18, 2024        | DEPP-8211              | Added Active Stage params for query Selector   |         

*/

public inherited sharing class DesignationsDAO extends DmlBase implements IDesignationsDAO {
    public static final String DC_PUBLISHED = 'Published';
    public static final String DC_ARCHIVED = 'Archived';
    public static final String DC_ACTIVE = 'Active';

    public Schema.SObjectType getSObjectType() {
        return Designation__c.SObjectType;
    }

    public static IDesignationsDAO newInstance() {
        return (IDesignationsDAO) ImplementationSelector.DAO.newInstance(
            Designation__c.SObjectType
        );
    }

    public Database.QueryLocator queryLocatorDesignationsForStageUpdate() {
        String stageToPublishRule =
            ' (Ready_For_Publishing__c = True ' +
            'AND QUT_Giving_Publish_Start_Date__c <= TODAY ' +
            'AND QUT_Giving_Publish_End_Date__c > TODAY ' +
            'AND Stage__c !=: DC_PUBLISHED ' +
            'AND Stage__c !=: DC_ARCHIVED ' +
            ')';
        
        String stageToActiveRule = 
            ' (Activation_Start_Date__c <= TODAY ' +
            'AND Activation_End_Date__c > TODAY '+
            'AND (Ready_For_Publishing__c = false '+
            'OR QUT_Giving_Publish_Start_Date__c = null ' +
            'OR QUT_Giving_Publish_Start_Date__c > TODAY '+
            'OR QUT_Giving_Publish_End_Date__c < TODAY) ' +
            'AND Stage__c !=: DC_ACTIVE '+
            'AND Stage__C !=: DC_ARCHIVED)';


        String queryFilter =
            'SELECT Id, Ready_For_Publishing__c,QUT_Giving_Publish_Start_Date__c, QUT_Giving_Publish_End_Date__c, Stage__c, ' +
                     'Activation_Start_Date__c, Activation_End_Date__c ' +
            'FROM Designation__c ' +
            'WHERE ' +
            stageToPublishRule +
            ' OR ' +
            stageToActiveRule;

        return Database.getQueryLocator(queryFilter);
    }

    public List<Designation__c> getDesignationsBySetRecordIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        if (!recordIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Stage__c, Id ' + 'FROM Designation__c WHERE Id IN :recordIds',
                accessLevel
            );
        } else {
            return new List<Designation__c>();
        }
    }
}
