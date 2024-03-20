/**
 * @description DAO Class for Donation Cause Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | March 14, 2024        | DEPP-8210              | Created file                                   |
      | eugene.andrew.abuan            | March 20, 2024        | DEPP-8200              | Added Donation Cause Code in query by Id       |

*/

public inherited sharing class DonationCausesDAO extends DmlBase implements IDonationCausesDAO {
    public static final String DC_PUBLISHED = 'Published';
    public static final String DC_ARCHIVED = 'Archived';

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

        String queryFilter =
            'SELECT Id, Ready_For_Publishing__c,QUT_Giving_Publish_Start_Date__c, QUT_Giving_Publish_End_Date__c, Stage__c  ' +
            'FROM Donation_Cause__c ' +
            'WHERE ' +
            stageToPublishRule;

        return Database.getQueryLocator(queryFilter);
    }

    public List<Donation_Cause__c> getDonationCausesBySetRecordIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        if (!recordIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Stage__c, Id, Donation_Cause_Code__c ' + 'FROM Donation_Cause__c WHERE Id IN :recordIds',
                accessLevel
            );
        } else {
            return new List<Donation_Cause__c>();
        }
    }
}
