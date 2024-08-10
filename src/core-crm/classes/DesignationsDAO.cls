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
      | eugene.andrew.abuan            | March 20, 2024        | DEPP-8200              | Added Designation Code in query by Id          |
      | nicole.genon                   | March 20, 2024        | DEPP-8212              | Added Archived Stage params for query Selector |
      | kenneth.f.alsay                | April 05, 2024        | DEPP-8399              | Added getDesignationsByNameStart               |
      | kenneth.f.alsay                | April 08, 2024        | DEPP-8399              | Added Record Type Ids                          |
      | eugene.andrew.abuan            | April 10, 2024        | DEPP-8390              | Added Define Stage string                      |
      | eugene.andrew.abuan            | April 10, 2024        | DEPP-8401              | Added Recordtype checking & Distribution Mngmnt|
*/

public inherited sharing class DesignationsDAO extends DmlBase implements IDesignationsDAO {
    
    public static final String DC_PUBLISHED = 'Published';
    public static final String DC_ARCHIVED = 'Archived';
    public static final String DC_ACTIVE = 'Active';
    public static final String DC_DEFINE = 'Define';
    public static final String ENDOWMENT_ACCOUNT_TYPE_PERPETUAL = 'Perpetual';
    public static final Id GIVING_TO_CAUSE_RECTYPE_ID = Schema.SObjectType.Designation__c.getRecordTypeInfosByDeveloperName()
    .get('Giving_To_Cause')
    .getRecordTypeId();
    public static final Id ENDOWNMENT_RECTYPE_ID = Schema.SObjectType.Designation__c.getRecordTypeInfosByDeveloperName()
    .get('Endowment')
    .getRecordTypeId();
    
    public Schema.SObjectType getSObjectType() {
        return Designation__c.SObjectType;
    }

    public static IDesignationsDAO newInstance() {
        return (IDesignationsDAO) ImplementationSelector.DAO.newInstance(
            Designation__c.SObjectType
        );
    }

    public Database.QueryLocator queryLocatorGetDesignationsForStageUpdate() {
        String stageToPublishRule =
            ' (Ready_For_Publishing__c = True ' +
            'AND Public_Giving_Publish_Start_Date__c <= TODAY ' +
            'AND Public_Giving_Publish_End_Date__c > TODAY ' +
            'AND Stage__c !=: DC_PUBLISHED ' +
            'AND Stage__c !=: DC_ARCHIVED ' +
            ')';
        
        String stageToActiveRule = 
            ' (Activation_Start_Date__c <= TODAY ' +
            'AND Activation_End_Date__c > TODAY '+
            'AND (Ready_For_Publishing__c = false '+
            'OR Public_Giving_Publish_Start_Date__c = null ' +
            'OR Public_Giving_Publish_Start_Date__c > TODAY '+
            'OR Public_Giving_Publish_End_Date__c < TODAY) ' +
            'AND Stage__c !=: DC_ACTIVE '+
            'AND Stage__C !=: DC_ARCHIVED '+ 
            'AND (RecordTypeId =: GIVING_TO_CAUSE_RECTYPE_ID OR RecordTypeId =:ENDOWNMENT_RECTYPE_ID ) ) ';

        String stageToArchivedRule =
            ' ( (Archived_Date__c <= TODAY ' +
            'OR Activation_End_Date__c <= TODAY) ' +
            'AND Stage__c !=: DC_ARCHIVED ' +
            ')';


        String queryFilter =
            'SELECT Id, Ready_For_Publishing__c,Public_Giving_Publish_Start_Date__c, Public_Giving_Publish_End_Date__c, Stage__c, ' +
                     'Activation_Start_Date__c, Activation_End_Date__c,Archived_Date__c, RecordTypeId ' +
            'FROM Designation__c ' +
            'WHERE ' +
            stageToPublishRule +
            ' OR ' +
            stageToActiveRule +
            'OR ' +
            stageToArchivedRule;

        return Database.getQueryLocator(queryFilter);
    }

    public List<Designation__c> getDesignationsBySetRecordIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        if (!recordIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Stage__c, Id, Designation_Code__c, Ready_For_Publishing__c, (Select Id FROM Products__r), Giving_Category__c, Study_Association__c ' + 'FROM Designation__c WHERE Id IN :recordIds',
                accessLevel
            );
        } else {
            return new List<Designation__c>();
        }
    }

    public List<Designation__c> getDesignationsByNameStart(
        String nameStart,
        AccessLevel accessLevel 
    ){
        if (nameStart != null && accessLevel != null) {
            nameStart += '%';
            return Database.query(
                'SELECT Id, Name, Ready_For_Publishing__c ' + 
                'FROM Designation__c ' + 
                'WHERE Name LIKE :nameStart ',
                accessLevel
            );
        } else {
            return new List<Designation__c>();
        }
    }
}