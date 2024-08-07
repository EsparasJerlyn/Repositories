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
      | julie.jane.alegre              | May 06, 2024          | DEPP-8490              | Add access level on findByCriteria method                   |
      | eugene.andrew.abuan            | August 05, 2024       | DEPP-8255              | Added getCompletedCadencebyRecordId                         |
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

    public String getWhereClauseByCriteria(
        CompletedCadencesDAO.Criteria completedCadenceCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        String soql = 'WHERE Cadence_Name__c = \'' + completedCadenceCriteria.getCompletedCadence() + '\' ' +
            ' AND Completed_Cadence_Status__c = \'' + completedCadenceCriteria.getStatus() + '\' ' +
            ' AND Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' ' +
            ' AND Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' ' +
            ' AND Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' '
            + 'AND Contact__r.Id IN ('+ DynamicQueryService.formatStringSetForWhereClause(contactCriteria.getContactIdSet()) + ')';
        
        if(completedCadenceCriteria.getCompletedCadanceDateFrom() != null && completedCadenceCriteria.getCompletedCadanceDateTo() != null ){
            soql = soql + ' AND LastModifiedDate <= ' + DynamicQueryService.convertDatetoDateTimeGMTString(completedCadenceCriteria.getCompletedCadanceDateFrom()) + ' ' + 'AND LastModifiedDate >= ' + DynamicQueryService.convertDatetoDateTimeGMTString(completedCadenceCriteria.getCompletedCadanceDateTo());
        }
        
        return soql;
    }

    public String getContactQueryByCriteria(
         CompletedCadencesDAO.Criteria completedCadenceCriteria, 
         ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT Contact__c FROM Completed_Cadence__c ' + getWhereClauseByCriteria(completedCadenceCriteria, contactCriteria);
    }

    public String getQueryByCriteria(
        CompletedCadencesDAO.Criteria completedCadenceCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT Id, Contact__c, Cadence_Name__c, LastModifiedDate FROM Completed_Cadence__c ' + getWhereClauseByCriteria(completedCadenceCriteria, contactCriteria);
    }

    public List<Completed_Cadence__c> findByCriteria(
        CompletedCadencesDAO.Criteria completedCadenceCriteria, 
        ContactsDAO.Criteria contactCriteria,
        AccessLevel AccessLevel
    ) {
        List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
        for (Completed_Cadence__c record : completedCadencesMap.values()) {
            if(
                record.Cadence_Name__c == completedCadenceCriteria.getCompletedCadence() &&
                record.Completed_Cadence_Status__c == completedCadenceCriteria.getStatus() 
            )
            {
                completedCadenceList.add(record);
            }
        }
        return completedCadenceList;
    }

    public List<Completed_Cadence__c> getCompletedCadencebyRecordId(
        Set<Id> completedCadenceIdSet,
        AccessLevel accessLevel
    ){
        List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
        for (Completed_Cadence__c record : completedCadencesMap.values()) {
            if(completedCadenceIdSet.contains(record.Id)){
                completedCadenceList.add(record);
            }
        }
        return completedCadenceList;    
    }

    public List<Completed_Cadence__c> getCompletedCadenceByStatus(
        String status,
        AccessLevel accessLevel
    ){
        List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
        for (Completed_Cadence__c record : completedCadencesMap.values()) {
            if(record.Completed_Cadence_Status__c == status){
                completedCadenceList.add(record);
            }
        }
        return completedCadenceList;    
    }
} 
