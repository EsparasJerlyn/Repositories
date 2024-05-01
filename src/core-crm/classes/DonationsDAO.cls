/**
 * @description DAO Class for Donation Object.
 * @author Accenture
 *
 * @history
 *
 *    |  Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |---------------------------------|-----------------------|------------------------|------------------------------------------------|
      |  nicole.genon                   | March 29, 2024        | DEPP-8167              | Created file                                   |
      |  kenneth.f.alsay                | April 23, 2024        | DEPP-8528              | Added CAUSE_RECTYPE_ID                         |
      |  kenneth.f.alsay                | April 23, 2024        | DEPP-8528              | Added getDonationsBySetRecordIds               |
      |  kenneth.f.alsay                | April 24, 2024        | DEPP-8528              | Added final Strings for stages and payment type|
      |                                 |                       |                        | queryLocatorGetDonationsForStageUpdate         |
*/
public inherited sharing class DonationsDAO extends DmlBase implements IDonationsDAO {
    //Strings for payment types
    public static final String RECURRING_PAYMENT_TYPE = 'Recurring Payment';

    //Strings for stages
    public static final String ACCEPTED_STAGE = 'Accepted';
    public static final String CANCELLED_STAGE = 'Cancelled';
    public static final String COMPLETED_STAGE = 'Completed';
    public static final String DECLINED_STAGE = 'Declined';
    public static final String PROPOSED_STAGE = 'Proposed';

    //Record Type Ids
    public static final Id CAUSE_RECTYPE_ID = Schema.SObjectType.Donation__c.getRecordTypeInfosByDeveloperName()
    .get('Cause')
    .getRecordTypeId();
    public static final Id GIFT_IN_KIND_RECTYPE_ID = Schema.SObjectType.Donation__c.getRecordTypeInfosByDeveloperName()
    .get('Gift_In_Kind')
    .getRecordTypeId();

    public Schema.SObjectType getSObjectType() {
        return Donation__c.SObjectType;
    }

    public static IDonationsDAO newInstance() {
        return (IDonationsDAO) ImplementationSelector.DAO.newInstance(
            Donation__c.SObjectType
        );
    }

    public Database.QueryLocator queryLocatorGetDonationsForStageUpdate() {
        String stageToCompletedRecurringRule =
            ' (RecordTypeId = :CAUSE_RECTYPE_ID ' +
            'AND Payment_Type__c = :RECURRING_PAYMENT_TYPE ' +
            'AND Final_Instalment_Date__c <= TODAY ' + 
            'AND (Stage__c !=: COMPLETED_STAGE ' +
            'AND Stage__c !=: CANCELLED_STAGE ' +
            'AND Stage__c !=: DECLINED_STAGE ' +
            'AND Stage__c !=: PROPOSED_STAGE) ' +
            ')';

        String queryFilter =
            'SELECT Id, Payment_Type__c, Final_Instalment_Date__c, Stage__c, RecordTypeId ' +
            'FROM Donation__c ' +
            'WHERE ' +
            stageToCompletedRecurringRule;

        return Database.getQueryLocator(queryFilter);
    }

    public static List<Donation__c> getDonationsByOpportunityIds(
        Set<Id> opportunityIds,
        AccessLevel accessLevel
    ) {
        if (!opportunityIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Stage__c, Opportunity__c ' + 
                'FROM Donation__c WHERE Opportunity__c IN :opportunityIds',
                accessLevel
            );
        } else {
            return new List<Donation__c>();
        }
    }

    public List<Donation__c> getDonationsBySetRecordIds(
        Set<Id> recordIds,
        AccessLevel accessLevel 
    ){
        if (!recordIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Final_Instalment_Date__c, Stage__c, Payment_Type__c ' + 
                'FROM Donation__c ' + 
                'WHERE Id IN :recordIds ',
                accessLevel
            );
        } else {
            return new List<Donation__c>();
        }
    }
}