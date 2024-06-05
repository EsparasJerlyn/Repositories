/**
 * @description Mock DAO Class for Contact Matching Service Configuration Metadata. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 05, 2024         | DEPP-9210              | Created file
 */
@isTest
public inherited sharing class ConMatchingServiceConfigurationsDAOMock extends DmlBaseMock implements IConMatchingServiceConfigurationsDAO {
    public Map<Id, Contact_Matching_Service_Configuration__mdt> conMatchServiceConfigMap;

    public Schema.SObjectType getSObjectType() {
        return Contact_Matching_Service_Configuration__mdt.SObjectType;
    }

    public ConMatchingServiceConfigurationsDAOMock() {
        super(
            new Map<Id, Contact_Matching_Service_Configuration__mdt>(),
            Schema.Contact_Matching_Service_Configuration__mdt.SObjectType
        );
        this.conMatchServiceConfigMap = (Map<Id, Contact_Matching_Service_Configuration__mdt>) super.records;
    }

    public Contact_Matching_Service_Configuration__mdt getInstanceByDeveloperName(
        String developerName
    ) {
        return (Contact_Matching_Service_Configuration__mdt) JSON.deserialize(
            '{"IsActive__c":"true","Size__c":"200","DeveloperName":"' + developerName + '"}',
            Contact_Matching_Service_Configuration__mdt.class
        );
    }
}
