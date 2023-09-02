/**
 * @description Mock DAO Class for hed__Term__c Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 10, 2023       |DEPP-5760               | Created File                        |
 */
@isTest
public inherited sharing class TermsDAOMock extends DmlBaseMock implements ITermsDAO{
    public Map<Id, hed__Term__c> termMap;

    public TermsDAOMock() {
        super(new Map<Id, hed__Term__c>(), Schema.hed__Term__c.SObjectType);
        this.termMap = (Map<Id, hed__Term__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return hed__Term__c.SObjectType;
    }

    public List<hed__Term__c> getTermRecordByApplication(
        Set<Id> termsIds,
        String accessLevel
    ) {
        List<hed__Term__c> termList = new List<hed__Term__c>();

        for (hed__Term__c record : termMap.values()) {
            if (termsIds.contains(record.Id)) {
                termList.add(record);
            }
        }

        return termList;
    }
}