/**
 * @description Mock DAO Class for Opportunity Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | May 04, 2023          | DEPP-5587              | Created file
 *    | alexander.cadalin              | May 17, 2023          | DEPP-5594              | added methods
 *    | kenneth.f.alsay                | June 19, 2023         | DEPP-5434,5399         | added getRecordsByStartingName method
 */
@isTest
public inherited sharing class OpportunitiesDAOMock extends DmlBaseMock implements IOpportunitiesDAO {
    public Map<Id, Opportunity> opportunitiesMap;

    public Schema.SObjectType getSObjectType() {
        return Opportunity.SObjectType;
    }

    public OpportunitiesDAOMock() {
        super(new Map<Id, Opportunity>(), Schema.Opportunity.SObjectType);
        this.opportunitiesMap = (Map<Id, Opportunity>) super.records;
    }

    public List<Opportunity> getRecordsSortByOpportunityCodeAsc() {
        return opportunitiesMap.values();
    }

    public List<Opportunity> getRecordsWithLikeOpportunityCodeSortAsc(String codeIsLike) {
        return opportunitiesMap.values();
    }

    public List<Opportunity> getRecordsBySetName(Set<String> names) {
        List<Opportunity> opportunityList = new List<Opportunity>();
        for (Opportunity record : opportunitiesMap.values()) {
            if (names.contains(record.Name)) {
                opportunityList.add(record);
            }
        }
        return opportunityList;
    }

    public List<Opportunity> getRecordsLikeName(
        String name,
        boolean wildCardBeforeName,
        String wildCard
    ) {
        List<Opportunity> opportunityList = new List<Opportunity>();
        if (wildCardBeforeName) {
            for (Opportunity record : opportunitiesMap.values()) {
                if ((record.Name).endsWith(name)) {
                    opportunityList.add(record);
                }
            }
        } else {
            for (Opportunity record : opportunitiesMap.values()) {
                if ((record.Name).startsWith(name)) {
                    opportunityList.add(record);
                }
            }
        }
        return opportunityList;
    }

    public List<Opportunity> getRecordsByStageName(String stageName) {
        List<Opportunity> opportunityList = new List<Opportunity>();
        for (Opportunity record : opportunitiesMap.values()) {
            if (record.StageName == stageName) {
                opportunityList.add(record);
            }
        }
        return opportunityList;
    }

    public List<Opportunity> getRecordsBySetIds(Set<Id> ids) {
        List<Opportunity> opportunityList = new List<Opportunity>();
        for (Opportunity record : opportunitiesMap.values()) {
            if (ids.contains(record.Id)) {
                opportunityList.add(record);
            }
        }
        return opportunityList;
    }

    public List<Opportunity> getOpportunityByAccountIds(
        Set<Id> accountIds,
        String accessLevel
    ) {
        List<Opportunity> opportunityList = new List<Opportunity>();

        for (Opportunity record : opportunitiesMap.values()) {
            if (accountIds.contains(record.AccountId)) {
                opportunityList.add(record);
            }
        }

        return opportunityList;
    }

    public List<Opportunity> getOpportunityByRecordTypeIds(
        Set<Id> recordTypeIds,
        AccessLevel accessLevel
    ) {
        List<Opportunity> opportunityList = new List<Opportunity>();

        if(!recordTypeIds.isEmpty()){
            for (Opportunity record : opportunitiesMap.values()) {
                if (recordTypeIds.contains(record.RecordTypeId)) {
                    opportunityList.add(record);
                }
            }
        }

        return opportunityList;
    }
}
