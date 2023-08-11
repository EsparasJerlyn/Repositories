/**
 * @description Mock DAO Class for hed__Program_Enrollment__c Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 08, 2023       |DEPP-5760               | Created File                        |
 */
@isTest
public inherited sharing class ProgramEnrollmentsDAOMock extends DmlBaseMock implements IProgramEnrollmentsDAO{
    public Map<Id, hed__Program_Enrollment__c> programEnrollmentMap;

    public ProgramEnrollmentsDAOMock() {
        super(new Map<Id, hed__Program_Enrollment__c>(), Schema.hed__Program_Enrollment__c.SObjectType);
        this.programEnrollmentMap = (Map<Id, hed__Program_Enrollment__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return hed__Program_Enrollment__c.SObjectType;
    }

    public List<hed__Program_Enrollment__c> getProgramEnrollmentsById(Set<Id> programEnrollmentIds, String accessLevel) {
        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();

        for (hed__Program_Enrollment__c record : programEnrollmentMap.values()) {
            if (programEnrollmentIds.contains(record.Id)) {
                programEnrollmentList.add(record);
            }
        }

        return programEnrollmentList;
    }
}