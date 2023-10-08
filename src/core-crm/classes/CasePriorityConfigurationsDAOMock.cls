/**
 * @description Mock DAO Class for Case Priority Configuration Object
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
public inherited sharing class CasePriorityConfigurationsDAOMock extends DmlBaseMock implements ICasePriorityConfigurationsDAO{
    public Map<Id, Case_Priority_Configuration__c> casePrioConfigMap;

    public CasePriorityConfigurationsDAOMock() {
        super(new Map<Id, Case_Priority_Configuration__c>(), Schema.Case_Priority_Configuration__c.SObjectType);
        this.casePrioConfigMap = (Map<Id, Case_Priority_Configuration__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return Case_Priority_Configuration__c.SObjectType;
    }

    public List<Case_Priority_Configuration__c> getActiveCasePriorityConfigurations(
        AccessLevel accessLevel){
        return casePrioConfigMap.values();
    }
}