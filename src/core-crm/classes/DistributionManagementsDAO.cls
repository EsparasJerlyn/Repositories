/**
 * @description DAO Class for Distribution Management Object.
 * @author Accenture
 *
 * @history
 *

 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                                     |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------------------------------------------------|
      | kenneth.f.alsay                | April 8, 2024         | DEPP-8399              | Created file                                                                                       |
      | kenneth.f.alsay                | April 11, 2024        | DEPP-8453              | Added queryLocatorGetDistributionMgtsForStatusUpdate                                               |
      | nicole.genon                   | April 11, 2024        | DEPP-8452              | Added statusToActive queryLocatorGetDistributionMgtsForStatusUpdate                                |
      | neil.s.h.lesidan               | April 11, 2024        | DEPP-8392              | Update query, method getDistributionManagementByDesignationId                                      |
      | kenneth.f.alsay                | May 13, 2024          | IT3P2ST FIX            | Updated statusToActive soql string                                                                 |
*/
public inherited sharing class DistributionManagementsDAO extends DmlBase implements IDistributionManagementsDAO {
    public static final String DM_ACTIVE = 'Active';
    public static final String DM_INACTIVE = 'Inactive';
    public static final String DM_READY_FOR_USE = 'Ready For Use';
    public static final String DESIGNATION_GIVING_TO_CAUSE_RECTYPE_ID = DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID;
    public static final String STATUS_DEFINE = 'Define';
    public static final Date CUSTOM_DATE = (Test.isRunningTest()) ? (System.today() + 5) : System.Today();

    public Schema.SObjectType getSObjectType() {
        return Distribution_Management__c.SObjectType;
    }

    public static IDistributionManagementsDAO newInstance() {
        return (IDistributionManagementsDAO) ImplementationSelector.DAO.newInstance(
            Distribution_Management__c.SObjectType
        );
    }

    public Database.QueryLocator queryLocatorGetDistributionMgtsForStatusUpdate() {
        String statusToInactive =
            ' (Status__c = :DM_ACTIVE ' +
            'AND End_Date__c <= TODAY ' +
            ')';

        String statusToActive =
        ' (Status__c = :DM_READY_FOR_USE ' +
        'AND Start_Date__c <= :CUSTOM_DATE ' +
        'AND End_Date__c > :CUSTOM_DATE ' +
        ')';

        String queryFilter =
            'SELECT Id, Status__c, End_Date__c, Start_Date__c, Designation__r.RecordTypeId ' +
            'FROM Distribution_Management__c ' +
            'WHERE ' +
            statusToInactive +
            ' OR ' +
            statusToActive;

        return Database.getQueryLocator(queryFilter);
    }

    public List<Distribution_Management__c> getDistributionManagementByDesignationId(
        Set<Id> designationIds,
        AccessLevel accessLevel
    ){
        if(designationIds.isEmpty()){
            return new List<Distribution_Management__c>();
        }
        return Database.query(
            'SELECT Id, Status__c, Designation__c, End_Date__c, Start_Date__c, Name ' +
            'FROM Distribution_Management__c ' +
            'WHERE Designation__c IN :designationIds ',
            accessLevel
        );
    }

    public List<Distribution_Management__c> getDistributionManagementsBySetRecordIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        if (!recordIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Designation__c, Start_Date__c, End_Date__c, Status__c ' +
                'FROM Distribution_Management__c WHERE Id IN :recordIds',
                accessLevel
            );
        } else {
            return new List<Distribution_Management__c>();
        }
    }
}