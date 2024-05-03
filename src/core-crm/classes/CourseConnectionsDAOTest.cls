/**
 * @description Test Class CourseConnectionDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | mark.j.mahilum                 | July 21, 2023         | DEPP-5799              | Created File                                      |
      | eccarius.munoz                 | August 08, 2023       | DEPP-5760              | added method named                                |
      |                                |                       |                        | getCourseConnectionByProgramEnrollmentIds         |
      | roy.nino.s.regala              | Sep 20, 2023          | DEPP-6714              | added method named                                |
      |                                |                       |                        | getCourseConnectionByProgramEnrollmentIds         |
      | kenneth.f.alsay                | Sep 25, 2023          | DEPP-6629              | added method named                                |
      |                                |                       |                        | getCourseConnectionByStatusTest                   |
      | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCourseConnectionByCartItemTest|
      |                                |                       |                        | getCourseConnectionByCartItemNotEmptyTest         |
 */
@isTest
public with sharing class CourseConnectionsDAOTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new CourseConnectionsDAO().getSObjectType() == hed__Course_Enrollment__c.SObjectType,
                'SObject is not hed__Course_Enrollment__c'
            );
        }
        Test.stopTest();
    }


    @isTest
    static void getCourseConnectionByPEContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getCourseConnectionByPEContactIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCourseConnectionByProgramEnrollmentIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getCourseConnectionByProgramEnrollmentIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getActiveCourseConnectionsBySetContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getActiveCourseConnectionsBySetContactIds(
                    new Set<String>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getRegisteredLearnersEmailByCourseOfferingTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getRegisteredLearnersEmailByCourseOffering(
                    new Set<Id>(),
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCourseConnectionByStatusTest(){
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getCourseConnectionByStatus(
                    'Active',
                    'Sent'
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCourseConnectionByCartItemTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getCourseConnectionByCartItem(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getCourseConnectionByCartItemNotEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            MockIdGenerator builderForCartItem = new MockIdGenerator(CartItem.sObjectType);
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .getCourseConnectionByCartItem(
                    new Set<Id>{builderForCartItem.getMockId()},
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should be empty.');
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
            programEnrollmentCriteria.academicStatus = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentCriteria.enrollmentStage = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;

            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.courseGrade = '100';
            courseConnectionCriteria.status = ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH;

            String whereClauseString = CourseConnectionsDAO.newInstance().getWhereClauseByCriteria(courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'WHERE '
                + 'Enrollment_Status__c IN(' + courseConnectionCriteria.status + ') '
                + 'AND hed__Display_Grade__c = \'' + courseConnectionCriteria.courseGrade + '\' '
                + 'AND hed_Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' '
                + 'AND hed_Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' '
                + 'AND hed_Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND hed_Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND hed_Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\'';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void getWhereClauseByNoCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            String whereClauseString = CourseConnectionsDAO.newInstance().getWhereClauseByCriteria(courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = '';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            String wherClauseString = CourseConnectionsDAO.newInstance()
                .getContactQueryByCriteria(
                    new CourseConnectionsDAO.Criteria(),
                    new ProgramEnrollmentsDAO.Criteria(),
                    new ContactsDAO.Criteria()
                );
            System.assert(wherClauseString != null, 'Contact query by criteria should not be null.');
        }
        Test.stopTest();
    }

    @isTest
    static void getQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            String wherClauseString = CourseConnectionsDAO.newInstance()
                .getQueryByCriteria(
                    new CourseConnectionsDAO.Criteria(),
                    new ProgramEnrollmentsDAO.Criteria(),
                    new ContactsDAO.Criteria()
                );
            System.assert(wherClauseString != null, 'Query by criteria should not be null.');
        }
        Test.stopTest();
    }

    @isTest
    static void findByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .findByCriteria(
                    new CourseConnectionsDAO.Criteria(),
                    new ProgramEnrollmentsDAO.Criteria(),
                    new ContactsDAO.Criteria()
                );
            System.assert(courseConnectionList.isEmpty(), 'courseConnectionList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void criteriaIsEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            CourseConnectionsDAO.Criteria criteria = new CourseConnectionsDAO.Criteria();
            System.assert(criteria.isEmpty(), 'Criteria should be empty.');
        }
        Test.stopTest();
    }

}