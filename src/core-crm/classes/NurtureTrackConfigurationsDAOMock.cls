/**
 * @description Mock DAO Class for Nurture Track Configuration Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | Created file                 |
 */
@isTest
public inherited sharing class NurtureTrackConfigurationsDAOMock extends DmlBaseMock implements INurtureTrackConfigurationsDAO {
    public Map<Id, Nurture_Track_Configuration__c> nurtureTrackConfigMap;

    public Schema.SObjectType getSObjectType() {
        return Nurture_Track_Configuration__c.SObjectType;
    }

    public NurtureTrackConfigurationsDAOMock() {
        super(new Map<Id, Nurture_Track_Configuration__c>(), Schema.Nurture_Track_Configuration__c.SObjectType);
        this.nurtureTrackConfigMap = (Map<Id, Nurture_Track_Configuration__c>) super.records;
    }

    public List<Nurture_Track_Configuration__c> getNurtureTrackLeadScoreThreshold(
        String accessLevel
    ) {
        List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
        
        for (Nurture_Track_Configuration__c record : nurtureTrackConfigMap.values()) {
            if (record.Status__c == 'Active' &&
                record.Lead_Score_Threshold__c !=NULL)
            {
                nurtureList.add(record);
            }
        }       
        return nurtureList;
    }

    public List<Nurture_Track_Configuration__c> getNurtureTrackByCadenceNames(
        Set<String> cadenceNames,
        String accessLevel
    ) {
        List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
        
        for (Nurture_Track_Configuration__c record : nurtureTrackConfigMap.values()) {
            if (cadenceNames.contains(record.Cadence_Name__c)){
                nurtureList.add(record);
            }
        }       
        return nurtureList;
    }  
    
    public List<Nurture_Track_Configuration__c> getNurtureTrack(
        String fieldsToQuery,
        String accessLevel
    ) {
        List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
        
        for (Nurture_Track_Configuration__c record : nurtureTrackConfigMap.values()) {
            if (record.Status__c == 'Active')
            {
                nurtureList.add(record);
            }
        }       
        return nurtureList;
    }
} 