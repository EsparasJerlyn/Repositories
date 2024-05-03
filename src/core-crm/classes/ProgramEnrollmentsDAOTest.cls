/**
 * @description Test Class for ProgramEnrollmentsDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | eccarius.munoz                 | August 08, 2023       | DEPP-5760              | Created File                               |
 *    | julie.jane.alegre              | May 03, 2024          | DEPP-5728              | Add test  method for Program Enrollment    |
 */  

@isTest
public with sharing class ProgramEnrollmentsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator', 'QUT_ESB'});
    }

    @isTest
    static void getProgramEnrollmentsByIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Program_Enrollment__c> programEnrollmentList = ProgramEnrollmentsDAO.newInstance()
                .getProgramEnrollmentsById(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(programEnrollmentList.isEmpty(), 'Program Enrollment list should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new ProgramEnrollmentsDAO().getSObjectType() == hed__Program_Enrollment__c.SObjectType,
                'SObject is not hed__Program_Enrollment__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getProgramEnrollmentsByContactIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Program_Enrollment__c> programEnrollmentList = ProgramEnrollmentsDAO.newInstance()
                .getProgramEnrollmentsByContactIds(
                    new Set<Id>(),
                    'SYSTEM_MODE'
                );
            System.assert(programEnrollmentList.isEmpty(), 'Program Enrollment list should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getProgramEnrollmentsByContactIdAndStatusTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Program_Enrollment__c> programEnrollmentList = ProgramEnrollmentsDAO.newInstance()
                .getProgramEnrollmentsByContactIdAndStatus(
                    new Set<Id>(),
                    '',
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(programEnrollmentList.isEmpty(), 'Program Enrollment list should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void getAllProgramEnrollmentsByContactIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<hed__Program_Enrollment__c> programEnrollmentList = ProgramEnrollmentsDAO.newInstance()
                .getAllProgramEnrollmentsByContactId(
                    new Set<Id>(),
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(programEnrollmentList.isEmpty(), 'Program Enrollment list should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void queryLocatorGetAllProgramEnrollmentsByContactIdTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            System.assert(
                ProgramEnrollmentsDAO.newInstance().queryLocatorGetAllProgramEnrollmentsByContactId(
                    new Set<Id>()
                ) != null,
                'Program Enrollment list should not be empty.'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getWhereClauseByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

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
            programEnrollmentCriteria.enrollmentStatus = ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH;
            programEnrollmentCriteria.categoryType = 'Graduate Certificate';

            String whereClauseString = ProgramEnrollmentsDAO.newInstance().getWhereClauseByCriteria(programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'WHERE '
                + 'Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' '
                + 'AND Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' '
                + 'AND Enrollment_Status__c IN(\'Admitted\', \'Leave of Absence\') '
                + 'AND hed__Program_Plan__r.Category_Type__c  = \'' + programEnrollmentCriteria.categoryType + '\' '
                + 'AND hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\'';
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
            String whereClauseString = ProgramEnrollmentsDAO.newInstance().getWhereClauseByCriteria(programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = '';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

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
            programEnrollmentCriteria.enrollmentStatus = ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH;

            programEnrollmentCriteria.categoryType = 'Graduate Certificate';

            String whereClauseString = ProgramEnrollmentsDAO.newInstance().getContactQueryByCriteria(programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'SELECT hed__Contact__c FROM hed__Program_Enrollment__c WHERE '
                + 'Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' '
                + 'AND Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' '
                + 'AND Enrollment_Status__c IN(\'Admitted\', \'Leave of Absence\') '
                + 'AND hed__Program_Plan__r.Category_Type__c  = \'' + programEnrollmentCriteria.categoryType + '\' '
                + 'AND hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\'';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void getQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {

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
            programEnrollmentCriteria.enrollmentStatus = ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH;
            programEnrollmentCriteria.categoryType = 'Graduate Certificate';

            String whereClauseString = ProgramEnrollmentsDAO.newInstance().getQueryByCriteria(programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 
                + 'SELECT '  
                + ' Id, hed__Contact__c, Name,  ' 
                + ' Academic_Status__c, Enrollment_Stage__c, Enrollment_Status__c, ' 
                + ' hed__Contact__r.hed__Citizenship_Status__c, hed__Contact__r.QUT_Student__c, hed__Contact__r.RecordType.DeveloperName ' 
                + ' FROM hed__Program_Enrollment__c WHERE ' 
                + 'Academic_Status__c = \'' + programEnrollmentCriteria.academicStatus + '\' '
                + 'AND Enrollment_Stage__c = \'' + programEnrollmentCriteria.enrollmentStage + '\' '
                + 'AND Enrollment_Status__c IN(\'Admitted\', \'Leave of Absence\') '
                + 'AND hed__Program_Plan__r.Category_Type__c  = \'' + programEnrollmentCriteria.categoryType + '\' '
                + 'AND hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\'';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
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
            
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.academicStatus = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentCriteria.enrollmentStage = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            programEnrollmentCriteria.enrollmentStatus = ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH;
            programEnrollmentCriteria.categoryType = 'Graduate Certificate';

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            
            List<hed__Program_Enrollment__c> programEnrollmentList = ProgramEnrollmentsDAO.newInstance()
                .findByCriteria(
                    programEnrollmentCriteria,
                    contactCriteria
                );

            System.assertEquals(programEnrollmentList.size(), programEnrollmentListCreated.size(),  'programEnrollmentList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void criteriaIsEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            ProgramEnrollmentsDAO.Criteria criteria = new ProgramEnrollmentsDAO.Criteria();
            System.assert(criteria.isEmpty(), 'Criteria should be empty.');
        }
        Test.stopTest();
    }
    
}