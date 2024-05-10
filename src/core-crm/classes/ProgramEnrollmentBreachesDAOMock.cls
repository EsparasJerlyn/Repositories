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
@isTest
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
        String soql = '';
        soql = whereClauseCheckerForProgramEnrollmentBreachCriteria(programEnrollmentBreachCriteria) + whereClauseCheckerForProgramEnrollmentBreachCriteria(programEnrollmentBreachCriteria) + whereClauseCheckerForContactCriteria(contactCriteria);
         
        if(soql != '') {
            soql = 'WHERE ' + soql.trim().removeStart('AND').trim();
        }
        
        /*temporarily commented out*/
        // if(programEnrollmentBreachCriteria.keyDateOffset != null && programEnrollmentBreachCriteria.getExecutionDate() != null){
        //     Date lowerKeyDateOffSetBoundary = programEnrollmentBreachCriteria.getExecutionDate().addDays(-programEnrollmentBreachCriteria.keyDateOffset);
        //     Date upperKeyDateOffSetBoundary = programEnrollmentBreachCriteria.getExecutionDate().addDays(programEnrollmentBreachCriteria.keyDateOffset);
        //     soql = soql + 'AND Breach_Date__c <= ' + lowerKeyDateOffSetBoundary + ' ' + 'AND Breach_Date__c >= ' + upperKeyDateOffSetBoundary ;
        // }

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
        ContactsDAO.Criteria contactCriteria,
        AccessLevel accessLevel
    ) {
        List<Program_Enrollment_Breach__c> programEnrollmentBreachList = new List<Program_Enrollment_Breach__c>();

        for (Program_Enrollment_Breach__c record : programEnrollmentBreachMap.values()) {
            if(
                record.Breach_Name__c == programEnrollmentBreachCriteria.getBreach() &&
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

    //Checks to ensure fields have values
    private String whereClauseCheckerForProgramEnrollmentBreachCriteria(ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria){
        
        String soql = '';

        if(programEnrollmentBreachCriteria.getBreachStatus() != null){
            soql += 'AND Breach_Status__c IN(' + programEnrollmentBreachCriteria.getBreachStatus() + ') ' ;
        }
        if(programEnrollmentBreachCriteria.getBreach() != null){
            soql += 'AND Breach_Name__c = \'' + programEnrollmentBreachCriteria.getBreach() + '\' ' ;
        }

        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForProgramEnrollmentCriteria(ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria){
        String soql = '';

        if(programEnrollmentCriteria.getAcademicStatus() != null){
            soql += 'AND Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStage() != null){
            soql += 'AND Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStatus() != null){
            soql += 'AND Program_Enrollment__r.Enrollment_Status__c IN (' + formatSetForWhereClause(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH) + ') ';
        }
        if(programEnrollmentCriteria.getCategoryType() != null){
            soql += 'AND Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  = \'' + programEnrollmentCriteria.getCategoryType() + '\' ';
        }
        
        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForContactCriteria(ContactsDAO.Criteria contactCriteria){
        String soql = '';

        if(contactCriteria.getCitizenshipStatus() != null){
            soql += 'AND Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' ' ;
        }
        if(contactCriteria.getIsQUTStudent() != null){
            soql += 'AND Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' ' ;
        }
        if(contactCriteria.getRecordType() != null){
            soql += 'AND Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' ' ;
        }

        return soql;
    }

    private String formatSetForWhereClause(Set<String> statusSet){
        List<String> formattedStatus = new List<String>();
        for(String status : statusSet){
            formattedStatus.add('\'' + status + '\'');
        }
        return String.join(formattedStatus, ', ');
    }

}