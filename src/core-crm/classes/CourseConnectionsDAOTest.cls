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
      | julie.jane.alegre              | May 03, 2024          | DEPP-7528              | Added test classes for Program Enrollment         |
 */
@isTest
public with sharing class CourseConnectionsDAOTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserQUTESB();
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {

            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            Id contactId = mockIdGen.getMockId();

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setContactIdSet(new Set<Id>{contactId});
            contactCriteria.setCitizenshipStatus(ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL);

            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setPreviousAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);

            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.setCourseGrade('100');
            courseConnectionCriteria.setStatus(ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH);

            String whereClauseString = CourseConnectionsDAO.newInstance().getWhereClauseByCriteria(courseConnectionCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'WHERE '
                + 'Enrollment_Status__c IN(\'Designated\', \'Failed\', \'Enrolled\', \'Leave of Absence\') '
                + 'AND hed__Display_Grade__c = \'' + courseConnectionCriteria.getCourseGrade() + '\' '
                + 'AND hed__Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' '
                + 'AND hed__Program_Enrollment__r.Previous_Academic_Status__c = \'' + programEnrollmentCriteria.getPreviousAcademicStatus() + '\' '
                + 'AND hed__Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' '
                + 'AND hed__Program_Enrollment__r.Enrollment_Status__c IN(\'Admitted\', \'Leave of Absence\') '
                + 'AND hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' '
                + 'AND hed__Contact__r.Id IN ('+ DynamicQueryService.formatStringSetForWhereClause(contactCriteria.getContactIdSet()) + ')';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void getWhereClauseByNoCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {

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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {

            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            Id contactId = mockIdGen.getMockId();

            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.setCourseGrade('100');
            courseConnectionCriteria.setStatus(ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH);

            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setPreviousAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setContactIdSet(new Set<Id>{contactId});
            contactCriteria.setCitizenshipStatus(ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL);

            String whereClauseString = CourseConnectionsDAO.newInstance()
                .getContactQueryByCriteria(
                    courseConnectionCriteria,
                    programEnrollmentCriteria,
                    contactCriteria
                );
            String expectedWhereClause = 'WHERE '
                    + 'Enrollment_Status__c IN(\'Designated\', \'Failed\', \'Enrolled\', \'Leave of Absence\') '
                    + 'AND hed__Display_Grade__c = \'' + courseConnectionCriteria.getCourseGrade() + '\' '
                    + 'AND hed__Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' '
                    + 'AND hed__Program_Enrollment__r.Previous_Academic_Status__c = \'' + programEnrollmentCriteria.getPreviousAcademicStatus() + '\' '
                    + 'AND hed__Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' '
                    + 'AND hed__Program_Enrollment__r.Enrollment_Status__c IN(\'Admitted\', \'Leave of Absence\') '
                    + 'AND hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                    + 'AND hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                    + 'AND hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' '
                    + 'AND hed__Contact__r.Id IN ('+ DynamicQueryService.formatStringSetForWhereClause(contactCriteria.getContactIdSet()) + ')';
            
            String expectedClauseString = 'SELECT hed__Contact__c FROM hed__Course_Enrollment__c ' +  expectedWhereClause;
            System.assertEquals(expectedClauseString, whereClauseString, 'Contact query by criteria should not be null.');
        }
        Test.stopTest();
    }

    @isTest
    static void getQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            Id contactId = mockIdGen.getMockId();

            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.setCourseGrade('100');
            courseConnectionCriteria.setStatus(ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH);
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setPreviousAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setContactIdSet(new Set<Id>{contactId});
            contactCriteria.setCitizenshipStatus(ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL);

            String whereClauseString = CourseConnectionsDAO.newInstance()
                .getQueryByCriteria(
                    courseConnectionCriteria,
                    programEnrollmentCriteria,
                    contactCriteria
                );
            String expectedWhereClause = 'WHERE '
                    + 'Enrollment_Status__c IN(\'Designated\', \'Failed\', \'Enrolled\', \'Leave of Absence\') '
                    + 'AND hed__Display_Grade__c = \'' + courseConnectionCriteria.getCourseGrade() + '\' '
                    + 'AND hed__Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' '
                    + 'AND hed__Program_Enrollment__r.Previous_Academic_Status__c = \'' + programEnrollmentCriteria.getPreviousAcademicStatus() + '\' '
                    + 'AND hed__Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' '
                    + 'AND hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                    + 'AND hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                    + 'AND hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' '
                    + 'AND hed__Contact__r.Id IN ('+ DynamicQueryService.formatStringSetForWhereClause(contactCriteria.getContactIdSet()) + ')';
            
            String expectedClauseString = 'SELECT ' + 
                                        'Id, hed__Contact__c, Name, Enrollment_Status__c, hed__Display_Grade__c, ' +
                                        'hed__Program_Enrollment__r.Academic_Status__c, hed__Program_Enrollment__r.Previous_Academic_Status__c, hed__Program_Enrollment__r.Enrollment_Stage__c, hed__Program_Enrollment__r.Enrollment_Status__c, ' +
                                        'hed__Contact__r.hed__Citizenship_Status__c, hed__Contact__r.QUT_Student__c, hed__Contact__r.RecordType.DeveloperName ' +
                                        'FROM hed__Course_Enrollment__c ' + expectedWhereClause;
                                                                    
            System.assertEquals(expectedClauseString, whereClauseString, 'Query by criteria should not be null.');
        }
        Test.stopTest();
    }

    @isTest
    static void findByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            //Created record
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
            courseConnectionListCreated[0].hed__Contact__c = contactList[0].Id;
        
            CourseConnectionsDAO.newInstance().insertRecords(courseConnectionListCreated,true,AccessLevel.SYSTEM_MODE);

            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);
            programEnrollmentCriteria.setCategoryType(new List<String>{'Graduate Certificate'});




            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.setCourseGrade('100');
            courseConnectionCriteria.setStatus(ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH);


            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);

            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .findByCriteria(
                    courseConnectionCriteria,
                    programEnrollmentCriteria,
                    contactCriteria,
                    AccessLevel.USER_MODE
                );
                
            System.assertEquals(courseConnectionListCreated.size(), courseConnectionList.size(), 'courseConnectionList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void findByCriteriaNegativeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            //Created record
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);

            List<hed__Program_Plan__c> programPlanListCreated = TestDataFactory.createTestProgramPlanRecords(1);
            programPlanListCreated[0].Category_Type__c = 'Graduate Certificate';
            ProgramPlansDAO.newInstance().insertRecords(programPlanListCreated,true,AccessLevel.SYSTEM_MODE);
    
            List<hed__Program_Enrollment__c> programEnrollmentListCreated = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentListCreated[0].Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentListCreated[0].Previous_Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentListCreated[0].Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentListCreated[0].Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            programEnrollmentListCreated[0].hed__Contact__c = contactList[0].Id;
            programEnrollmentListCreated[0].hed__Program_Plan__c = programPlanListCreated[0].Id;
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentListCreated,true,AccessLevel.SYSTEM_MODE);

            List<Program_Offering__c> programOfferingListCreated = TestDataFactory.createTestProgramOfferingRecords(1, programPlanListCreated);
            ProgramOfferingsDAO.newInstance().insertRecords(programOfferingListCreated,true,AccessLevel.SYSTEM_MODE);

            //Created a course connection record for negative test scenario
            List<hed__Course_Enrollment__c> courseConnectionListCreated = TestDataFactory.createTestCourseConnectionRecordProgram(1, contactList[0].Id, programOfferingListCreated);
            courseConnectionListCreated[0].hed__Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            courseConnectionListCreated[0].Enrollment_Status__c = CourseConnectionsDAO.ENROLLMENT_STATUS_CANCELLED;
            courseConnectionListCreated[0].hed__Display_Grade__c = '100';
            courseConnectionListCreated[0].hed__Contact__c = contactList[0].Id;
            CourseConnectionsDAO.newInstance().insertRecords(courseConnectionListCreated,true,AccessLevel.SYSTEM_MODE);

            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setPreviousAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);
            programEnrollmentCriteria.setCategoryType(new List<String>{'Graduate Certificate'});

            CourseConnectionsDAO.Criteria courseConnectionCriteria = new CourseConnectionsDAO.Criteria();
            courseConnectionCriteria.setCourseGrade('100');
            courseConnectionCriteria.setStatus(ELCCourseConnectionParser.ENROLLMENT_STATUS_FOR_OUTREACH);

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);

            List<hed__Course_Enrollment__c> courseConnectionList = CourseConnectionsDAO.newInstance()
                .findByCriteria(
                    courseConnectionCriteria,
                    programEnrollmentCriteria,
                    contactCriteria,
                    AccessLevel.USER_MODE
                );
                
            System.assert(courseConnectionList.isEmpty(), 'Course Connection record should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void criteriaIsEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            CourseConnectionsDAO.Criteria criteria = new CourseConnectionsDAO.Criteria();
            System.assert(criteria.isEmpty(), 'Criteria should be empty.');
        }
        Test.stopTest();
    }

}