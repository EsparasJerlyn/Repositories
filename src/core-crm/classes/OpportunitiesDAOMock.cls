/**
 * @description Mock DAO Class for Opportunity Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 04, 2023          | DEPP-5587              | Created file
      | alexander.cadalin              | May 17, 2023          | DEPP-5594              | added methods
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
        for (Opportunity record: opportunitiesMap.values()){
            if(names.contains(record.Name)){
                opportunityList.add(record);
            }
        }
        return opportunityList;
    } 
}
