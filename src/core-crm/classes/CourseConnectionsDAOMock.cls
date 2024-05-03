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
        if(courseConnectionCriteria.status != null){
            soql += 'AND Enrollment_Status__c IN(' + courseConnectionCriteria.status + ') ' ;
        }
        if(courseConnectionCriteria.courseGrade != null){
            soql += 'AND hed__Display_Grade__c = \'' + courseConnectionCriteria.courseGrade + '\' ' ;
        }
        if(programEnrollmentCriteria.academicStatus != null){
            soql += 'AND hed_Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' ' ;
        }
        if(programEnrollmentCriteria.enrollmentStage != null){
            soql += 'AND hed_Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' ' ;
        }
        if(programEnrollmentCriteria.enrollmentStatus != null){
            soql += 'AND hed_Program_Enrollment__r.Enrollment_Status__c = \'' + programEnrollmentCriteria.enrollmentStatus + '\' ' ;
        }
        if(contactCriteria.citizenshipStatus != null){
            soql += 'AND hed_Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.citizenshipStatus + '\' ' ;
        }
        if(contactCriteria.isQUTStudent != null){
            soql += 'AND hed_Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.isQUTStudent + ' ' ;
        }
        if(contactCriteria.recordType != null){
            soql += 'AND hed_Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.recordType + '\' ' ;
        }
        
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
        return 'SELECT hed__Program_Enrollment__r.hed__Contact__c FROM hed__Course_Enrollment__c ' + getWhereClauseByCriteria(courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public String getQueryByCriteria(
        CourseConnectionsDAO.Criteria courseConnectionCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
    ){
        return 'SELECT ' + 
        ' Id, hed__Program_Enrollment__r.hed__Contact__c, Name, Enrollment_Status__c, hed__Grade__c, ' +
        ' hed__Program_Enrollment__r.Academic_Status__c, hed__Program_Enrollment__r.Enrollment_Stage__c, hed__Program_Enrollment__r.Enrollment_Status__c, ' +
        ' hed__Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c, hed__Program_Enrollment__r.hed__Contact__r.QUT_Student__c, hed__Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName ' +
        ' FROM hed__Course_Enrollment__c ' +
        getWhereClauseByCriteria(courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
    }

    public List<hed__Course_Enrollment__c> findByCriteria(
        CourseConnectionsDAO.Criteria courseConnectionCriteria,
        ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria,
        ContactsDAO.Criteria contactCriteria
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
                record.hed__Display_Grade__c == courseConnectionCriteria.courseGrade)
            {
                courseConnectionList.add(record);
            }
        }
        return courseConnectionList;
    }
}