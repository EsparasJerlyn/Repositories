/**
 * @description Test Class for LeaveOfAbsencesDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | gabriel.p.ventayen             | April 30, 2024        | DEPP-8041              | Created file                                   |
 *    | eugene.andrew.abuan            | May 20, 2024          | DEPP-8801              | Changes for Category Type                      |
 */
@isTest
public with sharing class LeaveOfAbsencesDAOTest {
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
                new LeaveOfAbsencesDAO().getSObjectType() == Leave_of_Absence__c.SObjectType,
                'SObject is not Leave_of_Absence__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getWhereClauseByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);
            Id contactId = mockIdGen.getMockId();

            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setIsQUTStudent(false);
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setContactIdSet(new Set<Id>{contactId});
            contactCriteria.setCitizenshipStatus(ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL);

            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setPreviousAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);
            programEnrollmentCriteria.setCategoryType(new List<String>{'Graduate Certificate'});
            
            LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
            leaveOfAbsenceCriteria.setIsOnleave(true);
            leaveOfAbsenceCriteria.setEndDateFrom(Date.today().addDays(-10));
            leaveOfAbsenceCriteria.setEndDateTo(Date.today().addDays(10));

            String whereClauseString = LeaveOfAbsencesDAO.newInstance().getWhereClauseByCriteria(leaveOfAbsenceCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'WHERE '
                + 'Is_On_Leave__c = ' + leaveOfAbsenceCriteria.getIsOnLeave() + ' '
                + 'AND End_Date__c <= ' + DynamicQueryService.convertDatetoDateString(leaveOfAbsenceCriteria.getEndDateFrom()) + ' ' 
                + 'AND End_Date__c >= ' + DynamicQueryService.convertDatetoDateString(leaveOfAbsenceCriteria.getEndDateTo()) + ' '
                + 'AND hed_Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' '
                + 'AND hed_Program_Enrollment__r.Previous_Academic_Status__c = \'' + programEnrollmentCriteria.getPreviousAcademicStatus() + '\' '
                + 'AND hed_Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' '
                + 'AND hed_Program_Enrollment__r.Enrollment_Status__c IN (\'Admitted\', \'Leave of Absence\') '
                + 'AND hed_Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  IN ('+ DynamicQueryService.formatStringSetForWhereClause(new Set<String>(programEnrollmentCriteria.getCategoryType())) + ') '
                + 'AND Student__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND Student__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND Student__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' '
                + 'AND Student__r.Id IN ('+ DynamicQueryService.formatStringSetForWhereClause(contactCriteria.getContactIdSet()) + ')';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void getWhereClauseByNoCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
            String whereClauseString = LeaveOfAbsencesDAO.newInstance().getWhereClauseByCriteria(leaveOfAbsenceCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = '';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void getContactQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

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
            programEnrollmentCriteria.setCategoryType(new List<String>{'Graduate Certificate'});
            
            LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
            leaveOfAbsenceCriteria.setIsOnleave(true);
            leaveOfAbsenceCriteria.setEndDateFrom(Date.today().addDays(-10));
            leaveOfAbsenceCriteria.setEndDateTo(Date.today().addDays(10));

            String whereClauseString = LeaveOfAbsencesDAO.newInstance().getContactQueryByCriteria(leaveOfAbsenceCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'SELECT Student__c FROM Leave_Of_Absence__c WHERE '
                + 'Is_On_Leave__c = ' + leaveOfAbsenceCriteria.getIsOnLeave() + ' '
                + 'AND End_Date__c <= ' + DynamicQueryService.convertDatetoDateString(leaveOfAbsenceCriteria.getEndDateFrom()) + ' ' 
                + 'AND End_Date__c >= ' + DynamicQueryService.convertDatetoDateString(leaveOfAbsenceCriteria.getEndDateTo()) + ' '
                + 'AND hed_Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' '
                + 'AND hed_Program_Enrollment__r.Previous_Academic_Status__c = \'' + programEnrollmentCriteria.getPreviousAcademicStatus() + '\' '
                + 'AND hed_Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' '
                + 'AND hed_Program_Enrollment__r.Enrollment_Status__c IN (\'Admitted\', \'Leave of Absence\') '
                + 'AND hed_Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  IN ('+ DynamicQueryService.formatStringSetForWhereClause(new Set<String>(programEnrollmentCriteria.getCategoryType())) + ') '
                + 'AND Student__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND Student__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND Student__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' '
                + 'AND Student__r.Id IN ('+ DynamicQueryService.formatStringSetForWhereClause(contactCriteria.getContactIdSet()) + ')';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void getQueryByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

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
            programEnrollmentCriteria.setCategoryType(new List<String>{'Graduate Certificate'});
            
            LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
            leaveOfAbsenceCriteria.setIsOnleave(true);
            leaveOfAbsenceCriteria.setEndDateFrom(Date.today().addDays(-10));
            leaveOfAbsenceCriteria.setEndDateTo(Date.today().addDays(10));

            String whereClauseString = LeaveOfAbsencesDAO.newInstance().getQueryByCriteria(leaveOfAbsenceCriteria, programEnrollmentCriteria, contactCriteria);
            String expectedWhereClause = 'SELECT ' 
                + ' Id, Student__c, Name, Is_On_Leave__c, End_Date__c, ' 
                + ' hed_Program_Enrollment__r.Academic_Status__c, hed_Program_Enrollment__r.Previous_Academic_Status__c, hed_Program_Enrollment__r.Enrollment_Stage__c, hed_Program_Enrollment__r.Enrollment_Status__c, ' 
                + ' Student__r.hed__Citizenship_Status__c, Student__r.QUT_Student__c, Student__r.RecordType.DeveloperName ' 
                + ' FROM Leave_Of_Absence__c WHERE ' +
                + 'Is_On_Leave__c = ' + leaveOfAbsenceCriteria.getIsOnLeave() + ' '
                + 'AND End_Date__c <= ' + DynamicQueryService.convertDatetoDateString(leaveOfAbsenceCriteria.getEndDateFrom()) + ' ' 
                + 'AND End_Date__c >= ' + DynamicQueryService.convertDatetoDateString(leaveOfAbsenceCriteria.getEndDateTo()) + ' '
                + 'AND hed_Program_Enrollment__r.Academic_Status__c = \'' + programEnrollmentCriteria.getAcademicStatus() + '\' '
                + 'AND hed_Program_Enrollment__r.Previous_Academic_Status__c = \'' + programEnrollmentCriteria.getPreviousAcademicStatus() + '\' '
                + 'AND hed_Program_Enrollment__r.Enrollment_Stage__c = \'' + programEnrollmentCriteria.getEnrollmentStage() + '\' '
                + 'AND hed_Program_Enrollment__r.Enrollment_Status__c IN (\'Admitted\', \'Leave of Absence\') '
                + 'AND hed_Program_Enrollment__r.hed__Program_Plan__r.Category_Type__c  IN ('+ DynamicQueryService.formatStringSetForWhereClause(new Set<String>(programEnrollmentCriteria.getCategoryType())) + ') '
                + 'AND Student__r.hed__Citizenship_Status__c = \'' + contactCriteria.getCitizenshipStatus() + '\' '
                + 'AND Student__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' '
                + 'AND Student__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' '
                + 'AND Student__r.Id IN ('+ DynamicQueryService.formatStringSetForWhereClause(contactCriteria.getContactIdSet()) + ')';
            System.assertEquals(expectedWhereClause, whereClauseString, 'Incorrect Where Clause');
        }
        Test.stopTest();
    }

    @isTest
    static void findByCriteriaTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
    
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

            List<Leave_of_Absence__c> leaveOfAbsenceListCreated = TestDataFactory.createLeaveOfAbsenceRecord(1);
            leaveOfAbsenceListCreated[0].Start_Date__c = Date.today().addDays(-1); 
            leaveOfAbsenceListCreated[0].End_Date__c = Date.today().addDays(1); 
            leaveOfAbsenceListCreated[0].hed_Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            leaveOfAbsenceListCreated[0].Leave_No__c = 001;
            leaveOfAbsenceListCreated[0].Student__c = contactList[0].Id;
            LeaveOfAbsencesDAO.newInstance().insertRecords(leaveOfAbsenceListCreated,true,AccessLevel.SYSTEM_MODE);

            LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
            leaveOfAbsenceCriteria.setIsOnleave(true);
            leaveOfAbsenceCriteria.setEndDateFrom(Date.today().addDays(10));
            leaveOfAbsenceCriteria.setEndDateTo(Date.today().addDays(-10));
            
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setPreviousAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);
            programEnrollmentCriteria.setCategoryType(new List<String>{'Graduate Certificate'});



            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setIsQUTStudent(true);
            
            List<Leave_of_Absence__c> leaveOfAbsenceList = LeaveOfAbsencesDAO.newInstance()
                .findByCriteria(
                    leaveOfAbsenceCriteria,
                    programEnrollmentCriteria,
                    contactCriteria,
                    AccessLevel.USER_MODE
                );
            System.assertEquals(leaveOfAbsenceList.size(), leaveOfAbsenceListCreated.size(),  'leaveOfAbsenceList should not be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void findByCriteriaNegativeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
    
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

            //Create leave of absence record to test negative scenarios
            List<Leave_of_Absence__c> leaveOfAbsenceListCreated = TestDataFactory.createLeaveOfAbsenceRecord(1);
            leaveOfAbsenceListCreated[0].Start_Date__c = null; 
            leaveOfAbsenceListCreated[0].End_Date__c = null; 
            leaveOfAbsenceListCreated[0].hed_Program_Enrollment__c = programEnrollmentListCreated[0].Id;
            leaveOfAbsenceListCreated[0].Leave_No__c = 001;
            leaveOfAbsenceListCreated[0].Student__c = contactList[0].Id;
            LeaveOfAbsencesDAO.newInstance().insertRecords(leaveOfAbsenceListCreated,true,AccessLevel.SYSTEM_MODE);

            LeaveOfAbsencesDAO.Criteria leaveOfAbsenceCriteria = new LeaveOfAbsencesDAO.Criteria();
            leaveOfAbsenceCriteria.setIsOnleave(true);
            leaveOfAbsenceCriteria.setEndDateFrom(Date.today().addDays(-10));
            leaveOfAbsenceCriteria.setEndDateTo(Date.today().addDays(10));
            
            ProgramEnrollmentsDAO.Criteria programEnrollmentCriteria = new ProgramEnrollmentsDAO.Criteria();
            programEnrollmentCriteria.setAcademicStatus(ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE);
            programEnrollmentCriteria.setEnrollmentStage(ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED);
            programEnrollmentCriteria.setEnrollmentStatus(ELCProgramEnrollmentParser.ENROLLMENT_STATUS_FOR_OUTREACH);
            programEnrollmentCriteria.setCategoryType(new List<String>{'Graduate Certificate'});



            ContactsDAO.Criteria contactCriteria = new ContactsDAO.Criteria();
            contactCriteria.setRecordType(ContactsDAO.PERSON_RECORDTYPE);
            contactCriteria.setIsQUTStudent(true);
            
            List<Leave_of_Absence__c> leaveOfAbsenceList = LeaveOfAbsencesDAO.newInstance()
                .findByCriteria(
                    leaveOfAbsenceCriteria,
                    programEnrollmentCriteria,
                    contactCriteria,
                    AccessLevel.USER_MODE
                );
            System.assert(leaveOfAbsenceList.isEmpty(),  'Leave Of Absence record should be empty.');
        }
        Test.stopTest();
    }

    @isTest
    static void criteriaIsEmptyTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            LeaveOfAbsencesDAO.Criteria criteria = new LeaveOfAbsencesDAO.Criteria();
            System.assert(criteria.isEmpty(), 'Criteria should be empty.');
        }
        Test.stopTest();
    }
}