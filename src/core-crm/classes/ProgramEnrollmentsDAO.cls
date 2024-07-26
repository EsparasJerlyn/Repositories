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
 *    | eugene.andrew.abuan            | May 20, 2024          | DEPP-8801              | Changes for Category Type           |
 */
public inherited sharing class ProgramEnrollmentsDAO extends DmlBase implements IProgramEnrollmentsDAO{

    public static final String ACADEMIC_STATUS_SHOW_CAUSE = 'Showcause';    
    public static final String ENROLLMENT_STATUS_ENROLLED = 'Enrolled';
    public static final String ENROLLMENT_STATUS_ADMITTED = 'Admitted';
    public static final String ENROLLMENT_STATUS_PASSED = 'Passed';
    public static final String ENROLLMENT_STATUS_WITHDRAWN = 'Withdrawn';
    public static final String ENROLLMENT_STATUS_EARLY_WITHDRAWN = 'Early Withdrawn';
    public static final String ENROLLMENT_STATUS_LEAVE_OF_ABSENCE = 'Leave of Absence';

    public static final String ENROLLMENT_STAGE_ADMITTED = 'Admitted';
    public static final String ENROLLMENT_STAGE_WITHDRAWN = 'Withdrawn';

    public static final Set<String> ENROLLMENT_STATUSES_WITHDRAWN = new Set<String>{
        ENROLLMENT_STATUS_WITHDRAWN,
        ENROLLMENT_STATUS_EARLY_WITHDRAWN
    };

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
        Set<String> enrollmentStatuses = new Set<String>{
            ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED,
            ProgramEnrollmentsDAO.ENROLLMENT_STATUS_PASSED,
            ProgramEnrollmentsDAO.ENROLLMENT_STATUS_WITHDRAWN
        };
        return Database.query(
            'SELECT Id, hed__Contact__c, Enrollment_Status__c ' +
            'FROM hed__Program_Enrollment__c ' +
            'WHERE hed__Contact__c IN :contactIds ' +
            'AND Enrollment_Status__c IN(' + DynamicQueryService.formatStringSetForWhereClause(enrollmentStatuses) + ') ' +
            'WITH ' + String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<hed__Program_Enrollment__c> getProgramEnrollmentsByContactIdAndEnrollmentStatuses(Set<Id> contactIds, Set<String> statuses, AccessLevel accessLevel){
        return Database.query(
            'SELECT Id, hed__Account__c, hed__Contact__c ' +
              'FROM hed__Program_Enrollment__c ' +
             'WHERE hed__Contact__c IN :contactIds ' + 
               'AND Enrollment_Status__c IN :statuses',
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

    //updated test class and daomock
    public List<hed__Program_Enrollment__c> getPriorityCourses(Map<String, Object> params, AccessLevel accessLevel){
        return Database.queryWithBinds(
            'SELECT Id, hed__Contact__c ' +
              'FROM hed__Program_Enrollment__c ' +
             'WHERE hed__Contact__c IN : contactIdSet ' + 
               'AND hed__Program_Plan__r.hed__Account__r.Is_Priority_Program__c = true ' +
               'AND hed__Program_Plan__r.hed__Account__r.RecordTypeId =: academicProgramRecTypeId ' +
               'AND Enrollment_Status__c IN : enrollmentStatusList',
            params,
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
            soql += 'AND Academic_Status__c = \'' + String.escapeSingleQuotes(programEnrollmentCriteria.getAcademicStatus()) + '\' ';
        }
        if(programEnrollmentCriteria.getPreviousAcademicStatus() != null){
            soql += 'AND Previous_Academic_Status__c = \'' + String.escapeSingleQuotes(programEnrollmentCriteria.getPreviousAcademicStatus()) + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStage() != null){
            soql += 'AND Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' ';
        }
        if(programEnrollmentCriteria.getEnrollmentStatus() != null){
            String statusSetString = DynamicQueryService.formatStringSetForWhereClause(programEnrollmentCriteria.getEnrollmentStatus());
            soql += 'AND Enrollment_Status__c IN(' + statusSetString + ') ';
        }
        if(programEnrollmentCriteria.getCategoryType() != null){
            String categoryString = DynamicQueryService.formatStringSetForWhereClause(new Set<String>(programEnrollmentCriteria.getCategoryType()));
            soql += 'AND hed__Program_Plan__r.Category_Type__c  IN (' + categoryString + ') ';
        }
        if(programEnrollmentCriteria.getAcademicStatusDateFrom() != null){
            soql += 'AND Academic_Status_Date__c <= ' + DynamicQueryService.convertDatetoDateString(programEnrollmentCriteria.getAcademicStatusDateFrom()) + ' ' ;
        }
        if(programEnrollmentCriteria.getAcademicStatusDateTo() != null){
            soql += 'AND Academic_Status_Date__c >= ' + DynamicQueryService.convertDatetoDateString(programEnrollmentCriteria.getAcademicStatusDateTo()) + ' ' ;
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
        if(contactCriteria.getContactIdSet() != null){
            String contactIdString = DynamicQueryService.formatStringSetForWhereClause(contactCriteria.getContactIdSet());
            soql += 'AND hed__Contact__r.Id IN (' + contactIdString + ') ';
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
        ' Academic_Status__c, Previous_Academic_Status__c, Enrollment_Stage__c, Enrollment_Status__c, Academic_Status_Date__c, ' +
        ' hed__Contact__r.hed__Citizenship_Status__c, hed__Contact__r.QUT_Student__c, hed__Contact__r.RecordType.DeveloperName ' +
        ' FROM hed__Program_Enrollment__c ' +
        getWhereClauseByCriteria(programEnrollmentCriteria, contactCriteria);
    }

    public List<hed__Program_Enrollment__c> findByCriteria(
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria,
        AccessLevel accessLevel
    ){
        return Database.query(getQueryByCriteria(programEnrollmentCriteria, contactCriteria), accessLevel);
    }

    /**
     * @Description:Wrapper Class that represents the Criteria for Program Enrollment.
     */
    public class Criteria {
        private String academicStatus;
        private String previousAcademicStatus;
        private String enrollmentStage;
        private Set<String> enrollmentStatus;
        private List <String> categoryType;
        private Date academicStatusDateFrom;
        private Date academicStatusDateTo;

        public String getAcademicStatus(){
            return this.academicStatus;
        }

        public void setAcademicStatus(String varAcademicStatus){
            this.academicStatus = varAcademicStatus;
        }

        public String getPreviousAcademicStatus(){
            return this.previousAcademicStatus;
        }

        public void setPreviousAcademicStatus(String previousAcademicStatus){
            this.previousAcademicStatus = previousAcademicStatus;
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

        public List<String> getCategoryType(){
            return this.categoryType;
        }

        public void setCategoryType(List<String> varCategoryType){
            this.categoryType = varCategoryType;
        }

        public Date getAcademicStatusDateFrom(){
            return this.academicStatusDateFrom;
        }

        public void setAcademicStatusDateFrom(Date academicStatusDateFrom){
            this.academicStatusDateFrom = academicStatusDateFrom;
        }

        public Date getAcademicStatusDateTo(){
            return this.academicStatusDateTo;
        }

        public void setAcademicStatusDateTo(Date academicStatusDateTo){
            this.academicStatusDateTo = academicStatusDateTo;
        }
       
        public Boolean isEmpty() {
            return academicStatus == null && previousAcademicStatus == null && enrollmentStage == null 
                && categoryType == null && enrollmentStatus == null
                && academicStatusDateFrom == null && academicStatusDateTo == null;
        }
    }
    
}