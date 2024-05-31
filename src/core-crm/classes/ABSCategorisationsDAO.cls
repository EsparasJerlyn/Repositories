/**
 * @description DAO Class for ABS_Categorisation__c Object. Contains soql and constants related to the ABS_Categorisation__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 27, 2024          | DEPP-8954              | Created file                 |
 */
public inherited sharing class ABSCategorisationsDAO extends DmlBase implements IABSCategorisationsDAO {
    
    public Schema.SObjectType getSObjectType() {
        return ABS_Categorisation__c.SObjectType;
    }

    public static IABSCategorisationsDAO newInstance() {
        return (IABSCategorisationsDAO) ImplementationSelector.DAO.newInstance(ABS_Categorisation__c.sObjectType);
    }
    
    public List<ABS_Categorisation__c> getLatestUpdatedActiveCategorisationRecord(
        String accessLevel
    ) {
        return Database.query(
            'SELECT Id,Effective_End_Date__c, Effective_Start_Date__c, Is_Active__c, Low_SES_Lower_Boundary__c, Low_SES_Upper_Boundary__c, Remoteness_Inner_Regional__c, Remoteness_Outer_Regional__c, ' +
            'Remoteness_Remote__c, Remoteness_Very_Remote__c ' +
            'FROM ABS_Categorisation__c ' +
            'WHERE Is_Active__c = TRUE ' +
            'WITH ' + String.escapeSingleQuotes(accessLevel) +
            ' ORDER BY LastModifiedDate DESC LIMIT 1'
        );             
    }
}