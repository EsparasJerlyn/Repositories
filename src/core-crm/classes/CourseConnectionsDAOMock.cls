/**
 * @description Mock DAO Class for Course Connection Object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | mark.j.mahilum                 | July 21, 2023         | DEPP-5799              | Created File                                   |
      | eccarius.munoz                 | August 08, 2023       | DEPP-5760              | added method named                             |
      |                                |                       |                        | getCourseConnectionByProgramEnrollmentIds      |
      | roy.nino.s.regala              | Sep 20, 2023          | DEPP-6714              | added method named                             |
      |                                |                       |                        | getActiveCourseConnectionsBySetContactIds      |
      | kenneth.f.alsay                | Sep 25, 2023          | DEPP-6629              | added getCourseConnectionByStatus method       |
      | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCourseConnectionByCartItem |
 */
@isTest
public inherited sharing class CourseConnectionsDAOMock extends DmlBaseMock implements ICourseConnectionsDAO { 
    public Map<Id, hed__Course_Enrollment__c> courseConnectionMap;

    public CourseConnectionsDAOMock() {
        super(new Map<Id, hed__Course_Enrollment__c>(), Schema.hed__Course_Enrollment__c.SObjectType);
        this.courseConnectionMap = (Map<Id, hed__Course_Enrollment__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return hed__Course_Enrollment__c.SObjectType;
    }

    public List<hed__Course_Enrollment__c> getCourseConnectionByPEContactIds(
        Set<Id> contactIds,
        String accessLevel
    ) {
        List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();

        for (hed__Course_Enrollment__c record : courseConnectionMap.values()) {
            if (contactIds.contains(record.hed__Program_Enrollment__r.hed__Contact__c)) {
                courseConnectionList.add(record);
            }
        }

        return courseConnectionList;
    }

    public List<hed__Course_Enrollment__c> getCourseConnectionByProgramEnrollmentIds(
        Set<Id> programEnrollmentIds,
        String accessLevel
    ) {
        List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();

        for (hed__Course_Enrollment__c record : courseConnectionMap.values()) {
            if (programEnrollmentIds.contains(record.Id)) {
                courseConnectionList.add(record);
            }
        }

        return courseConnectionList;
    }

    public List<hed__Course_Enrollment__c> getActiveCourseConnectionsBySetContactIds(
        Set<String> contactIds,
        AccessLevel accessLevel
    ) {
        List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();

        for (hed__Course_Enrollment__c record : courseConnectionMap.values()) {
            if (contactIds.contains(record.hed__Contact__c) && record.hed__Status__c == 'Active') {
                courseConnectionList.add(record);
            }
        }

        return courseConnectionList;
    }
    
    public List<hed__Course_Enrollment__c> getRegisteredLearnersEmailByCourseOffering(
        Set<Id> courseOfferingIds,
        Set<Id> programOfferingIds,
        AccessLevel accessLevel
    ) {
        List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();
        courseOfferingIds = courseOfferingIds == null ? new Set<Id>() : courseOfferingIds;
        programOfferingIds = programOfferingIds == null ? new Set<Id>() : programOfferingIds;

        for (hed__Course_Enrollment__c record : courseConnectionMap.values()) {
            if (
                (courseOfferingIds.contains(record.hed__Course_Offering__c) ||
                programOfferingIds.contains(record.Program_Offering__c)) &&
                record.hed__Status__c == 'Active'
            ) {
                courseConnectionList.add(record);
            }
        }

        return courseConnectionList;
    }
    public List<hed__Course_Enrollment__c> getCourseConnectionByStatus(
        String status,
        String lmsIntegrationStatus
    ){
        List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();

        for (hed__Course_Enrollment__c record : courseConnectionMap.values()) {
            if (record.LMS_Integration_Status__c == lmsIntegrationStatus && record.hed__Status__c == status) {
                courseConnectionList.add(record);
            }
        }

        return courseConnectionList;
    }

    public List<hed__Course_Enrollment__c> getCourseConnectionByCartItem(
        Set<Id> cartItemIdSet,
        AccessLevel accessLevel
    ) {
        List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();

        for (hed__Course_Enrollment__c record : courseConnectionMap.values()) {
            if (cartItemIdSet.contains(record.Cart_Item__c)) {
                courseConnectionList.add(record);
            }
        }

        return courseConnectionList;
    }

    public String getWhereClauseByCriteria(
        CourseConnectionsDAO.Criteria courseConnectionCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        String soql = '';
        soql = whereClauseCheckerForCourseConnectionCriteria(courseConnectionCriteria) + whereClauseCheckerForProgramEnrollmentCriteria(programEnrollmentCriteria) + whereClauseCheckerForContactCriteria(contactCriteria);        
        if(soql != '') {
            soql = 'WHERE ' + soql.trim().removeStart('AND').trim();
        }
        return soql;
    }

    public String getContactQueryByCriteria(
        CourseConnectionsDAO.Criteria courseConnectionCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT hed__Contact__c FROM hed__Course_Enrollment__c ' + getWhereClauseByCriteria(courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public String getQueryByCriteria(
        CourseConnectionsDAO.Criteria courseConnectionCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT ' + 
        'Id, hed__Contact__c, Name, Enrollment_Status__c, hed__Display_Grade__c, ' +
        'hed__Program_Enrollment__r.Academic_Status__c, hed__Program_Enrollment__r.Previous_Academic_Status__c, hed__Program_Enrollment__r.Enrollment_Stage__c, hed__Program_Enrollment__r.Enrollment_Status__c, ' +
        'hed__Contact__r.hed__Citizenship_Status__c, hed__Contact__r.QUT_Student__c, hed__Contact__r.RecordType.DeveloperName ' +
        'FROM hed__Course_Enrollment__c ' +
        getWhereClauseByCriteria(courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public List<hed__Course_Enrollment__c> findByCriteria(
        CourseConnectionsDAO.Criteria courseConnectionCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria,
        AccessLevel accessLevel
    ) {
        List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();

        for (hed__Course_Enrollment__c record : courseConnectionMap.values()) {
            if(
                (   
                    record.Enrollment_Status__c == CourseConnectionsDAO.ENROLLMENT_STATUS_DESIGNATED || 
                    record.Enrollment_Status__c == CourseConnectionsDAO.ENROLLMENT_STATUS_FAILED ||
                    record.Enrollment_Status__c == CourseConnectionsDAO.ENROLLMENT_STATUS_ENROLLED ||
                    record.Enrollment_Status__c == CourseConnectionsDAO.ENROLLMENT_STATUS_LEAVE_OF_ABSENCE 
                ) &&
                record.hed__Display_Grade__c == courseConnectionCriteria.getCourseGrade())
            {
                courseConnectionList.add(record);
            }
        }
        return courseConnectionList;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForCourseConnectionCriteria(CourseConnectionsDAO.Criteria courseConnectionCriteria){
        String soql = '';
        if(courseConnectionCriteria.getStatus() != null){
            String statusSetString = DynamicQueryService.formatStringSetForWhereClause(courseConnectionCriteria.getStatus());
            soql += 'AND Enrollment_Status__c IN(' + statusSetString + ') ';
        }
        if(courseConnectionCriteria.getCourseGrade() != null){
            soql += 'AND hed__Display_Grade__c = \'' + courseConnectionCriteria.getCourseGrade() + '\' ' ;
        }
        
        return soql;
    }

    //Checks to ensure fields have values
    private String whereClauseCheckerForProgramEnrollmentCriteria(ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria){
        String soql = '';

        if(programEnrollmentCriteria.getAcademicStatus() != null){
            soql += 'AND hed__Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' ' ;
        }
        if(programEnrollmentCriteria.getPreviousAcademicStatus() != null){
            soql += 'AND hed__Program_Enrollment__r.Previous_Academic_Status__c = \'' + programEnrollmentCriteria.getPreviousAcademicStatus() + '\' ' ;
        }
        if(programEnrollmentCriteria.getEnrollmentStage() != null){
            soql += 'AND hed__Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' ' ;
        }
        if(programEnrollmentCriteria.getEnrollmentStatus() != null){
            String statusSetString = DynamicQueryService.formatStringSetForWhereClause(programEnrollmentCriteria.getEnrollmentStatus());
            soql += 'AND hed__Program_Enrollment__r.Enrollment_Status__c IN(' + statusSetString + ') ';
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


}