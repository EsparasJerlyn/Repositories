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
        //Collate all criteria checked in every Criteria fields
        soql = 
            whereClauseCheckerForProgramEnrollmentCriteria(programEnrollmentCriteria) + 
            whereClauseCheckerForContactCriteria(contactCriteria); 
        
        if(soql != '') {
            soql = 'WHERE ' + soql.trim().removeStart('AND').trim();
        }
    
        return soql; 
    }   

    //Checks to ensure fields have values
    private String whereClauseCheckerForProgramEnrollmentCriteria(ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria){
        String soql = '';

        if(programEnrollmentCriteria.getAcademicStatus() != null){
            soql += 'AND Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStage() != null){
            soql += 'AND Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStatus() != null){
            soql += 'AND Enrollment_Status__c IN(' + formatStringSetForWhereClause(programEnrollmentCriteria.getEnrollmentStatus()) + ') ';
        }
        if(programEnrollmentCriteria.getCategoryType() != null){
            soql += 'AND hed__Program_Plan__r.Category_Type__c  = \'' + programEnrollmentCriteria.getCategoryType() + '\' ';
        }
        
        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForContactCriteria(ContactsDAO.Criteria contactCriteria){
        String soql = '';

        if(contactCriteria.getCitizenshipStatus() != null){
            soql += 'AND hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' ' ;
        }
        if(contactCriteria.getIsQUTStudent() != null){
            soql += 'AND hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' ' ;
        }
        if(contactCriteria.getRecordType() != null){
            soql += 'AND hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' ' ;
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
                record.Academic_Status__c == programEnrollmentCriteria.getAcademicStatus() &&
                record.Enrollment_Stage__c == programEnrollmentCriteria.getEnrollmentStage() &&
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
    
    private String formatStringSetForWhereClause(Set<String> stringSet){
        List<String> formattedStrings = new List<String>();
        for(String lineString : stringSet){
            formattedStrings.add('\'' + lineString + '\'');
        }
        return String.join(formattedStrings, ', ');
    }
}