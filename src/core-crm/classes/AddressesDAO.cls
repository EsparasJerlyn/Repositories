/**
 * @description DAO Class for hed__Address__c Object. Contains soql and constants related to the hed__Address__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | sep 22, 2023          | DEPP-6652              | Created file
 */
public inherited sharing class AddressesDAO extends DmlBase implements IAddressesDAO {
    public Schema.SObjectType getSObjectType() {
        return hed__Address__c.SObjectType;
    }

    public static IAddressesDAO newInstance() {
        return (IAddressesDAO) ImplementationSelector.DAO.newInstance(hed__Address__c.sObjectType);
    }
}
