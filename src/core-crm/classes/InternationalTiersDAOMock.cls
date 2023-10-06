/**
 * @description Mock DAO Class for InternationalTiers Object
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Octover 5, 2023       | DEPP-6426              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public inherited sharing class InternationalTiersDAOMock extends DmlBaseMock implements IInternationalTiersDAO{
    public Map<Id, International_Tier__c> internationalTiersMap;

    public InternationalTiersDAOMock() {
        super(new Map<Id, International_Tier__c>(), Schema.International_Tier__c.SObjectType);
        this.internationalTiersMap = (Map<Id, International_Tier__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return International_Tier__c.SObjectType;
    }

    public List<International_Tier__c> getActiveInternationalTiers(
        AccessLevel accessLevel){
        return internationalTiersMap.values();
    }
}