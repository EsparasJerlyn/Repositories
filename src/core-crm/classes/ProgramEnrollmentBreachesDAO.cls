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
 *    | eugene.andrew.abuan            | May 20, 2024          | DEPP-8801              | Changes for Category Type                      |
 *    |                                |                       |                        |                                                |
 */

public inherited sharing class ProgramEnrollmentBreachesDAO extends DmlBase implements IProgramEnrollmentBreachesDAO {
    public static final String NULL_STATUS = '';
    public static final String ACTIVE_BREACH_STATUS = 'Active Breach';
    public static final String WAIT_FOR_STUDENT_ACTION_STATUS = 'Wait For Student Action';
    public static final String BREACH_RESOLVED_STATUS = 'Breach Resolved';

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
        if(programEnrollmentBreachCriteria.getBreachDateFrom() != null  ){
            soql = soql 
            + 'AND Breach_Date__c <= ' + DynamicQueryService.convertDatetoDateString(programEnrollmentBreachCriteria.getBreachDateFrom()) + ' ' ;
        }
        if(programEnrollmentBreachCriteria.getBreachDateTo() != null){
            soql = soql 
            + 'AND Breach_Date__c >= ' + DynamicQueryService.convertDatetoDateString(programEnrollmentBreachCriteria.getBreachDateTo()) + ' ';
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

        if(programEnrollmentCriteria.getAcademicStatus() != null){
            soql += 'AND Program_Enrollment__r.Academic_Status__c = \'' + String.escapeSingleQuotes(programEnrollmentCriteria.getAcademicStatus()) + '\' ';
        }
        if(programEnrollmentCriteria.getPreviousAcademicStatus() != null){
            soql += 'AND Program_Enrollment__r.Previous_Academic_Status__c = \'' + String.escapeSingleQuotes(programEnrollmentCriteria.getPreviousAcademicStatus()) + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStage() != null){
            soql += 'AND Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStatus() != null){
            String statusSetString = DynamicQueryService.formatStringSetForWhereClause(programEnrollmentCriteria.getEnrollmentStatus());
            soql += 'AND Program_Enrollment__r.Enrollment_Status__c IN (' + statusSetString + ') ';
        }
        if(programEnrollmentCriteria.getCategoryType() != null){
            String categoryString = DynamicQueryService.formatStringSetForWhereClause(new Set<String>(programEnrollmentCriteria.getCategoryType()));
            soql += 'AND Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  IN (' + categoryString + ') ';
        }
        
        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForContactCriteria(ContactsDAO.Criteria contactCriteria){
        String soql = '';

        if(contactCriteria.getCitizenshipStatus() != null){
            soql += 'AND Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' ';
        }
        if(contactCriteria.getIsQUTStudent() != null){
            soql += 'AND Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' ' ;
        }
        if(contactCriteria.getRecordType() != null){
            soql += 'AND Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' ';
        }
        if(contactCriteria.getContactIdSet() != null){
            String contactIdString = DynamicQueryService.formatStringSetForWhereClause(contactCriteria.getContactIdSet());
            soql += 'AND Contact__r.Id IN (' + contactIdString + ') ';
        }

        return soql;
    }

    public String getContactQueryByCriteria(
        ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT Contact__c FROM Program_Enrollment_Breach__c ' + getWhereClauseByCriteria(programEnrollmentBreachCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public String getQueryByCriteria(
        ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT Id, Breach_Name__c, Breach_Status__c, Contact__c, Breach_Date__c FROM Program_Enrollment_Breach__c ' + getWhereClauseByCriteria(programEnrollmentBreachCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public List<Program_Enrollment_Breach__c> findByCriteria(
        ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria, 
        ContactsDAO.Criteria contactCriteria,
        AccessLevel accessLevel
    ){
        return Database.query(getQueryByCriteria(programEnrollmentBreachCriteria, programEnrollmentCriteria, contactCriteria), accessLevel);
    }

    /**
     * @Description:Wrapper Class that represents the Criteria for Program Enrollment Breach.
     */
    public class Criteria {
        private Id breach;
        private Set<String> breachStatus;
        private Date breachDateFrom;
        private Date breachDateTo;

        public Boolean isEmpty() {
            return breach == null && breachStatus == null 
                && breachDateFrom == null && breachDateTo == null;
        }

        public Id getBreach(){
            return breach;
        }

        public void setBreach(Id breach){
            this.breach = breach;
        }

        public Set<String> getBreachStatus(){
            return breachStatus;
        }

        public void setBreachStatus(Set<String> breachStatus){
            this.breachStatus = breachStatus;
        }

        public Date getBreachDateFrom(){
            return breachDateFrom;
        }

        public void setBreachDateFrom(Date breachDateFrom){
            this.breachDateFrom = breachDateFrom;
        }

        public Date getBreachDateTo(){
            return breachDateTo;
        }

        public void setBreachDateTo(Date breachDateTo){
            this.breachDateTo = breachDateTo;
        }
    }
    
}
