/**
 * @description Mock DAO Class for Application_Preference__c Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 11, 2023       |DEPP-6252               | Created File                        |
 */
@isTest
public inherited sharing class ApplicationPreferencesDAOMock extends DmlBaseMock implements IApplicationPreferencesDAO{
    public Map<Id, Application_Preference__c> applicationPreferenceMap;

    public ApplicationPreferencesDAOMock() {
        super(new Map<Id, Application_Preference__c>(), Schema.Application_Preference__c.SObjectType);
        this.applicationPreferenceMap = (Map<Id, Application_Preference__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return Application_Preference__c.SObjectType;
    }

    public List<Application_Preference__c> getApplicationPreferenceByAppSetIdsQTAC(
        Set<Id> applicationIDSet,
		AccessLevel accessLevel 
    ) {
        List<Application_Preference__c> applicationPrefList = new List<Application_Preference__c>();

        for (Application_Preference__c record : applicationPreferenceMap.values()) {
            if (applicationIDSet.contains(record.Application__c)) {
                applicationPrefList.add(record);
            }
        }

        return applicationPrefList;
    }

    public List<Application_Preference__c> getApplicationPreferenceByAppSetIdsStudyLink(
        Set<Id> applicationIDSet,
		AccessLevel accessLevel 
    ) {
        List<Application_Preference__c> applicationPrefList = new List<Application_Preference__c>();

        for (Application_Preference__c record : applicationPreferenceMap.values()) {
            if (applicationIDSet.contains(record.Application__c)) {
                applicationPrefList.add(record);
            }
        }

        return applicationPrefList;
    }

    public List<Application_Preference__c> getCurrentApplicationPreferenceById(
        Set<Id> applicationPreferenceIds,
		String accessLevel 
    ) {
        List<Application_Preference__c> applicationPrefList = new List<Application_Preference__c>();

        for (Application_Preference__c record : applicationPreferenceMap.values()) {
            if (applicationPreferenceIds.contains(record.Application__c)) {
                applicationPrefList.add(record);
            }
        }

        return applicationPrefList;
    }
}