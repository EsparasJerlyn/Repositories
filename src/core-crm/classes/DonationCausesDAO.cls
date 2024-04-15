/**
 * @description DAO Class for Donation Cause Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | March 14, 2024        | DEPP-8210              | Created file                                   |
      | eugene.andrew.abuan            | March 18, 2024        | DEPP-8211              | Added Active Stage params for query Selector   |         
      | eugene.andrew.abuan            | March 20, 2024        | DEPP-8200              | Added Donation Cause Code in query by Id       |
      | nicole.genon                   | March 20, 2024        | DEPP-8212              | Added Archived Stage params for query Selector |
      | kenneth.f.alsay                | March 27, 2024        | DEPP-8209              | Added getDonationCauseBySetNames               |
      | kenneth.f.alsay                | March 27, 2024        | DEPP-8209              | Added Ready_For_Publishing__c in query by Id   |
*/
public inherited sharing class DonationCausesDAO extends DmlBase implements IDonationCausesDAO {
    public static final String DC_PUBLISHED = 'Published';
    public static final String DC_ARCHIVED = 'Archived';
    public static final String DC_ACTIVE = 'Active';

    public Schema.SObjectType getSObjectType() {
        return Donation_Cause__c.SObjectType;
    }

    public static IDonationCausesDAO newInstance() {
        return (IDonationCausesDAO) ImplementationSelector.DAO.newInstance(
            Donation_Cause__c.SObjectType
        );
    }

    public Database.QueryLocator queryLocatorGetDonatioCausesForStageUpdate() {
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

        String stageToArchivedRule =
            ' ( (Archived_Date__c <= TODAY ' +
            'OR Activation_End_Date__c <= TODAY) ' +
            'AND Stage__c !=: DC_ARCHIVED ' +
            ')';


        String queryFilter =
            'SELECT Id, Ready_For_Publishing__c,QUT_Giving_Publish_Start_Date__c, QUT_Giving_Publish_End_Date__c, Stage__c, ' +
                     'Activation_Start_Date__c, Activation_End_Date__c,Archived_Date__c ' +
            'FROM Donation_Cause__c ' +
            'WHERE ' +
            stageToPublishRule +
            ' OR ' +
            stageToActiveRule +
            'OR ' +
            stageToArchivedRule;

        return Database.getQueryLocator(queryFilter);
    }

    public List<Donation_Cause__c> getDonationCausesBySetRecordIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        if (!recordIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Stage__c, Id, Donation_Cause_Code__c, Ready_For_Publishing__c, (Select Id FROM Products__r)' + 'FROM Donation_Cause__c WHERE Id IN :recordIds',
                accessLevel
            );
        } else {
            return new List<Donation_Cause__c>();
        }
    }

    public List<Donation_Cause__c> getDonationCauseByNameStart(
        String nameStart,
        AccessLevel accessLevel 
    ){
        if (nameStart != null && accessLevel != null) {
            nameStart += '%';
            return Database.query(
                'SELECT Id, Name, Ready_For_Publishing__c ' + 
                'FROM Donation_Cause__c ' + 
                'WHERE Name LIKE :nameStart ',
                accessLevel
            );
        } else {
            return new List<Donation_Cause__c>();
        }
    }
}