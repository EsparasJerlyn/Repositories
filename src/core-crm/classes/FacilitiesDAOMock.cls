/**
 * @description Mock DAO Class for hed__Facility__c Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 10, 2023       |DEPP-5760               | Created File                        |
 */
@isTest
public inherited sharing class FacilitiesDAOMock extends DmlBaseMock implements IFacilitiesDAO{
    public Map<Id, hed__Facility__c> facilityMap;

    public FacilitiesDAOMock() {
        super(new Map<Id, hed__Facility__c>(), Schema.hed__Facility__c.SObjectType);
        this.facilityMap = (Map<Id, hed__Facility__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return hed__Facility__c.SObjectType;
    }
}