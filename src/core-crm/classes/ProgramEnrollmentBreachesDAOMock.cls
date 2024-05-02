/**
 * @description DAO Class for Program_Enrollment_Breach__c Object. Contains soql and constants related to the Program_Enrollment_Breach__c object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | julie.jane.alegre              | April 29, 2024        | DEPP-8041              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */

 public inherited sharing class ProgramEnrollmentBreachesDAOMock extends DmlBaseMock implements IProgramEnrollmentBreachesDAO {
    public Map<Id, Program_Enrollment_Breach__c> programEnrollmentBreachMap;

    public Schema.SObjectType getSObjectType() {
        return Program_Enrollment_Breach__c.SObjectType;
    }

    public ProgramEnrollmentBreachesDAOMock() {
        super(new Map<Id, Program_Enrollment_Breach__c>(), Schema.Program_Enrollment_Breach__c.SObjectType);
        this.programEnrollmentBreachMap = (Map<Id, Program_Enrollment_Breach__c>) super.records;
    }

    public String getWhereClauseByCriteria(
        ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){ 
        String soql = 'WHERE Breach_Name__c = \'' + programEnrollmentBreachCriteria.breach + '\' ' +
        ' AND Breach_Status__c = \'' + programEnrollmentBreachCriteria.breachStatus + '\' ' +
        ' AND Program_Enrollment__r.Academic_Status__c  = \'' + programEnrollmentCriteria.academicStatus + '\' ' +
        ' AND Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  = \'' + programEnrollmentCriteria.categoryType + '\' ' +
        ' AND Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.citizenshipStatus + '\' ' +
        ' AND Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.isQUTStudent + ' ' +
        ' AND Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.recordType + '\'';

        if(programEnrollmentBreachCriteria.keyDateOffset != null && programEnrollmentBreachCriteria.executionDate != null){
            Date lowerKeyDateOffSetBoundary = programEnrollmentBreachCriteria.executionDate.addDays(-programEnrollmentBreachCriteria.keyDateOffset);
            Date upperKeyDateOffSetBoundary = programEnrollmentBreachCriteria.executionDate.addDays(programEnrollmentBreachCriteria.keyDateOffset);
            soql = soql + 'AND Breach_Date__c <= ' + lowerKeyDateOffSetBoundary + ' ' + 'AND Breach_Date__c >= ' + upperKeyDateOffSetBoundary ;
        }

        return soql;
    }

    public String getContactQueryByCriteria(
        ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT Program_Enrollment__r.hed__Contact__c FROM Program_Enrollment_Breach__c ' + getWhereClauseByCriteria(programEnrollmentBreachCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public String getQueryByCriteria(
        ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT Id, Breach_Name__c, Breach_Status__c FROM Program_Enrollment_Breach__c ' + getWhereClauseByCriteria(programEnrollmentBreachCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public List<Program_Enrollment_Breach__c> findByCriteria(
        ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ) {
        List<Program_Enrollment_Breach__c> programEnrollmentBreachList = new List<Program_Enrollment_Breach__c>();
        Date lowerKeyDateOffSetBoundary = programEnrollmentBreachCriteria.executionDate.addDays(-programEnrollmentBreachCriteria.keyDateOffset);
        Date upperKeyDateOffSetBoundary = programEnrollmentBreachCriteria.executionDate.addDays(programEnrollmentBreachCriteria.keyDateOffset);

        for (Program_Enrollment_Breach__c record : programEnrollmentBreachMap.values()) {
            if(
                record.Breach_Name__c == programEnrollmentBreachCriteria.breach &&
                record.Breach_Date__c <= lowerKeyDateOffSetBoundary && 
                record.Breach_Date__c >= upperKeyDateOffSetBoundary && 
                (
                    record.Breach_Status__c == ProgramEnrollmentBreachesDAO.ACTIVE_BREACH_STATUS ||
                    record.Breach_Status__c == ProgramEnrollmentBreachesDAO.WAIT_FOR_STUDENT_ACTION_STATUS
                )
            )
            {
                programEnrollmentBreachList.add(record);
            }
        }
        return programEnrollmentBreachList;
    }
}
