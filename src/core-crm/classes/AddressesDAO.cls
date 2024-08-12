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
    
    public static final String VALID_ADDRESS = 'Valid';
    public static final String NOT_VALID_ADDRESS = 'Not Valid';
    public static final String FIRST_ADMITTED_ADDRESS = 'First Admitted';
    public static final String OTHER_ADDRESS = 'Other';
    public static final String OUTER_REGIONAL_AUSTRALIA = 'OUTER REGIONAL AUSTRALIA';
    public static final String INNER_REGIONAL_AUSTRALIA = 'INNER REGIONAL AUSTRALIA';
    public static final String REMOTE = 'REMOTE AUSTRALIA';
    public static final String VERY_REMOTE = 'VERY REMOTE AUSTRALIA';
    public static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    public static final String INTEGRATION_STATUS_FAILED = 'Failed';
    public static final String INTEGRATION_STATUS_SENT = 'Sent';
    public static final String INTEGRATION_STATUS_RETRY = 'Retry';
    public static final Set<String> MAILING_COUNTRY_AU = new Set<String>{'AU','AUS','Australia'};
    
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
    
    public List<hed__Address__c> getAddressesByContactIdsAndAddressType(
        Set<Id> contactIdsSet,
        Set<String> addressTypes,
        String accessLevel
    ) {
        if (contactIdsSet.isEmpty()) {
            return new List<hed__Address__c>();
        }
        
        return Database.query(
            'SELECT Id, hed__Parent_Contact__c, hed__Address_Type__c, Validated__c, LastModifiedDate, ABS_Categorisation__c, hed__Formula_MailingAddress__c, hed__MailingCity__c, Remoteness_Class__c, ' +
            'hed__MailingCountry__c, hed__MailingCounty__c, hed__MailingState__c, hed__MailingStreet__c, hed__Formula_MailingStreetAddress__c, hed__MailingStreet2__c, hed__MailingPostalCode__c, Meshblock_Id__c, ' +
            'Socio_Economic_Percentile__c, Statistical_Area_1_Id__c, hed__Parent_Contact__r.Regional_Remote__c, hed__Parent_Contact__r.Low_Socio_Economic_Status__c, Address_Integration_Status__c, Is_First_Admission_Address__c, ' +
            'GNAF_ID__c, hed__Parent_Contact__r.hed__Citizenship_Status__c ' +
            'FROM hed__Address__c ' +
            'WHERE hed__Parent_Contact__c IN: contactIdsSet ' +
            'AND hed__Address_Type__c IN: addressTypes ' +
            'WITH ' + String.escapeSingleQuotes(accessLevel) +
            ' ORDER BY LastModifiedDate DESC'
        );
    }

    public Database.QueryLocator getQueryLocatorByIds(Set<Id> recordIds) {        
        return Database.getQueryLocator(
            'SELECT Id, hed__Parent_Contact__c, hed__Address_Type__c, Validated__c, LastModifiedDate, ABS_Categorisation__c, Address_Integration_Status__c, ' + 
                'hed__Formula_MailingAddress__c, hed__MailingCity__c, Remoteness_Class__c, hed__MailingCountry__c, hed__MailingCounty__c, Is_First_Admission_Address__c, ' +
                'hed__MailingState__c, hed__MailingStreet__c, hed__Formula_MailingStreetAddress__c, hed__MailingStreet2__c, hed__MailingPostalCode__c, Meshblock_Id__c, ' +
                'Socio_Economic_Percentile__c, Statistical_Area_1_Id__c, hed__Parent_Contact__r.Regional_Remote__c, hed__Parent_Contact__r.Low_Socio_Economic_Status__c, ' +
                'GNAF_ID__c ' +
             'FROM hed__Address__c ' + 
            'WHERE Id IN : recordIds');
    }

    public Database.QueryLocator getQueryLocatorByIntegrationStatus(Set<String> status) {        
        return Database.getQueryLocator(
            'SELECT Id, hed__Parent_Contact__c, hed__Address_Type__c, Validated__c, LastModifiedDate, ABS_Categorisation__c, Address_Integration_Status__c, ' + 
                'hed__Formula_MailingAddress__c, hed__MailingCity__c, Remoteness_Class__c, hed__MailingCountry__c, hed__MailingCounty__c, Is_First_Admission_Address__c, ' +
                'hed__MailingState__c, hed__MailingStreet__c, hed__Formula_MailingStreetAddress__c, hed__MailingStreet2__c, hed__MailingPostalCode__c, Meshblock_Id__c, ' +
                'Socio_Economic_Percentile__c, Statistical_Area_1_Id__c, hed__Parent_Contact__r.Regional_Remote__c, hed__Parent_Contact__r.Low_Socio_Economic_Status__c, ' +
                'GNAF_ID__c ' +
             'FROM hed__Address__c ' + 
            'WHERE Address_Integration_Status__c IN : status');
    }

    public List<hed__Address__c> getAddressesByIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {      
        
        if (recordIds.isEmpty()) {
            return new List<hed__Address__c>();
        }

        return Database.query(
            'SELECT Id, hed__Parent_Contact__c, hed__Address_Type__c, Validated__c, LastModifiedDate, ABS_Categorisation__c, Address_Integration_Status__c, hed__Parent_Contact__r.QUT_Student__c, ' + 
                'hed__Formula_MailingAddress__c, hed__MailingCity__c, Remoteness_Class__c, hed__MailingCountry__c, hed__MailingCounty__c, Is_First_Admission_Address__c, ' +
                'hed__MailingState__c, hed__MailingStreet__c, hed__Formula_MailingStreetAddress__c, hed__MailingStreet2__c, hed__MailingPostalCode__c, Meshblock_Id__c, ' +
                'Socio_Economic_Percentile__c, Statistical_Area_1_Id__c, hed__Parent_Contact__r.Regional_Remote__c, hed__Parent_Contact__r.Low_Socio_Economic_Status__c, ' +
                'GNAF_ID__c ' +
             'FROM hed__Address__c ' + 
            'WHERE Id IN : recordIds',
            accessLevel
        );
    }

}
