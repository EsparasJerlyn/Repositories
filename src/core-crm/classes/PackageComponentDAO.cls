/**
 * @description DAO Class for Package_Component__c Object. Contains soql and constants related to the Package Component object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | arsenio.jr.dayrit              | August 15, 2023       | DEPP-6370              | created file                               |
 *    | eccarius.munoz                 | August 21, 2023       |DEPP-6252               | Added getPackageComponentsByAppPrefIdSet   |               |
 */
public inherited sharing class PackageComponentDAO extends DmlBase implements IPackageComponentDAO {

    public static IPackageComponentDAO newInstance() {
        return (IPackageComponentDAO) ImplementationSelector.DAO.newInstance(Package_Component__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Package_Component__c.SObjectType;
    }

    public List<Package_Component__c> getPackageComponentsByAppPrefIdSet(
        Set<Id> applicationPreferenceIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Start_Date__c, Package_Component_No__c, Application_Preference__c ' +
            'FROM Package_Component__c ' +
            'WHERE Application_Preference__c IN :applicationPreferenceIds  ',
            accessLevel
            
        );
    }

}