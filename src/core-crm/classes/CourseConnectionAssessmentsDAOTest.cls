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
 *    |                                |                       |                        |                                                |
 */
@isTest
public with sharing class CourseConnectionAssessmentsDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator'});
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
            contactCriteria.isQUTStudent = true;
            contactCriteria.recordType = ContactsDAO.PERSON_RECORDTYPE;
            contactCriteria.contactIdSet = new Set<Id>{contactId};
            contactCriteria.citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.academicStatus = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentCriteria.enrollmentStage = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.courseGrade = '100';
            courseConnectionCriteria.status = CourseConnectionsDAO.ENROLLMENT_STATUS_FOR_OUTREACH;
            CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            courseConnectionAssessmentsCriteria.assessmentGrade = '100';
            courseConnectionAssessmentsCriteria.submissionDate = Date.today();
            courseConnectionAssessmentsCriteria.assessmentPriority = 'Low';

            String whereClauseString = CourseConnectionAssessmentsDAO.newInstance().getWhereClauseByCriteria(courseConnectionAssessmentsCriteria, courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'WHERE '
                + 'Assessment_Grade__c = \'' + courseConnectionAssessmentsCriteria.assessmentGrade + '\' '
                + 'AND Submission_Date__c = ' + courseConnectionAssessmentsCriteria.submissionDate + ' '
                + 'AND Assessment_Name__r.Assessment_Priority__c = \'' + courseConnectionAssessmentsCriteria.assessmentPriority + '\' '
                + 'AND Course_Connection__r.Enrollment_Status__c IN(' + courseConnectionCriteria.status + ') '
                + 'AND Course_Connection__r.hed__Display_Grade__c = \'' + courseConnectionCriteria.courseGrade + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.citizenshipStatus + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.isQUTStudent + ' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.recordType + '\'';
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
            contactCriteria.isQUTStudent = true;
            contactCriteria.recordType = ContactsDAO.PERSON_RECORDTYPE;
            contactCriteria.contactIdSet = new Set<Id>{contactId};
            contactCriteria.citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.academicStatus = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentCriteria.enrollmentStage = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.courseGrade = '100';
            courseConnectionCriteria.status = CourseConnectionsDAO.ENROLLMENT_STATUS_FOR_OUTREACH;
            CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            courseConnectionAssessmentsCriteria.assessmentGrade = '100';
            courseConnectionAssessmentsCriteria.submissionDate = Date.today();
            courseConnectionAssessmentsCriteria.assessmentPriority = 'Low';

            String whereClauseString = CourseConnectionAssessmentsDAO.newInstance().getQueryByCriteria(courseConnectionAssessmentsCriteria, courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'SELECT Id, Assessment_Grade__c, Submission_Date__c, Assessment_Name__r.Assessment_Priority__c, Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__c FROM Course_Connection_Assessment__c WHERE '
                + 'Assessment_Grade__c = \'' + courseConnectionAssessmentsCriteria.assessmentGrade + '\' '
                + 'AND Submission_Date__c = ' + courseConnectionAssessmentsCriteria.submissionDate + ' '
                + 'AND Assessment_Name__r.Assessment_Priority__c = \'' + courseConnectionAssessmentsCriteria.assessmentPriority + '\' '
                + 'AND Course_Connection__r.Enrollment_Status__c IN(' + courseConnectionCriteria.status + ') '
                + 'AND Course_Connection__r.hed__Display_Grade__c = \'' + courseConnectionCriteria.courseGrade + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.citizenshipStatus + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.isQUTStudent + ' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.recordType + '\'';
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
            contactCriteria.isQUTStudent = true;
            contactCriteria.recordType = ContactsDAO.PERSON_RECORDTYPE;
            contactCriteria.contactIdSet = new Set<Id>{contactId};
            contactCriteria.citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.academicStatus = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentCriteria.enrollmentStage = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.courseGrade = '100';
            courseConnectionCriteria.status = CourseConnectionsDAO.ENROLLMENT_STATUS_FOR_OUTREACH;
            CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentsCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            courseConnectionAssessmentsCriteria.assessmentGrade = '100';
            courseConnectionAssessmentsCriteria.submissionDate = Date.today();
            courseConnectionAssessmentsCriteria.assessmentPriority = 'Low';

            String whereClauseString = CourseConnectionAssessmentsDAO.newInstance().getQueryByCriteria(courseConnectionAssessmentsCriteria, courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'SELECT Id, Assessment_Grade__c, Submission_Date__c, Assessment_Name__r.Assessment_Priority__c, Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__c FROM Course_Connection_Assessment__c WHERE '
                + 'Assessment_Grade__c = \'' + courseConnectionAssessmentsCriteria.assessmentGrade + '\' '
                + 'AND Submission_Date__c = ' + courseConnectionAssessmentsCriteria.submissionDate + ' '
                + 'AND Assessment_Name__r.Assessment_Priority__c = \'' + courseConnectionAssessmentsCriteria.assessmentPriority + '\' '
                + 'AND Course_Connection__r.Enrollment_Status__c IN(' + courseConnectionCriteria.status + ') '
                + 'AND Course_Connection__r.hed__Display_Grade__c = \'' + courseConnectionCriteria.courseGrade + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.citizenshipStatus + '\' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.isQUTStudent + ' '
                + 'AND Course_Connection__r.hed__Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.recordType + '\'';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Query');
        }
        Test.stopTest();
    }

    @isTest
    static void findByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Course_Connection_Assessment__c> courseConnectionAssessmentList = CourseConnectionAssessmentsDAO.newInstance()
                .findByCriteria(
                    new CourseConnectionAssessmentsDAO.Criteria(),
                    new CourseConnectionsDAO.Criteria(), 
                    new ProgramEnrollmentsDAO.Criteria(), 
                    new ContactsDAO.Criteria()
                );
            System.assert(courseConnectionAssessmentList.isEmpty(), 'courseConnectionAssessmentList should not be empty.');
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
