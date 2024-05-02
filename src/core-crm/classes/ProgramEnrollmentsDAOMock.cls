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
    
    public Database.QueryLocator queryLocatorGetAllProgramEnrollmentsByContactId(
        Set<Id> recordIds
    ){
        return null;
    }

    public String getWhereClauseByCriteria(
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        String soql = '';
        if(programEnrollmentCriteria.academicStatus != null){
            soql += 'AND Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' ' ;
        }
        if(programEnrollmentCriteria.enrollmentStage != null){
            soql += 'AND Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' ' ;
        }
        if(programEnrollmentCriteria.enrollmentStatus != null){
            soql += 'AND Enrollment_Status__c IN(' + programEnrollmentCriteria.enrollmentStatus + ') ' ;
        }
        if(contactCriteria.citizenshipStatus != null){
            soql += 'AND hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.citizenshipStatus + '\' ' ;
        }
        if(contactCriteria.isQUTStudent != null){
            soql += 'AND hed__Contact__r.QUT_Student__c = ' + contactCriteria.isQUTStudent + ' ' ;
        }
        if(contactCriteria.recordType != null){
            soql += 'AND hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.recordType + '\' ' ;
        }
        
        if(soql != '') {
            soql = 'WHERE ' + soql.trim().replaceFirst('^AND\\s*', '').trim();
        }
    
        return soql; 
    }

    public String getContactQueryByCriteria(
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT hed__Contact__c FROM hed__Program_Enrollment__c ' + getWhereClauseByCriteria(programEnrollmentCriteria, contactCriteria);
    }

    public String getQueryByCriteria(
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT ' + 
        ' Id, hed__Contact__c, Name,  ' +
        ' Academic_Status__c, Enrollment_Stage__c, Enrollment_Status__c, ' +
        ' hed__Contact__r.hed__Citizenship_Status__c, hed__Contact__r.QUT_Student__c, hed__Contact__r.RecordType.DeveloperName ' +
        ' FROM hed__Program_Enrollment__c ' +
        getWhereClauseByCriteria(programEnrollmentCriteria, contactCriteria);
    }

    public List<hed__Program_Enrollment__c> findByCriteria(
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ) {
        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();

        for (hed__Program_Enrollment__c record : programEnrollmentMap.values()) {
            if(
                record.Academic_Status__c == programEnrollmentCriteria.academicStatus &&
                record.Enrollment_Stage__c == programEnrollmentCriteria.enrollmentStage &&
                (
                    record.Enrollment_Status__c == ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED ||
                    record.Enrollment_Status__c == ProgramEnrollmentsDAO.ENROLLMENT_STATUS_LEAVE_OF_ABSENCE
                )
            )
            {
                programEnrollmentList.add(record);
            }
        }
        return programEnrollmentList;
    }
    
}