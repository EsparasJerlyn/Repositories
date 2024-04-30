/**
 * @description Mock DAO Class for Completed Cadence Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6107              | Created file                                                |
      | roy.nino.s.regala              | Aug 9, 2023           | DEPP-5677              | added new query                                             |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | updated method getCompletedCadenceByTargetIdsAndCadenceName |
 */
@isTest
public inherited sharing class CompletedCadencesDAOMock extends DmlBaseMock implements ICompletedCadencesDAO {
    public Map<Id, Completed_Cadence__c> completedCadencesMap;

    public Schema.SObjectType getSObjectType() {
        return Completed_Cadence__c.SObjectType;
    }

    public CompletedCadencesDAOMock() {
        super(new Map<Id, Completed_Cadence__c>(), Schema.Completed_Cadence__c.SObjectType);
        this.completedCadencesMap = (Map<Id, Completed_Cadence__c>) super.records;
    }

    public List<Completed_Cadence__c> getCompletedCadenceByContactIds(
        Set<Id> contactIds,
        String accessLevel
    ) {
        List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();

        for (Completed_Cadence__c record : completedCadencesMap.values()) {
            if (contactIds.contains(record.Contact__c)) {
                completedCadenceList.add(record);
            }
        }
        return completedCadenceList;
    }

    public List<Completed_Cadence__c> getCompletedCadenceByLeadIds(
        Set<Id> leadIds,
        String accessLevel
    ) {
        List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();

        for (Completed_Cadence__c record : completedCadencesMap.values()) {
            if (leadIds.contains(record.Lead__c)) {
                completedCadenceList.add(record);
            }
        }
        return completedCadenceList;
    }

    public List<Completed_Cadence__c> getCompletedCadenceByTargetIdsAndCadenceName(
        Set<String> targetIds,
        Set<String> cadenceNames,
        String accessLevel
    ) {
        List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();

        for (Completed_Cadence__c record : completedCadencesMap.values()) {
            if (targetIds.contains(record.Lead__c) || targetIds.contains(record.Contact__c)) {
                completedCadenceList.add(record);
            }
        }
        return completedCadenceList;
    }

    public List<Completed_Cadence__c> getCompletedCadenceByTargetIds(
        Set<Id> targetIds,
        Set<String> cadenceNames,
        String accessLevel
    ) {
        List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();

        for (Completed_Cadence__c record : completedCadencesMap.values()) {
            if (targetIds.contains(record.Lead__c) || targetIds.contains(record.Contact__c)) {
                completedCadenceList.add(record);
            }
        }
        return completedCadenceList;
    }

    public List<Completed_Cadence__c> findByCriteria(
        CompletedCadencesDAO.Criteria completedCadenceCriteria, 
        ContactsDAO.Criteria contactCriteria
    ) {
        List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();

        for (Completed_Cadence__c record : completedCadencesMap.values()) {
            if(
                record.Cadence_Name__c == completedCadenceCriteria.completedCadence &&
                record.Completed_Cadence_Status__c == completedCadenceCriteria.status)
            {
                completedCadenceList.add(record);
            }
        }
        return completedCadenceList;
    }
} 
