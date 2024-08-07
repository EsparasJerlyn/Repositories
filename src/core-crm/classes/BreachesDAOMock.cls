/**
 * @description Mock DAO Class for Breach Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | arsenio.jr.dayrit              | May 9, 2024           | DEPP-8487              | created file                               |
 */
@isTest
public inherited sharing class BreachesDAOMock extends DmlBaseMock implements IBreachesDAO {
    
    public Map<Id, Breach__c> breachMap;

    public BreachesDAOMock() {
        super(new Map<Id, Breach__c>(), Schema.Breach__c.SObjectType);
        this.breachMap = (Map<Id, Breach__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return Breach__c.SObjectType;
    }

}