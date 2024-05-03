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
            contactCriteria.isQUTStudent = true;
            contactCriteria.recordType = ContactsDAO.PERSON_RECORDTYPE;
            contactCriteria.contactIdSet = new Set<Id>{contactId};
            contactCriteria.citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.academicStatus = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentCriteria.enrollmentStage = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.courseGrade = '100';
            courseConnectionCriteria.status = ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH;
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
            programEnrollmentCriteria.academicStatus = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentCriteria.enrollmentStage = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.courseGrade = '100';
            courseConnectionCriteria.status = ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH;
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
            programEnrollmentCriteria.academicStatus = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentCriteria.enrollmentStage = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.courseGrade = '100';
            courseConnectionCriteria.status = ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH;
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
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            //Create record

            List<Contact> contactList;
            List<Lead> leadList;
            List<hed__Program_Enrollment__c> programEnrollmentListCreated;
            List<hed__Program_Plan__c> programPlanListCreated;
            List<Program_Offering__c> programOfferingListCreated;
            List<hed__Course_Enrollment__c> courseConnectionListCreated;
            List<Course_Connection_Assessment__c> courseConnectionAssessmentListCreated;
    
            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new LeadsDAOMock());
            ImplementationSelector.DAO.setMock(new ActionCadenceTrackersDAOMock());
            ImplementationSelector.DAO.setMock(new ProgramEnrollmentsDAOMock());
            ImplementationSelector.DAO.setMock(new CourseConnectionAssessmentsDAOMock());
    
            contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].Calculated_Cadence__c = 'test cadence';
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);
    
            leadList = TestDataFactory.createTestLeadRecords(1);
            leadList[0].Lead_Type__c = 'Learner';
            leadList[0].Calculated_Cadence__c = 'test cadence';
            LeadsDAO.newInstance().insertRecords(leadList,true,AccessLevel.USER_MODE);
    
            programEnrollmentListCreated = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentListCreated[0].Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentListCreated[0].Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentListCreated[0].Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentListCreated,true,AccessLevel.SYSTEM_MODE);

            programPlanListCreated = TestDataFactory.createTestProgramPlanRecords(1);
            ProgramPlansDAO.newInstance().insertRecords(programPlanListCreated,true,AccessLevel.SYSTEM_MODE);

            programOfferingListCreated = TestDataFactory.createTestProgramOfferingRecords(1, programPlanListCreated);
            ProgramOfferingsDAO.newInstance().insertRecords(programOfferingListCreated,true,AccessLevel.SYSTEM_MODE);

            courseConnectionListCreated = TestDataFactory.createTestCourseConnectionRecordProgram(1, contactList[0].Id, programOfferingListCreated);
            courseConnectionListCreated[0].hed__Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            courseConnectionListCreated[0].Enrollment_Status__c = CourseConnectionsDAO.ENROLLMENT_STATUS_ENROLLED;
            courseConnectionListCreated[0].hed__Display_Grade__c = '100';
            CourseConnectionsDAO.newInstance().insertRecords(courseConnectionListCreated,true,AccessLevel.SYSTEM_MODE);
            
            courseConnectionAssessmentListCreated = TestDataFactory.createTestCourseConnectionAssessmentRecord(1, courseConnectionListCreated[0].Id);
            courseConnectionAssessmentListCreated[0].Assessment_Grade__c = '100';
            courseConnectionAssessmentListCreated[0].Submission_Date__c = Date.today();
            CourseConnectionAssessmentsDAO.newInstance().insertRecords(courseConnectionAssessmentListCreated,true,AccessLevel.SYSTEM_MODE);
            
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.academicStatus = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentCriteria.enrollmentStage = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentCriteria.enrollmentStatus = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_FOR_OUTREACH;
            
            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.courseGrade = '100';
            courseConnectionCriteria.status = CourseConnectionsDAO.ENROLLMENT_STATUS_FOR_OUTREACH;

            CourseConnectionAssessmentsDAO.Criteria courseConnectionAssessmentCriteria = new CourseConnectionAssessmentsDAO.Criteria();
            courseConnectionAssessmentCriteria.assessmentGrade = '100';
            courseConnectionAssessmentCriteria.submissionDate = Date.today();

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.recordType = ContactsDAO.PERSON_RECORDTYPE;
            contactCriteria.isQUTStudent = true;
    
            List<Course_Connection_Assessment__c> courseConnectionAssessmentList = CourseConnectionAssessmentsDAO.newInstance()
                .findByCriteria(
                    courseConnectionAssessmentCriteria,
                    courseConnectionCriteria,
                    programEnrollmentCriteria,
                    contactCriteria
                );
            System.debug('courseConnectionAssessmentListCreated' + courseConnectionAssessmentListCreated);
            System.debug('courseConnectionAssessmentList' + courseConnectionAssessmentList);
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
