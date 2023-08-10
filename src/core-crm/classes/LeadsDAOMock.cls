/**
 * @description Mock DAO Class for Lead Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                 |
      | mark.j.mahilum                 | June 26, 2023         | DEPP-5846              | Added new method             |
      | roy.nino.s.regala              | Aug 09, 2023          | DEPP-5677              | Added new method             |
 */
@isTest
public inherited sharing class LeadsDAOMock extends DmlBaseMock implements ILeadsDAO {
    public Map<Id, Lead> leadsMap;

    public Schema.SObjectType getSObjectType() {
        return Lead.SObjectType;
    }

    public LeadsDAOMock() {
        super(new Map<Id, Lead>(), Schema.Lead.SObjectType);
        this.leadsMap = (Map<Id, Lead>) super.records;
    }

    public List<Lead> getExistingUnconvertedLeadsByEmail(
        Set<String> emailsToMatch,
        Set<Id> excludedLeadsRecordsSet,
        String accessLevel
    ) {
        List<Lead> leadList = new List<Lead>();

        for (Lead record : leadsMap.values()) {
            if (
                (!excludedLeadsRecordsSet.contains(record.Id) &&
                (emailsToMatch.contains(record.Email) ||
                emailsToMatch.contains(record.Work_Email__c)))
            ) {
                leadList.add(record);
            }
        }

        return leadList;
    }

    public List<Lead> getLeadsWithLimit(Integer recordsCount) {
        List<Lead> leadList = new List<Lead>();

        for (Lead record : leadsMap.values()) {
            leadList.add(record);

            if (leadList.size() == recordsCount) {
                break;
            }
        }

        return leadList;
    }

    public List<Lead> getExistingUnconvertedLeads(Set<String> emailsToMatch, String accessLevel) {
        List<Lead> leadList = new List<Lead>();

        for (Lead record : leadsMap.values()) {
            if (
                (emailsToMatch.contains(record.Email) ||
                emailsToMatch.contains(record.Work_Email__c))
            ) {
                leadList.add(record);
            }
        }

        return leadList;
    }

    public List<Lead> getLearnerLeadsByCalculatedCadences(Set<String> calculatedCadences) {
        List<Lead> leadList = new List<Lead>();

        for (Lead record : leadsMap.values()) {
            if (calculatedCadences.contains(record.Calculated_Cadence__c)) {
                leadList.add(record);
            }
        }

        return leadList;
    }
}
