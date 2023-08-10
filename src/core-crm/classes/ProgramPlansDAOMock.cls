/**
 * @description Mock DAO Class for hed__Program_Plan__c Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 10, 2023       |DEPP-5760               | Created File                        |
 */
@isTest
public inherited sharing class ProgramPlansDAOMock extends DmlBaseMock implements IProgramPlansDAO{
    public Map<Id, hed__Program_Plan__c> programPlanMap;

    public ProgramPlansDAOMock() {
        super(new Map<Id, hed__Program_Plan__c>(), Schema.hed__Program_Plan__c.SObjectType);
        this.programPlanMap = (Map<Id, hed__Program_Plan__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return hed__Program_Plan__c.SObjectType;
    }
}