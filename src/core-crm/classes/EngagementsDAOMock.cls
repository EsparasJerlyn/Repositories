/**
 * @description Mock DAO Class for Engagements Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              |   May 16, 2023        | DEPP-5594              | Created file
      | alexnder.cadalin               |  May 17, 2023         | DEPP-5594              | added methods
 */
@isTest
public inherited sharing class EngagementsDAOMock extends DmlBaseMock implements IEngagementsDAO {
    public Map<Id, Engagement__c> engagementsMap;

    public Schema.SObjectType getSObjectType() {
        return Engagement__c.SObjectType;
    }

    public EngagementsDAOMock() {
        super(new Map<Id, Engagement__c>(), Schema.Engagement__c.SObjectType);
        this.engagementsMap = (Map<Id, Engagement__c>) super.records;
    }

    public List<Engagement__c> getRecordsSortByEngagementCodeAsc() {
        return engagementsMap.values();
    }

    public List<Engagement__c> getRecordsWithLikeEngagementCodeSortAsc(String codeIsLike) {
        return engagementsMap.values();
    }
}
