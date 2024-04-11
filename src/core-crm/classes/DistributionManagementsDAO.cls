/**
 * @description DAO Class for Distribution Managements Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | kenneth.f.alsay                | April 8, 2024         | DEPP-8399              | Created file                                   |
*/
public inherited sharing class DistributionManagementsDAO extends DmlBase implements IDistributionManagementsDAO {
    public Schema.SObjectType getSObjectType() {
        return Distribution_Management__c.SObjectType;
    }
    
    public static IDistributionManagementsDAO newInstance() {
        return (IDistributionManagementsDAO) ImplementationSelector.DAO.newInstance(
            Distribution_Management__c.SObjectType
        );
    }

    public List<Distribution_Management__c> getDistributionManagementByDesignationId(
        Set<Id> designationIds,
        AccessLevel accessLevel
    ){
        if(designationIds.isEmpty()){
            return new List<Distribution_Management__c>();
        }
        return Database.query(
            'SELECT Id, Status__c, Designation__c ' +
            'FROM Distribution_Management__c ' +
            'WHERE Designation__c IN :designationIds ',
            accessLevel
        );
    } 
}