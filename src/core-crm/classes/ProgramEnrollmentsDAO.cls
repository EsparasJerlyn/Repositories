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

    public static final String ACADEMIC_STATUS_SHOW_CAUSE = 'Showcause';    
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
    ){
        return Database.query(getQueryByCriteria(programEnrollmentCriteria, contactCriteria));
    }

    /**
     * @Description:Wrapper Class that represents the Criteria for outreach Case.
     */
    public class Criteria {
        private String academicStatus;
        private String enrollmentStage;
        private Set<String> enrollmentStatus;
        private String categoryType;

        public String getAcademicStatus(){
            return this.academicStatus;
        }

        public void setAcademicStatus(String varAcademicStatus){
            this.academicStatus = varAcademicStatus;
        }
        
        public String getEnrollmentStage(){
            return this.enrollmentStage;
        }

        public void setEnrollmentStage(String varEnrollmentStage){
            this.enrollmentStage = varEnrollmentStage;
        }

        public Set<String> getEnrollmentStatus(){
            return this.enrollmentStatus;
        }

        public void setEnrollmentStatus(Set<String> varEnrollmentStatus){
            this.enrollmentStatus = varEnrollmentStatus;
        }

        public String getCategoryType(){
            return this.categoryType;
        }

        public void setCategoryType(String varCategoryType){
            this.categoryType = varCategoryType;
        }
       
        public Boolean isEmpty() {
            return academicStatus == null && enrollmentStage == null && categoryType == null && enrollmentStatus == null;
        }
    }

    private String formatStringSetForWhereClause(Set<String> stringSet){
        List<String> formattedStrings = new List<String>();
        for(String lineString : stringSet){
            formattedStrings.add('\'' + lineString + '\'');
        }
        return String.join(formattedStrings, ', ');
    }
}