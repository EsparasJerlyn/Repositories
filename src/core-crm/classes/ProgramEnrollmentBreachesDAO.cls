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

public inherited sharing class ProgramEnrollmentBreachesDAO extends DmlBase implements IProgramEnrollmentBreachesDAO {
    public static final String NULL_STATUS = '';
    public static final String ACTIVE_BREACH_STATUS = 'Active Breach';
    public static final String WAIT_FOR_STUDENT_ACTION_STATUS = 'Wait For Student Action';

    public static final Set<String> STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH = new Set<String>{
        ACTIVE_BREACH_STATUS,
        WAIT_FOR_STUDENT_ACTION_STATUS
    };   

    public static IProgramEnrollmentBreachesDAO newInstance() {
        return (IProgramEnrollmentBreachesDAO) ImplementationSelector.DAO.newInstance(
            Program_Enrollment_Breach__c.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return 	Program_Enrollment_Breach__c.SObjectType;
    }

    public String getWhereClauseByCriteria(
        ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){ 
        String soql = '';
        //Collate all criteria checked in every Criteria fields
        soql = 
            whereClauseCheckerForProgramEnrollmentBreach(programEnrollmentBreachCriteria) + 
            whereClauseCheckerForProgramEnrollmentCriteria(programEnrollmentCriteria) + 
            whereClauseCheckerForContactCriteria(contactCriteria); 
        
        if(soql != '') {
            soql = 'WHERE ' + soql.trim().removeStart('AND').trim();
        }
        
        /*temporarily commented out*/
        // if(programEnrollmentBreachCriteria.getKeyDateOffset() != null && programEnrollmentBreachCriteria.getExecutionDate() != null){
        //     Date lowerKeyDateOffSetBoundary = programEnrollmentBreachCriteria.getExecutionDate().addDays(-programEnrollmentBreachCriteria.getKeyDateOffset());
        //     Date upperKeyDateOffSetBoundary = programEnrollmentBreachCriteria.getExecutionDate().addDays(programEnrollmentBreachCriteria.getKeyDateOffset());
        //     soql = soql + 'AND Breach_Date__c <= ' + lowerKeyDateOffSetBoundary + ' ' + 'AND Breach_Date__c >= ' + upperKeyDateOffSetBoundary ;
        // }

        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForProgramEnrollmentBreach(ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria){
        
        String soql = '';
        if(programEnrollmentBreachCriteria.getBreachStatus() != null){
            soql += 'AND Breach_Status__c IN(' + formatStringSetForWhereClause(programEnrollmentBreachCriteria.getBreachStatus()) + ') ' ;
        }
        if(programEnrollmentBreachCriteria.getBreach() != null){
            soql += 'AND Breach_Name__c = \'' + programEnrollmentBreachCriteria.getBreach() + '\' ' ;
        }

        return soql;
    }

    private String formatStringSetForWhereClause(Set<String> stringSet){
        List<String> formattedStrings = new List<String>();
        for(String lineString : stringSet){
            formattedStrings.add('\'' + lineString + '\'');
        }
        return String.join(formattedStrings, ', ');
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForProgramEnrollmentCriteria(ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria){
        String soql = '';

        if(programEnrollmentCriteria.academicStatus != null){
            soql += 'AND Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' ';
        }
        if(programEnrollmentCriteria.enrollmentStage != null){
            soql += 'AND Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' ';
        }
        if(programEnrollmentCriteria.enrollmentStatus != null){
            soql += 'AND Program_Enrollment__r.Enrollment_Status__c IN (' + formatSetForWhereClause(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH) + ') ';
        }
        if(programEnrollmentCriteria.categoryType != null){
            soql += 'AND Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  = \'' + programEnrollmentCriteria.categoryType + '\' ';
        }
        
        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForContactCriteria(ContactsDAO.Criteria contactCriteria){
        String soql = '';

        if(contactCriteria.getCitizenshipStatus() != null){
            soql += 'AND Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' ';
        }
        if(contactCriteria.getIsQUTStudent() != null){
            soql += 'AND Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' ' ;
        }
        if(contactCriteria.getRecordType() != null){
            soql += 'AND Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\'';
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

    public List<Program_Enrollment_Breach__c> findByCriteria(
        ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        return Database.query(getQueryByCriteria(programEnrollmentBreachCriteria, programEnrollmentCriteria, contactCriteria));
    }

    public String getQueryByCriteria(
        ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT Id, Breach_Name__c, Breach_Status__c FROM Program_Enrollment_Breach__c ' + getWhereClauseByCriteria(programEnrollmentBreachCriteria, programEnrollmentCriteria, contactCriteria);
    }

    /**
     * @Description:Wrapper Class that represents the Criteria for outreach Case.
     */
    public class Criteria {
        private Id breach;
        private Set<String> breachStatus;
        private Integer keyDateOffset;    
        private Date executionDate;

        public Id isEmpty() {
            return breach == null && breachStatus == null && keyDateOffset == null && executionDate == null;
        }

        public void getBreach(){
            return breach;
        }

        public void setBreach(Id breach){
            this.breach = breach;
        }

        public void getBreachStatus(){
            return breachStatus;
        }

        public void setBreachStatus(Set<String> breachStatus){
            this.breachStatus = breachStatus;
        }

        public void getKeyDateOffset(){
            return keyDateOffset;
        }

        public void setKeyDateOffset(Integer keyDateOffset){
            this.keyDateOffset = keyDateOffset;
        }

        public void getExecutionDate(){
            return executionDate;
        }

        public void setExecutionDate(Date executionDate){
            this.executionDate = executionDate;
        }
    }

    private String formatSetForWhereClause(Set<String> statusSet){
        List<String> formattedStatus = new List<String>();
        for(String status : statusSet){
            formattedStatus.add('\'' + status + '\'');
        }
        return String.join(formattedStatus, ', ');
    }
}
