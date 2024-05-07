/**
 * @description Test Class for CourseConnectionAssessmentsDAO
 *
 * @author Accenture
 *
 * @history
 * 
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | julie.jane.alegre              | April 29, 2024        | DEPP-8041              | Created file                                   |
 *    | eccarius.munoz                 | May 3, 2024           | DEPP-7528              | Added test methods for query in outreac case   |
 *    |                                |                       |                        |                                                |
 */
@isTest
public with sharing class CourseConnectionAssessmentsDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator', 'QUT_ESB'});
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new CourseConnectionAssessmentsDAO().getSObjectType() == Course_Connection_Assessment__c.SObjectType,
                'SObject is not Course_Connection_Assessment__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getWhereClauseByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {

            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            Id contactId = mockIdGen.getMockId();

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setContactIdSet(new Set<Id>{contactId});
            contactCriteria.setCitizenshipStatus(ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL);

            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);

            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.setCourseGrade('100');
            courseConnectionCriteria.setStatus(ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH);

            Date submissionDate = Date.today();
            String submissionDateString = DateTime.newInstance(submissionDate.year(), submissionDate.month(), submissionDate.day()).format('YYYY-MM-dd');
            CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            courseConnectionAssessmentsCriteria.setAssessmentGrade('100');
            courseConnectionAssessmentsCriteria.setSubmissionDate(submissionDate);
            courseConnectionAssessmentsCriteria.setAssessmentPriority('Low');
            courseConnectionAssessmentsCriteria.setExecutionDate(Date.today());
            courseConnectionAssessmentsCriteria.setDueDateFrom(-10);
            courseConnectionAssessmentsCriteria.setDueDateTo(10);

            String whereClauseString = CourseConnectionAssessmentsDAO.newInstance().getWhereClauseByCriteria(courseConnectionAssessmentsCriteria, courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'WHERE '
                + 'Assessment_Grade__c = \'' + courseConnectionAssessmentsCriteria.getAssessmentGrade() + '\' '
                + 'AND Submission_Date__c = ' + submissionDateString + ' '
                + 'AND Assessment_Name__r.Assessment_Priority__c = \'' + courseConnectionAssessmentsCriteria.getAssessmentPriority() + '\' '
                + 'AND Assessment_Name__r.Due_Date__c >= ' + courseConnectionAssessmentsCriteria.getDueDateFrom() + ' ' 
                + 'AND Assessment_Name__r.Due_Date__c <= ' + courseConnectionAssessmentsCriteria.getDueDateTo() + ' '
                + 'AND Course_Connection__r.Enrollment_Status__c IN (\'Designated\', \'Failed\', \'Enrolled\', \'Leave of Absence\') '
                + 'AND Course_Connection__r.hed__Display_Grade__c = \'' + courseConnectionCriteria.getCourseGrade() + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Enrollment_Status__c IN (\'Admitted\', \'Leave of Absence\') '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\'';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }

        Test.stopTest();
    }

    @isTest
    static void getContactQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {

            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            Id contactId = mockIdGen.getMockId();

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setContactIdSet(new Set<Id>{contactId});
            contactCriteria.setCitizenshipStatus(ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL);

            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);

            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.setCourseGrade('100');
            courseConnectionCriteria.setStatus(ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH);

            Date submissionDate = Date.today();
            String submissionDateString = DateTime.newInstance(submissionDate.year(), submissionDate.month(), submissionDate.day()).format('YYYY-MM-dd');
            CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            courseConnectionAssessmentsCriteria.setAssessmentGrade('100');
            courseConnectionAssessmentsCriteria.setSubmissionDate(submissionDate);
            courseConnectionAssessmentsCriteria.setAssessmentPriority('Low');
            courseConnectionAssessmentsCriteria.setExecutionDate(Date.today());
            courseConnectionAssessmentsCriteria.setDueDateFrom(-10);
            courseConnectionAssessmentsCriteria.setDueDateTo(10);

            String whereClauseString = CourseConnectionAssessmentsDAO.newInstance().getContactQueryByCriteria(courseConnectionAssessmentsCriteria, courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'SELECT Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__c FROM Course_Connection_Assessment__c WHERE '
                + 'Assessment_Grade__c = \'' + courseConnectionAssessmentsCriteria.getAssessmentGrade() + '\' '
                + 'AND Submission_Date__c = ' + submissionDateString + ' '
                + 'AND Assessment_Name__r.Assessment_Priority__c = \'' + courseConnectionAssessmentsCriteria.getAssessmentPriority() + '\' '
                + 'AND Assessment_Name__r.Due_Date__c >= ' + courseConnectionAssessmentsCriteria.getDueDateFrom() + ' ' 
                + 'AND Assessment_Name__r.Due_Date__c <= ' + courseConnectionAssessmentsCriteria.getDueDateTo() + ' '
                + 'AND Course_Connection__r.Enrollment_Status__c IN (\'Designated\', \'Failed\', \'Enrolled\', \'Leave of Absence\') '
                + 'AND Course_Connection__r.hed__Display_Grade__c = \'' + courseConnectionCriteria.getCourseGrade() + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Enrollment_Status__c IN (\'Admitted\', \'Leave of Absence\') '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\'';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Query');
        }
        
        Test.stopTest();
    }

    @isTest
    static void getQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {

            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            Id contactId = mockIdGen.getMockId();

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setContactIdSet(new Set<Id>{contactId});
            contactCriteria.setCitizenshipStatus(ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL);

            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);

            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.setCourseGrade('100');
            courseConnectionCriteria.setStatus(ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH);

            Date submissionDate = Date.today();
            String submissionDateString = DateTime.newInstance(submissionDate.year(), submissionDate.month(), submissionDate.day()).format('YYYY-MM-dd');

            CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            courseConnectionAssessmentsCriteria.setAssessmentGrade('100');
            courseConnectionAssessmentsCriteria.setSubmissionDate(submissionDate);
            courseConnectionAssessmentsCriteria.setAssessmentPriority ('Low');
            courseConnectionAssessmentsCriteria.setExecutionDate(Date.today());
            courseConnectionAssessmentsCriteria.setDueDateFrom(-10);
            courseConnectionAssessmentsCriteria.setDueDateTo(10);

            String whereClauseString = CourseConnectionAssessmentsDAO.newInstance().getQueryByCriteria(courseConnectionAssessmentsCriteria, courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'SELECT Id, Assessment_Grade__c, Submission_Date__c, Assessment_Name__r.Assessment_Priority__c, Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__c FROM Course_Connection_Assessment__c WHERE '
                + 'Assessment_Grade__c = \'' + courseConnectionAssessmentsCriteria.getAssessmentGrade() + '\' '
                + 'AND Submission_Date__c = ' + submissionDateString + ' '
                + 'AND Assessment_Name__r.Assessment_Priority__c = \'' + courseConnectionAssessmentsCriteria.getAssessmentPriority() + '\' '
                + 'AND Assessment_Name__r.Due_Date__c >= ' + courseConnectionAssessmentsCriteria.getDueDateFrom() + ' ' 
                + 'AND Assessment_Name__r.Due_Date__c <= ' + courseConnectionAssessmentsCriteria.getDueDateTo() + ' '
                + 'AND Course_Connection__r.Enrollment_Status__c IN (\'Designated\', \'Failed\', \'Enrolled\', \'Leave of Absence\') '
                + 'AND Course_Connection__r.hed__Display_Grade__c = \'' + courseConnectionCriteria.getCourseGrade() + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Enrollment_Status__c IN (\'Admitted\', \'Leave of Absence\') '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\'';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Query');
        }

        Test.stopTest();
    }

    @isTest
    static void findByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
    
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);

            List<hed__Program_Plan__c> programPlanListCreated = TestDataFactory.createTestProgramPlanRecords(1);
            programPlanListCreated[0].Category_Type__c = 'Graduate Certificate';
            ProgramPlansDAO.newInstance().insertRecords(programPlanListCreated,true,AccessLevel.SYSTEM_MODE);
    
            List<hed__Program_Enrollment__c> programEnrollmentListCreated = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentListCreated[0].Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentListCreated[0].Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentListCreated[0].Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            programEnrollmentListCreated[0].hed__Contact__c = contactList[0].Id;
            programEnrollmentListCreated[0].hed__Program_Plan__c = programPlanListCreated[0].Id;
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentListCreated,true,AccessLevel.SYSTEM_MODE);

            List<Program_Offering__c> programOfferingListCreated = TestDataFactory.createTestProgramOfferingRecords(1, programPlanListCreated);
            ProgramOfferingsDAO.newInstance().insertRecords(programOfferingListCreated,true,AccessLevel.SYSTEM_MODE);

            List<hed__Course_Enrollment__c> courseConnectionListCreated = TestDataFactory.createTestCourseConnectionRecordProgram(1, contactList[0].Id, programOfferingListCreated);
            courseConnectionListCreated[0].hed__Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            courseConnectionListCreated[0].Enrollment_Status__c = CourseConnectionsDAO.ENROLLMENT_STATUS_ENROLLED;
            courseConnectionListCreated[0].hed__Display_Grade__c = '100';
            CourseConnectionsDAO.newInstance().insertRecords(courseConnectionListCreated,true,AccessLevel.SYSTEM_MODE);
            
            Assessment__c assessmentCreated = new Assessment__c();
            assessmentCreated.Assessment_Priority__c = 'Low';
            assessmentCreated.Due_Date__c = Date.today();
            insert assessmentCreated;
            
            List<Course_Connection_Assessment__c> courseConnectionAssessmentListCreated = TestDataFactory.createTestCourseConnectionAssessmentRecord(1, courseConnectionListCreated[0].Id);
            courseConnectionAssessmentListCreated[0].Assessment_Grade__c = '100';
            courseConnectionAssessmentListCreated[0].Submission_Date__c = Date.today();
            courseConnectionAssessmentListCreated[0].Assessment_Name__c = assessmentCreated.Id;
            CourseConnectionAssessmentsDAO.newInstance().insertRecords(courseConnectionAssessmentListCreated,true,AccessLevel.SYSTEM_MODE);

            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);
            programEnrollmentCriteria.setCategoryType('Graduate Certificate');
            
            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.setCourseGrade('100');
            courseConnectionCriteria.setStatus(ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH);

            CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            courseConnectionAssessmentCriteria.setAssessmentGrade('100');
            courseConnectionAssessmentCriteria.setSubmissionDate(Date.today());
            courseConnectionAssessmentCriteria.setExecutionDate(Date.today());
            courseConnectionAssessmentCriteria.setDueDateFrom(-10);
            courseConnectionAssessmentCriteria.setDueDateTo(10);

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setIsQUTStudent(true);
    
            List<Course_Connection_Assessment__c> courseConnectionAssessmentList = CourseConnectionAssessmentsDAO.newInstance()
                .findByCriteria(
                    courseConnectionAssessmentCriteria,
                    courseConnectionCriteria,
                    programEnrollmentCriteria,
                    contactCriteria,
                    AccessLevel.SYSTEM_MODE
                );

            System.assertEquals(courseConnectionAssessmentList.size(), courseConnectionAssessmentListCreated.size(),  'courseConnectionAssessmentList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void criteriaIsEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            CourseConnectionAssessmentsDAO.Criteria criteria = new CourseConnectionAssessmentsDAO.Criteria();
            System.assert(criteria.isEmpty(), 'Criteria should be empty.');
        }
        Test.stopTest();
    }
}