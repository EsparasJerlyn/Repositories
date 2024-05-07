/**
 * @description Test Class for ProgramEnrollmentBreachesDAO
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
public with sharing class ProgramEnrollmentBreachesDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator', 'QUT_ESB'});
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new ProgramEnrollmentBreachesDAO().getSObjectType() == Program_Enrollment_Breach__c.SObjectType,
                'SObject is not Program_Enrollment_Breach__c'
            );
        }
        Test.stopTest();
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
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);
            programEnrollmentCriteria.setCategoryType('Graduate Certificate');
            ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
            programEnrollmentBreachCriteria.setBreachStatus(ProgramEnrollmentBreachesDAO.STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH);
            programEnrollmentBreachCriteria.setBreach(mockIdGen.getMockId());
            programEnrollmentBreachCriteria.setExecutionDate(Date.today());
            programEnrollmentBreachCriteria.setBreachDateFrom(-10);
            programEnrollmentBreachCriteria.setBreachDateTo(10);
            
            String whereClauseString = ProgramEnrollmentBreachesDAO.newInstance().getWhereClauseByCriteria(programEnrollmentBreachCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'WHERE '
                + 'Breach_Status__c IN(\'Active Breach\', \'Wait For Student Action\') '
                + 'AND Breach_Name__c = \'' + programEnrollmentBreachCriteria.getBreach() + '\' '
                + 'AND Breach_Date__c >= ' + programEnrollmentBreachCriteria.getBreachDateFrom() + ' ' 
                + 'AND Breach_Date__c <= ' + programEnrollmentBreachCriteria.getBreachDateTo() + ' '
                + 'AND Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' '
                + 'AND Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' '
                + 'AND Program_Enrollment__r.Enrollment_Status__c IN (\'Admitted\', \'Leave of Absence\') '
                + 'AND Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  = \'' + programEnrollmentCriteria.getCategoryType() + '\' '
                + 'AND Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\'';
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
            ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
            String whereClauseString = ProgramEnrollmentBreachesDAO.newInstance().getWhereClauseByCriteria(programEnrollmentBreachCriteria, programEnrollmentCriteria, contactCriteria);
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
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);
            programEnrollmentCriteria.setCategoryType('Graduate Certificate');
            ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
            programEnrollmentBreachCriteria.setBreachStatus(ProgramEnrollmentBreachesDAO.STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH);
            programEnrollmentBreachCriteria.setBreach(mockIdGen.getMockId());
            programEnrollmentBreachCriteria.setExecutionDate(Date.today());
            programEnrollmentBreachCriteria.setBreachDateFrom(-10);
            programEnrollmentBreachCriteria.setBreachDateTo(10);

            String whereClauseString = ProgramEnrollmentBreachesDAO.newInstance().getContactQueryByCriteria(programEnrollmentBreachCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'SELECT Program_Enrollment__r.hed__Contact__c FROM Program_Enrollment_Breach__c WHERE '
                + 'Breach_Status__c IN(\'Active Breach\', \'Wait For Student Action\') '
                + 'AND Breach_Name__c = \'' + programEnrollmentBreachCriteria.getBreach() + '\' '
                + 'AND Breach_Date__c >= ' + programEnrollmentBreachCriteria.getBreachDateFrom() + ' ' 
                + 'AND Breach_Date__c <= ' + programEnrollmentBreachCriteria.getBreachDateTo() + ' '
                + 'AND Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' '
                + 'AND Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' '
                + 'AND Program_Enrollment__r.Enrollment_Status__c IN (\'Admitted\', \'Leave of Absence\') '
                + 'AND Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  = \'' + programEnrollmentCriteria.getCategoryType() + '\' '
                + 'AND Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\'';
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
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);
            programEnrollmentCriteria.setCategoryType('Graduate Certificate');
            ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
            programEnrollmentBreachCriteria.setBreachStatus(ProgramEnrollmentBreachesDAO.STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH);
            programEnrollmentBreachCriteria.setBreach(mockIdGen.getMockId());
            programEnrollmentBreachCriteria.setExecutionDate(Date.today());
            programEnrollmentBreachCriteria.setBreachDateFrom(-10);
            programEnrollmentBreachCriteria.setBreachDateTo(10);

            String whereClauseString = ProgramEnrollmentBreachesDAO.newInstance().getQueryByCriteria(programEnrollmentBreachCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'SELECT Id, Breach_Name__c, Breach_Status__c FROM Program_Enrollment_Breach__c WHERE '
                + 'Breach_Status__c IN(\'Active Breach\', \'Wait For Student Action\') '
                + 'AND Breach_Name__c = \'' + programEnrollmentBreachCriteria.getBreach() + '\' '
                + 'AND Breach_Date__c >= ' + programEnrollmentBreachCriteria.getBreachDateFrom() + ' ' 
                + 'AND Breach_Date__c <= ' + programEnrollmentBreachCriteria.getBreachDateTo() + ' '
                + 'AND Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' '
                + 'AND Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' '
                + 'AND Program_Enrollment__r.Enrollment_Status__c IN (\'Admitted\', \'Leave of Absence\') '
                + 'AND Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  = \'' + programEnrollmentCriteria.getCategoryType() + '\' '
                + 'AND Program_Enrollment__r.hed__Contact__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND Program_Enrollment__r.hed__Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND Program_Enrollment__r.hed__Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\'';
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

            Breach__c breachCreated = new Breach__c();
            insert breachCreated;
            
            List<Program_Enrollment_Breach__c> programEnrollmentBreachListCreated = TestDataFactory.createTestProgramEnrollmentBreachRecords(1);
            programEnrollmentBreachListCreated[0].Breach_Status__c = ProgramEnrollmentBreachesDAO.ACTIVE_BREACH_STATUS; 
            programEnrollmentBreachListCreated[0].Breach_Name__c = breachCreated.Id;
            programEnrollmentBreachListCreated[0].Breach_Date__c = Date.today();
            programEnrollmentBreachListCreated[0].Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            ProgramEnrollmentBreachesDAO.newInstance().insertRecords(programEnrollmentBreachListCreated,true,AccessLevel.SYSTEM_MODE);

            ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
            programEnrollmentBreachCriteria.setBreachStatus(ProgramEnrollmentBreachesDAO.STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH);
            programEnrollmentBreachCriteria.setBreach(breachCreated.Id);
            programEnrollmentBreachCriteria.setExecutionDate(Date.today());
            programEnrollmentBreachCriteria.setBreachDateFrom(-10);
            programEnrollmentBreachCriteria.setBreachDateTo(10);
            
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);
            programEnrollmentCriteria.setCategoryType('Graduate Certificate');

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
                        
            List<Program_Enrollment_Breach__c> programEnrollmentBreachList = ProgramEnrollmentBreachesDAO.newInstance()
                .findByCriteria(
                    programEnrollmentBreachCriteria,
                    programEnrollmentCriteria,
                    contactCriteria,
                    AccessLevel.USER_MODE
                );

            System.assertEquals(programEnrollmentBreachList.size(), programEnrollmentBreachListCreated.size(),  'programEnrollmentBreachList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void findByCriteriaNegativeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = false;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);

            List<hed__Program_Plan__c> programPlanListCreated = TestDataFactory.createTestProgramPlanRecords(1);
            programPlanListCreated[0].Category_Type__c = 'Graduate Certificate';
            ProgramPlansDAO.newInstance().insertRecords(programPlanListCreated,true,AccessLevel.SYSTEM_MODE);
    
            List<hed__Program_Enrollment__c> programEnrollmentListCreated = TestDataFactory.createTestProgramEnrollmentRecords(1);
            programEnrollmentListCreated[0].Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            programEnrollmentListCreated[0].Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_WITHDRAWN;
            programEnrollmentListCreated[0].Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            programEnrollmentListCreated[0].hed__Contact__c = contactList[0].Id;
            programEnrollmentListCreated[0].hed__Program_Plan__c = programPlanListCreated[0].Id;
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentListCreated,true,AccessLevel.SYSTEM_MODE);

            Breach__c breachCreated = new Breach__c();
            insert breachCreated;
            
            //Create a Program Enrollment Breach record to test negative scenario
            List<Program_Enrollment_Breach__c> programEnrollmentBreachListCreated = TestDataFactory.createTestProgramEnrollmentBreachRecords(1);
            programEnrollmentBreachListCreated[0].Breach_Status__c = ProgramEnrollmentBreachesDAO.BREACH_RESOLVED_STATUS; 
            programEnrollmentBreachListCreated[0].Breach_Name__c = breachCreated.Id;
            programEnrollmentBreachListCreated[0].Breach_Date__c = Date.today();
            programEnrollmentBreachListCreated[0].Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            ProgramEnrollmentBreachesDAO.newInstance().insertRecords(programEnrollmentBreachListCreated,true,AccessLevel.SYSTEM_MODE);

            ProgramEnrollmentBreachesDAO.Criteria programEnrollmentBreachCriteria = new ProgramEnrollmentBreachesDAO.Criteria();
            programEnrollmentBreachCriteria.setBreachStatus(ProgramEnrollmentBreachesDAO.STATUSES_FOR_PROGRAM_ENROLLMENT_BREACH);
            programEnrollmentBreachCriteria.setBreach(breachCreated.Id);
            programEnrollmentBreachCriteria.setExecutionDate(Date.today());
            programEnrollmentBreachCriteria.setBreachDateFrom(-10);
            programEnrollmentBreachCriteria.setBreachDateTo(10);
            
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);
            programEnrollmentCriteria.setCategoryType('Graduate Certificate');

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(true);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
                        
            List<Program_Enrollment_Breach__c> programEnrollmentBreachList = ProgramEnrollmentBreachesDAO.newInstance()
                .findByCriteria(
                    programEnrollmentBreachCriteria,
                    programEnrollmentCriteria,
                    contactCriteria,
                    AccessLevel.USER_MODE
                );

            System.assert(programEnrollmentBreachList.isEmpty(), 'Program Enrollment Breach record should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void criteriaIsEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            ProgramEnrollmentBreachesDAO.Criteria criteria = new ProgramEnrollmentBreachesDAO.Criteria();
            System.assert(criteria.isEmpty(), 'Criteria should be empty.');
        }
        Test.stopTest();
    }
}
