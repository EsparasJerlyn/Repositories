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
        WAIT_FOR_STUDENT_ACTION_STATUS,
        NULL_STATUS
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
        if(programEnrollmentBreachCriteria.breachStatus != null){
            soql += 'AND Breach_Status__c IN(' + programEnrollmentBreachCriteria.breachStatus + ') ' ;
        }
        if(programEnrollmentBreachCriteria.breach != null){
            soql += 'AND Breach_Name__c = \'' + programEnrollmentBreachCriteria.breach + '\' ' ;
        }
        if(programEnrollmentCriteria.academicStatus != null){
            soql += 'AND Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' ' ;
        }
        if(programEnrollmentCriteria.enrollmentStage != null){
            soql += 'AND Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' ' ;
        }
        if(programEnrollmentCriteria.enrollmentStatus != null){
            soql += 'AND Program_Enrollment__r.Enrollment_Status__c = \'' + programEnrollmentCriteria.enrollmentStatus + '\' ' ;
        }
        if(contactCriteria.citizenshipStatus != null){
            soql += 'AND Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.citizenshipStatus + '\' ' ;
        }
        if(contactCriteria.isQUTStudent != null){
            soql += 'AND Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.isQUTStudent + ' ' ;
        }
        if(contactCriteria.recordType != null){
            soql += 'AND Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.recordType + '\' ' ;
        }
        
        if(soql != '') {
            soql = 'WHERE ' + soql.trim().replaceFirst('^AND\\s*', '').trim();
        }
        
        /*temporarily commented out*/
        // if(programEnrollmentBreachCriteria.keyDateOffset != null && programEnrollmentBreachCriteria.executionDate != null){
        //     Date lowerKeyDateOffSetBoundary = programEnrollmentBreachCriteria.executionDate.addDays(-programEnrollmentBreachCriteria.keyDateOffset);
        //     Date upperKeyDateOffSetBoundary = programEnrollmentBreachCriteria.executionDate.addDays(programEnrollmentBreachCriteria.keyDateOffset);
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
        public Id breach;
        public Set<String> breachStatus;
        public Integer keyDateOffset;    
        public Date executionDate;

        public Boolean isEmpty() {
            return breach == null && breachStatus == null && keyDateOffset == null && executionDate == null;
        }
    }
}
