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
        Contact_Matching_Service_Configuration__mdt customMetadata = null;

        for(Contact_Matching_Service_Configuration__mdt cmsConfig: conMatchServiceConfigMap.values()){
            if(cmsConfig.DeveloperName == developerName){
                return cmsConfig;
            }
        }

        return customMetadata;
    }
}
