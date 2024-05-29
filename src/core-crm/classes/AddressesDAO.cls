/**
 * @description DAO Class for hed__Address__c Object. Contains soql and constants related to the hed__Address__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | sep 22, 2023          | DEPP-6652              | Created file                 |
      | eccarius.munoz                 | May 29, 2024          | DEPP-8955              | added getQueryLocatorByIds   |
 */
public inherited sharing class AddressesDAO extends DmlBase implements IAddressesDAO {

    private static final String ADDRESS_TYPE_OTHER = 'Other';

    public Schema.SObjectType getSObjectType() {
        return hed__Address__c.SObjectType;
    }

    public static IAddressesDAO newInstance() {
        return (IAddressesDAO) ImplementationSelector.DAO.newInstance(hed__Address__c.sObjectType);
    }

    public List<hed__Address__c> getAddressesByContactIdsSet(
        Set<Id> contactIdsSet,
        AccessLevel accessLevel
    ) {
        if (contactIdsSet.isEmpty()) {
            return new List<hed__Address__c>();
        }

        return Database.query(
            'SELECT Id, hed__Parent_Contact__c, hed__Address_Type__c ' +
                'FROM hed__Address__c ' +
                'WHERE hed__Parent_Contact__c IN: contactIdsSet',
            accessLevel
        );
    }

    @SuppressWarnings('PMD.UnusedLocalVariable')
    public Database.QueryLocator getQueryLocatorByIds(Set<Id> addressIdSet){

        String personRecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID; 

        String query =
            'SELECT Id, hed__Parent_Contact__c ' + 
              'FROM hed__Address__c ' + 
             'WHERE Id IN: addressIdSet ' + 
               'AND hed__Parent_Contact__r.QUT_Student__c = true  ' + 
               'AND hed__Parent_Contact__r.RecordTypeId =: personRecordTypeId';

        return Database.getQueryLocator(query);
    }

}
