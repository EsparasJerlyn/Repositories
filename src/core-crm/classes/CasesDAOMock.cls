/**
 * @description Mock DAO Class for Case Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                              |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------|
      | arsenio.jr.dayrit              | September 11, 2023    | DEPP-5652              | Created File                                |
      | arsenio.jr.dayrit              | September 26, 2023    | DEPP-6720              | added new method getCasesBySuppliedPhone    |
      | neil.s.h.lesidan               | September 20, 2023    | DEPP-6478              | Added getCaseBySuppliedEmail                |
 */
@isTest
public inherited sharing class CasesDAOMock extends DmlBaseMock implements ICasesDAO {

    public Map<Id, Case> caseMap;

    public CasesDAOMock() {
        super(new Map<Id, Case>(), Schema.Case.SObjectType);
        this.caseMap = (Map<Id, Case>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return Case.SObjectType;
    }

    public List<Case> getCasesByContactIds(
        Set<Id> contactIds,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();

        for (Case record : caseMap.values()) {
            if (contactIds.contains(record.ContactId)) {
                caseList.add(record);
            }
        }

        return caseList;
    }

    public List<Case> getCasesByLeadIds(
        Set<Id> leadIds,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();

        for (Case record : caseMap.values()) {
            if (leadIds.contains(record.Lead__c)) {
                caseList.add(record);
            }
        }

        return caseList;
    }

    public List<Case> getCasesByContactOrLeadIds(
        Set<Id> contactOrLeadIds,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();

        for (Case record : caseMap.values()) {
            if (
                contactOrLeadIds.contains(record.Lead__c) ||
                contactOrLeadIds.contains(record.ContactId)
            ) {
                caseList.add(record);
            }
        }

        return caseList;
    }

    public List<Case> getCasesBySuppliedPhone(
        Set<String> suppliedMobile,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();

        for (Case record : caseMap.values()) {
            if (
                suppliedMobile.contains(record.SuppliedPhone)  
            ) {
                caseList.add(record);
            }
        }

        return caseList;
    }

    public List<Case> getCaseBySuppliedEmail(
        String suppliedEmail,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();

        for (Case record : caseMap.values()) {
            if (
                suppliedEmail == record.SuppliedEmail
            ) {
                caseList.add(record);
            }
        }

        return caseList;
    }

    public List<Case> getCasesByIds(
        Set<Id> caseIds,
        AccessLevel accessLevel
    ) {
        List<Case> caseList = new List<Case>();

        for (Case record : caseMap.values()) {
            if (
                caseIds.contains(record.Id)
            ) {
                caseList.add(record);
            }
        }

        return caseList;
    }
}