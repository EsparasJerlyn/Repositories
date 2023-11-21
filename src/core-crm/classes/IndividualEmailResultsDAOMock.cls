/**
 * @description Mock DAO Class for et4ae5__IndividualEmailResult__c Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                              |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------|
 *    | eccarius.munoz                 | October 26, 2023      | DEPP-5866              | created file                                |
 */

@isTest
public inherited sharing class IndividualEmailResultsDAOMock extends DmlBaseMock implements IIndividualEmailResultsDAO{
    public Map<Id, et4ae5__IndividualEmailResult__c> indivEmailMap;

    public IndividualEmailResultsDAOMock() {
        super(new Map<Id, et4ae5__IndividualEmailResult__c>(), Schema.et4ae5__IndividualEmailResult__c.SObjectType);
        this.indivEmailMap = (Map<Id, et4ae5__IndividualEmailResult__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return et4ae5__IndividualEmailResult__c.SObjectType;
    }

    public List<et4ae5__IndividualEmailResult__c> getIndivEmailResultsByContactOrLeadIds(
        Set<Id> contactLeadIds,
        AccessLevel accessLevel
    ) {
        List<et4ae5__IndividualEmailResult__c> indivEmailList = new List<et4ae5__IndividualEmailResult__c>();

        for (et4ae5__IndividualEmailResult__c record : indivEmailMap.values()) {
            if (contactLeadIds.contains(record.et4ae5__Contact__c) || contactLeadIds.contains(record.et4ae5__Lead__c)) {
                indivEmailList.add(record);
            }
        }

        return indivEmailList;
    }

    public Database.QueryLocator queryLocatorGetIndivEmailResultsByContactOrLeadIds(
        Set<Id> recordIds
    ){
        return null;
    }
}