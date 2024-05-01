/**
 * @description DAO Class for hed__Program_Enrollment__c Object. Contains soql and constants related to the hed__Program_Enrollment__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 08, 2023       |DEPP-5760               | Created File                        |
 *    | roy.nino.s.regala              | November 03, 2023     |DEPP-7145               | Added new static string variable    |
 */
public inherited sharing class ProgramEnrollmentsDAO extends DmlBase implements IProgramEnrollmentsDAO{

    public static final String ENROLLMENT_STATUS_ENROLLED = 'Enrolled';
    public static final String ENROLLMENT_STATUS_ADMITTED = 'Admitted';
    public static final String ENROLLMENT_STATUS_LEAVE_OF_ABSENCE = 'Leave of Absence';

    public static final String ENROLLMENT_STAGE_ADMITTED = 'Admitted';

    public static final Set<String> ENROLLMENT_STATUS = new Set<String>{
        'Early Withdrawn',
        'Withdrawn',
        'Passed',
        'Conditionally Complete',
        'Potentially Complete'
    };

    public static final Set<String> ENROLLMENT_STATUS_FOR_OUTREACH = new Set<String>{
        ENROLLMENT_STATUS_ADMITTED,
        ENROLLMENT_STATUS_LEAVE_OF_ABSENCE
    };

    public Schema.SObjectType getSObjectType(){
		return hed__Program_Enrollment__c.SObjectType;
	}

    public static IProgramEnrollmentsDAO newInstance(){
		return (IProgramEnrollmentsDAO) ImplementationSelector.DAO.newInstance(hed__Program_Enrollment__c.SObjectType);
	}

    public List<hed__Program_Enrollment__c> getProgramEnrollmentsById(Set<Id> programEnrollmentIds, String accessLevel){
        return Database.query(
            'SELECT Id, hed__Contact__c, Enrollment_Status__c ' +
            'FROM hed__Program_Enrollment__c ' +
            'WHERE Id IN :programEnrollmentIds ' + 
            'WITH ' + String.escapeSingleQuotes(accessLevel)
        );
    }
    
    public List<hed__Program_Enrollment__c> getProgramEnrollmentsByContactIds(Set<Id> contactIds, String accessLevel){
        return Database.query(
            'SELECT Id, hed__Contact__c, Enrollment_Status__c ' +
            'FROM hed__Program_Enrollment__c ' +
            'WHERE hed__Contact__c IN :contactIds ' +
            'AND Enrollment_Status__c = \'Admitted\' ' +
            'AND hed__Contact__r.QUT_Student__c = FALSE ' +
            'WITH ' + String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<hed__Program_Enrollment__c> getProgramEnrollmentsByContactIdAndStatus(Set<Id> contactIds, String status, AccessLevel accessLevel){
        return Database.query(
            'SELECT Id, hed__Account__c, hed__Contact__c ' +
              'FROM hed__Program_Enrollment__c ' +
             'WHERE hed__Contact__c IN :contactIds ' + 
               'AND Enrollment_Status__c =: status',
            accessLevel
        );
    }

    public List<hed__Program_Enrollment__c> getAllProgramEnrollmentsByContactId(Set<Id> contactIds, AccessLevel accessLevel){
        return Database.query(
            'SELECT Id, hed__Account__c, hed__Contact__c, Enrollment_Status__c, Lead_Score_Reset__c, Enrollment_Status_Date__c, hed__Admission_Date__c ' +
              'FROM hed__Program_Enrollment__c ' +
             'WHERE hed__Contact__c IN :contactIds',
            accessLevel
        );
    }

    public Database.QueryLocator queryLocatorGetAllProgramEnrollmentsByContactId(
        Set<Id> recordIds
    ){
        String query =
            'SELECT Id, hed__Account__c, hed__Contact__c, Enrollment_Status__c, Lead_Score_Reset__c ' +
              'FROM hed__Program_Enrollment__c ' +
             'WHERE hed__Contact__c IN :recordIds';
        return Database.getQueryLocator(query);
    }

    /**
     * @Description:Wrapper Class that represents the Criteria for outreach Case.
     */
    public class Criteria {
        public String academicStatus;
        public String enrollmentStage;
        public Set<String> enrollmentStatus;
        public String categoryType;
       
        public Boolean isEmpty() {
            return academicStatus == null && enrollmentStage == null && categoryType == null && enrollmentStatus.isEmpty();
        }
    }
}