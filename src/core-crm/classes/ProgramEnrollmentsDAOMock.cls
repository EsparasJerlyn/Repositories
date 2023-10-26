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

    public List<hed__Program_Enrollment__c> getProgramEnrollmentsByContactIds(Set<Id> contactIds, String accessLevel) {
        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();

        for (hed__Program_Enrollment__c record : programEnrollmentMap.values()) {
            if (contactIds.contains(record.hed__Contact__c)) {
                programEnrollmentList.add(record);
            }
        }

        return programEnrollmentList;
    }

    public List<hed__Program_Enrollment__c> getProgramEnrollmentsByContactIdAndStatus(Set<Id> contactIds, String status, AccessLevel accessLevel) {
        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();

        for (hed__Program_Enrollment__c record : programEnrollmentMap.values()) {
            if (contactIds.contains(record.hed__Contact__c) && status == record.Enrollment_Status__c) {
                programEnrollmentList.add(record);
            }
        }

        return programEnrollmentList;
    }

    public List<hed__Program_Enrollment__c> getAllProgramEnrollmentsByContactId(Set<Id> contactIds, AccessLevel accessLevel) {
        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();

        for (hed__Program_Enrollment__c record : programEnrollmentMap.values()) {
            if (contactIds.contains(record.hed__Contact__c)) {
                programEnrollmentList.add(record);
            }
        }

        return programEnrollmentList;
    }
    
    
}