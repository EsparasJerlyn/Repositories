/**
 * @description DAO Class for Distribution Managements Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                         |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------------|
      | kenneth.f.alsay                | April 8, 2024         | DEPP-8399              | Created file                                           |
      | kenneth.f.alsay                | April 11, 2024        | DEPP-8453              | Added queryLocatorGetDistributionMgtsForStatusUpdate   |
*/
public inherited sharing class DistributionManagementsDAO extends DmlBase implements IDistributionManagementsDAO {
    public static final String DM_ACTIVE = 'Active';
    public static final String DM_INACTIVE = 'Inactive';
    public static final String DESIGNATION_GIVING_TO_CAUSE_RECTYPE_ID = DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID;
    
    public Schema.SObjectType getSObjectType() {
        return Distribution_Management__c.SObjectType;
    }
    
    public static IDistributionManagementsDAO newInstance() {
        return (IDistributionManagementsDAO) ImplementationSelector.DAO.newInstance(
            Distribution_Management__c.SObjectType
        );
    }
    
    public Database.QueryLocator queryLocatorGetDistributionMgtsForStatusUpdate() {
        //Status = Active
        //End Date <= Current Date
        //Designation Record Type = Giving To Cause
        String statusToInactive =
            ' (Status__c = :DM_ACTIVE ' +
            'AND End_Date__c <= TODAY ' +
            'AND Designation__r.RecordTypeId = :DESIGNATION_GIVING_TO_CAUSE_RECTYPE_ID ' +
            ')';
 
        String queryFilter =
            'SELECT Id, Status__c, End_Date__c, Designation__r.RecordTypeId ' +
            'FROM Distribution_Management__c ' +
            'WHERE ' +
            statusToInactive;
        
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
            'SELECT Id, Status__c, Designation__c, Designation__r.RecordTypeId, End_Date__c ' +
            'FROM Distribution_Management__c ' +
            'WHERE Designation__c IN :designationIds ',
            accessLevel
        );
    } 
}