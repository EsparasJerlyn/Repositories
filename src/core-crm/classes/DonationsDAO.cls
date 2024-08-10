/**
 * @description DAO Class for Donation Object.
 * @author Accenture
 *
 * @history
 *
 *    |  Developer Email                | Date                  | JIRA                   | Change Summary                                                        |
      |---------------------------------|-----------------------|------------------------|-----------------------------------------------------------------------|
      |  nicole.genon                   | March 29, 2024        | DEPP-8167              | Created file                                                          |
      |  kim.howard.capanas             | April 18, 2024        | DEPP-8499              | added getDonationAssetsByDonationId method                            |
      |  kenneth.f.alsay                | April 23, 2024        | DEPP-8528              | Added CAUSE_RECTYPE_ID                                                |
      |  kenneth.f.alsay                | April 23, 2024        | DEPP-8528              | Added getDonationsBySetRecordIds                                      |
      |  kenneth.f.alsay                | April 24, 2024        | DEPP-8528              | Added final Strings for stages and payment type                       |
      |                                 |                       |                        | queryLocatorGetDonationsForStageUpdate                                |
      |  neil.s.h.lesidan               | April 30, 2024        | DEPP-8610              | Add method getDonationsByParentIdRecordType                           |
      |                                 |                       | DEPP-8570              |                                                                       |
      |                                 |                       | DEPP-8682              |                                                                       |
      |  nicole.genon                   | May 2, 2024           | DEPP-8673              | Added getDonationsBySetDonationParentIds,                             |
      |                                 |                       |                        | getDonationsBySetRecordTypeIds                                        |
      |  kenneth.f.alsay                | May 6, 2024           | DEPP-8520              | Added Cancellation_Date__c to getDonationsBySetRecordTypeIds SOQL     |
      |  kenneth.f.alsay                | May 6, 2024           | DEPP-8520              | Added COMPLETED_PART_PAID_STAGE final string                          |
      |  kenneth.f.alsay                | May 6, 2024           | DEPP-8520              | Added stageToCancelledCauseRule string                                |
      |  kenneth.f.alsay                | May 10, 2024          | DEPP-8566              | Added PLEDGE_DESIGNATION_SPLIT_RECTYPE_ID final string                |
      |  neil.s.h.lesidan               | April 30, 2024        | DEPP-8595              | Add PLEDGE_DESIGNATION_SPLIT_RECTYPE_NAME final string                |
      |                                 |                       | DEPP-8632              | Add ENDOWMENT_INSTALMENT_RECTYPE_NAME final string                    |
      |                                 |                       | DEPP-8596              | Add PLEDGE_INSTALMENT_RECTYPE_NAME final string                       |
      |                                 |                       | DEPP-8621              |                                                                       |
      |                                 |                       | DEPP-8720              |                                                                       |
      |                                 |                       | DEPP-8721              |                                                                       |
*/

public inherited sharing class DonationsDAO extends DmlBase implements IDonationsDAO {
    //Strings for payment types
    public static final String RECURRING_PAYMENT_TYPE = 'Recurring Payment';
    public static final String PAYMENT_PLAN_PAYMENT_TYPE = 'Payment Plan';

    //Strings for stages
    public static final String ACCEPTED_STAGE = 'Accepted';
    public static final String CANCELLED_STAGE = 'Cancelled';
    public static final String COMPLETED_STAGE = 'Completed';
    public static final String DECLINED_STAGE = 'Declined';
    public static final String PROPOSED_STAGE = 'Proposed';
    public static final String COMPLETED_PART_PAID_STAGE = 'Completed - Part Paid';

    //Record Type Ids
    public static final Id CAUSE_RECTYPE_ID = Schema.SObjectType.Donation__c.getRecordTypeInfosByDeveloperName()
    .get('Cause')
    .getRecordTypeId();
    public static final Id GIFT_IN_KIND_RECTYPE_ID = Schema.SObjectType.Donation__c.getRecordTypeInfosByDeveloperName()
    .get('Gift_In_Kind')
    .getRecordTypeId();
    public static final Id ENDOWMENT_RECTYPE_ID = Schema.SObjectType.Donation__c.getRecordTypeInfosByDeveloperName()
    .get('Endowment')
    .getRecordTypeId();
    public static final Id ENDOWMENT_INSTALMENT_RECTYPE_ID = Schema.SObjectType.Donation__c.getRecordTypeInfosByDeveloperName()
    .get('Endowment_Instalment')
    .getRecordTypeId();
    public static final Id PLEDGE_RECTYPE_ID = Schema.SObjectType.Donation__c.getRecordTypeInfosByDeveloperName()
    .get('Pledge')
    .getRecordTypeId();
    public static final Id PLEDGE_INSTALMENT_RECTYPE_ID = Schema.SObjectType.Donation__c.getRecordTypeInfosByDeveloperName()
    .get('Pledge_Instalment')
    .getRecordTypeId();
    public static final Id PLEDGE_DESIGNATION_SPLIT_RECTYPE_ID = Schema.SObjectType.Donation__c.getRecordTypeInfosByDeveloperName()
    .get('Pledge_Designation_Split')
    .getRecordTypeId();

    //Record Type Names
    public static final String ENDOWMENT_INSTALMENT_RECTYPE_NAME = Schema.SObjectType.Donation__c.getRecordTypeInfosByDeveloperName()
    .get('Endowment_Instalment')
    .getName();
    public static final String PLEDGE_INSTALMENT_RECTYPE_NAME = Schema.SObjectType.Donation__c.getRecordTypeInfosByDeveloperName()
    .get('Pledge_Instalment')
    .getName();
    public static final String PLEDGE_DESIGNATION_SPLIT_RECTYPE_NAME = Schema.SObjectType.Donation__c.getRecordTypeInfosByDeveloperName()
    .get('Pledge_Designation_Split')
    .getName();

    public Schema.SObjectType getSObjectType() {
        return Donation__c.SObjectType;
    }

    public static IDonationsDAO newInstance() {
        return (IDonationsDAO) ImplementationSelector.DAO.newInstance(
            Donation__c.SObjectType
        );
    }

    public Database.QueryLocator queryLocatorGetDonationsForStageUpdate() {
        String stageToCompletedRecurringCauseRule =
            ' (RecordTypeId = :CAUSE_RECTYPE_ID ' +
            'AND Payment_Type__c = :RECURRING_PAYMENT_TYPE ' +
            'AND Final_Instalment_Date__c <= TODAY ' + 
            'AND (Stage__c !=: COMPLETED_STAGE ' +
            'AND Stage__c !=: CANCELLED_STAGE ' +
            'AND Stage__c !=: DECLINED_STAGE ' +
            'AND Stage__c !=: PROPOSED_STAGE ' +
            'AND Stage__c !=: COMPLETED_PART_PAID_STAGE) ' +
            ')';

        String stageToCancelledCauseRule =
            ' (RecordTypeId = :CAUSE_RECTYPE_ID ' +
            'AND Cancellation_Date__c <= TODAY ' + 
            'AND (Stage__c !=: COMPLETED_STAGE ' +
            'AND Stage__c !=: CANCELLED_STAGE ' +
            'AND Stage__c !=: DECLINED_STAGE) ' +
            ')';

        String queryFilter =
            'SELECT Id, Payment_Type__c, Final_Instalment_Date__c, Stage__c, RecordTypeId, Cancellation_Date__c ' +
            'FROM Donation__c ' +
            'WHERE ' +
            stageToCompletedRecurringCauseRule + ' OR ' +
            stageToCancelledCauseRule;

        return Database.getQueryLocator(queryFilter);
    }

    public static List<Donation__c> getDonationsByOpportunityIds(
        Set<Id> opportunityIds,
        AccessLevel accessLevel
    ) {
        if (!opportunityIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Stage__c, Opportunity__c, Payment_Type__c, To_Designation__c, Contact__c, Is_Anonymous_Donation__c ' +
                'FROM Donation__c WHERE Opportunity__c IN :opportunityIds',
                accessLevel
            );
        } else {
            return new List<Donation__c>();
        }
    }

    public List<Donation__c> getDonationAssetsByDonationId(
        Set<Id> donationIds,
        AccessLevel accessLevel
    ){
        if(donationIds.isEmpty()){
            return new List<Donation__c>();
        }
        return Database.query(
            'SELECT Id, Donation_Asset__c ' +
            'FROM Donation__c ' +
            'WHERE Id IN :donationIds ',
            accessLevel
        );
    }    

    public List<Donation__c> getDonationsBySetRecordIds(
        Set<Id> recordIds,
        AccessLevel accessLevel 
    ){
        if (!recordIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Final_Instalment_Date__c, Stage__c, Payment_Type__c, Cancellation_Date__c ' + 
                'FROM Donation__c ' + 
                'WHERE Id IN :recordIds ',
                accessLevel
            );
        } else {
            return new List<Donation__c>();
        }
    }

    public static List<Donation__c> getDonationsByParentIdRecordType(
        Set<Id> parentDonations,
        Id recordTypeId,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Name, Donation_Parent__c, Total_Amount__c, Instalment_Date__c, Stage__c, Instalment_Number__c, To_Designation__c, To_Designation__r.Name, ' +
            'Donation_Comment__c, Payment_Type__c, Contact__c, Account__c, From_Designation__c, Is_Anonymous_Donation__c ' +
            'FROM Donation__c WHERE Donation_Parent__c  IN :parentDonations ' +
            'AND RecordTypeId = :recordTypeId',
            accessLevel
        );
    }

    public static List<Donation__c> getDonationsBySetDonationParentIds(
        Set<Id> donationParentIds,
        AccessLevel accessLevel
    ) {
        if (!donationParentIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Stage__c, Opportunity__c, Payment_Type__c, To_Designation__c, Contact__c ' + 
                'FROM Donation__c WHERE Donation_Parent__c IN :donationParentIds',
                accessLevel
            );
        } else {
            return new List<Donation__c>();
        }
    }

    public static List<Donation__c> getDonationsBySetRecordTypeIds(
        Set<Id> recordTypeIds,
        AccessLevel accessLevel
    ) {
        if (!recordTypeIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Stage__c, Opportunity__c, Payment_Type__c, To_Designation__c, Contact__c, Cancellation_Reason__c, Cancellation_Comment__c, Cancellation_Date__c, ' +
                'Donation_Parent__c, RecordTypeId, Donation_Comment__c, Total_Amount__c ' +
                'FROM Donation__c WHERE RecordTypeId IN :recordTypeIds',
                accessLevel
            );
        } else {
            return new List<Donation__c>();
        }
    }
}  