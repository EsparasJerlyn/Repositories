/**
 * @description Test Class for ContactPersonaFlagsService
 *
 * @see ApplicationService
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | July 18,2023          | DEPP-5799    | Created file                                |
*/
@isTest
private class ContactPersonaFlagsServiceTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
     
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    private static void testApplicationWithContactPositive() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> newContacts = createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(
                    createTestApplicationStudyLinkRecords(newContacts,'Existing'),
                    false,
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }
    
    @isTest
    private static void testApplicationWithContactNegative() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> newContacts = createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(
                    createTestApplicationStudyLinkRecords(newContacts,'Withdrawn'),
                    true,
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }
    
    @isTest
    private static void testProgramEnrollmentWithContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> newContacts = createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(createTestProgramEnrollmentRecords(newContacts,'Admitted'));
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }
    
    @isTest
    private static void testProgramEnrollmentWithContactChangedContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> newContacts = createTestContactRecords(0, 2);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            List<hed__Program_Enrollment__c> newProgramEnrollments = createTestProgramEnrollmentRecords(newContacts,'Admitted');
            ProgramEnrollmentsDAO.newInstance().insertRecords(newProgramEnrollments, false, AccessLevel.USER_MODE);
            for(hed__Program_Enrollment__c pe: newProgramEnrollments){
                pe.hed__Contact__c = newContacts[1].Id;
            } 
            Test.startTest();
            Database.SaveResult[] srList = Database.update(newProgramEnrollments);
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }
        }
    }

    @isTest
    private static void testProgramEnrollmentWithCourseConnection() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> newContacts = createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            List<hed__Program_Enrollment__c> programEnrollmentList = createTestProgramEnrollmentRecords(newContacts,'Admitted');
            insert programEnrollmentList;
            
            List<hed__Course_Enrollment__c> courseConnectionRecord = new List<hed__Course_Enrollment__c>();
            for (Integer i = 0; i < 1; i++) {
                courseConnectionRecord.add(
                    new hed__Course_Enrollment__c(
                        hed__Contact__c = newContacts[0].Id,
                        Enrollment_Status__c = 'Active',
                        hed__Program_Enrollment__c = programEnrollmentList[0].Id
                    )
                );
            }

            insert courseConnectionRecord;

            
            for (hed__Program_Enrollment__c programEnrollment : programEnrollmentList){
                programEnrollment.Enrollment_Status__c = 'Admitted';
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(programEnrollmentList);
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }
        }
    }

    @isTest
    private static void testProgramEnrollmentToWithdrawn() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> newContacts = createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, true, AccessLevel.USER_MODE);
            

            List<hed__Program_Enrollment__c> programEnrollmentList = createTestProgramEnrollmentRecords(newContacts,'Admitted');
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList, true, AccessLevel.USER_MODE);
            
            List<hed__Course_Enrollment__c> courseConnectionRecord = new List<hed__Course_Enrollment__c>();
            for (Integer i = 0; i < 1; i++) {
                courseConnectionRecord.add(
                    new hed__Course_Enrollment__c(
                        hed__Contact__c = newContacts[0].Id,
                        Enrollment_Status__c = 'Active',
                        hed__Program_Enrollment__c = programEnrollmentList[0].Id
                    )
                );
            }

            CourseConnectionsDAO.newInstance().insertRecords(courseConnectionRecord, true, AccessLevel.USER_MODE);

            
            for (hed__Program_Enrollment__c programEnrollment : programEnrollmentList){
                programEnrollment.Enrollment_Status__c = 'Withdrawn';
            }
            
            Test.startTest();
            ProgramEnrollmentsDAO.newInstance().updateRecords(programEnrollmentList, true, AccessLevel.USER_MODE);
            Test.stopTest();

            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(1)){
                System.assert(String.isBlank(record.Future_Student_Journey_Status__c),'Record Future_Student_Journey_Status__c did not match');
            }
        }
    }


    @isTest
    private static void testProgramEnrollmentToWithdrawnWithApplyApplication() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> newContacts = createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, true, AccessLevel.USER_MODE);

            List<hed__Application__c> newApplications = createTestApplicationStudyLinkRecords(newContacts,'Apply');
            newApplications.addAll(createTestApplicationStudyLinkRecords(newContacts,'Apply'));

            ApplicationsDAO.newInstance().insertRecords(newApplications,false,AccessLevel.USER_MODE);

            List<hed__Program_Enrollment__c> programEnrollmentList = createTestProgramEnrollmentRecords(newContacts,'Admitted');
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList, true, AccessLevel.USER_MODE);
            
            List<hed__Course_Enrollment__c> courseConnectionRecord = new List<hed__Course_Enrollment__c>();
            for (Integer i = 0; i < 1; i++) {
                courseConnectionRecord.add(
                    new hed__Course_Enrollment__c(
                        hed__Contact__c = newContacts[0].Id,
                        Enrollment_Status__c = 'Active',
                        hed__Program_Enrollment__c = programEnrollmentList[0].Id
                    )
                );
            }

            CourseConnectionsDAO.newInstance().insertRecords(courseConnectionRecord, true, AccessLevel.USER_MODE);

            
            for (hed__Program_Enrollment__c programEnrollment : programEnrollmentList){
                programEnrollment.Enrollment_Status__c = 'Withdrawn';
            }
            
            Test.startTest();
            ProgramEnrollmentsDAO.newInstance().updateRecords(programEnrollmentList, true, AccessLevel.USER_MODE);
            Test.stopTest();

            for(Contact record: ContactsDAO.newInstance().getPersonContactsWithLimit(1)){
                System.assert(record.Future_Student_Journey_Status__c == 'Apply','Record Future_Student_Journey_Status__c did not match');
            }
        }
    }
    
    @isTest
    private static void testAffiliationWithContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {            
            Account acc = TestDataFactory.createTestAccount(false);
            acc.RecordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID;
            insert acc;
            
            List<Contact> newContacts = createTestContactRecords(0, 1);     
            newContacts[0].AccountId = acc.Id;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);

            List<hed__Affiliation__c> affliatedContacts = TestDataFactory.createTestAffliatedContactRecords(1, acc.Id);
            affliatedContacts[0].hed__Contact__c = newContacts[0].Id;
            
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(affliatedContacts);
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }    
    
    @isTest
    private static void testUpdateAffiliationWithContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {            
            Account acc = TestDataFactory.createTestAccount(false);
            acc.RecordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID;
            insert acc;
            
            List<Contact> newContacts = createTestContactRecords(0, 1);     
            newContacts[0].AccountId = acc.Id;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            List<hed__Affiliation__c> affliatedContacts = TestDataFactory.createTestAffliatedContactRecords(1, acc.Id);            
            insert affliatedContacts;
            
            Test.startTest();
            affliatedContacts[0].hed__Contact__c = newContacts[0].Id;            
            Database.SaveResult[] srList = Database.update(affliatedContacts);
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }
        }
    }  
    
    @isTest
    private static void testAffiliationWithOpportunity() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {            
            Account acc = TestDataFactory.createTestAccount(false);
            acc.RecordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID;
            insert acc;
            
            List<Contact> newContacts = createTestContactRecords(0, 1);     
            newContacts[0].AccountId = acc.Id;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            List<Opportunity> createTestOpportunityRecords = TestDataFactory.createTestOpportunityRecords(1,acc.Id,newContacts[0].Id);
            insert createTestOpportunityRecords;
            
            List<hed__Affiliation__c> affliatedContacts = TestDataFactory.createTestAffliatedContactRecords(1, acc.Id);
            affliatedContacts[0].hed__Contact__c = newContacts[0].Id;
            
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(affliatedContacts);
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }  
    
    @isTest
    private static void testContextualRolesWithContactAndOpportunity() {
        
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {            
            Account acc = TestDataFactory.createTestAccount(false);
            acc.RecordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID;
            insert acc;
            
            List<Contact> newContacts = createTestContactRecords(0, 1);     
            newContacts[0].AccountId = acc.Id;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            List<Opportunity> opportunityRecords = TestDataFactory.createTestOpportunityRecords(1,acc.Id,newContacts[0].Id);
            insert opportunityRecords;            
            List<Contextual_Role__c> contextualRoleList = TestDataFactory.createContextualRolesForOpportunity(1,
                                                                                                              ContextualRolesDAO.OPPORTUNITY_ROLE_RECTYPE_ID,
                                                                                                              opportunityRecords[0].Id,
                                                                                                              acc.Id,
                                                                                                              'Partners'
                                                                                                             );
            contextualRoleList[0].Contact__c = newContacts[0].Id;
            
            List<hed__Affiliation__c> affliatedContacts = TestDataFactory.createTestAffliatedContactRecords(1, acc.Id);
            affliatedContacts[0].hed__Contact__c = newContacts[0].Id;
            
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(contextualRoleList);
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    } 

    @isTest
    private static void testContextualRolesWithAffiliation() {
        
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {            
            Account acc = TestDataFactory.createTestAccount(false);
            acc.RecordTypeId = AccountsDAO.ACCT_UNIV_DEP_ID;
            insert acc;
            
            List<Contact> newContacts = createTestContactRecords(0, 1);     
            newContacts[0].AccountId = acc.Id;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.USER_MODE);
            
            List<Opportunity> opportunityRecords = TestDataFactory.createTestOpportunityRecords(1,acc.Id,newContacts[0].Id);
            insert opportunityRecords;            
            List<Contextual_Role__c> contextualRoleList = TestDataFactory.createContextualRolesForOpportunity(1,
                                                                                                              ContextualRolesDAO.OPPORTUNITY_ROLE_RECTYPE_ID,
                                                                                                              opportunityRecords[0].Id,
                                                                                                              acc.Id,
                                                                                                              'Partners'
                                                                                                             );
            contextualRoleList[0].Contact__c = newContacts[0].Id;
            
            Account acc1 = TestDataFactory.createTestAccount(false);
            acc1.RecordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID;
            insert acc1;
            
            List<hed__Affiliation__c> affliatedContacts = TestDataFactory.createTestAffliatedContactRecords(1, acc1.Id);
            affliatedContacts[0].hed__Contact__c = newContacts[0].Id;
            insert affliatedContacts;
            
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(contextualRoleList);
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    } 
    
    private static List<hed__Application__c> createTestApplicationStudyLinkRecords(List<Contact> conList, String applicationStatus) {
        List<hed__Application__c> newApplications = new List<hed__Application__c>();
        for (Contact con: conList) {
            newApplications.add(
                new hed__Application__c(
                    FirstName__c = 'Test First' + FIRSTNAME,
                    LastName__c = 'Test Last' + LASTNAME,
                    BirthDate__c = Date.valueOf(BIRTHDAY),
                    Email__c = 'workTest' + EMAIL,
                    Application_Status__c = applicationStatus,
                    hed__Applicant__c = con.Id,
                    RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID,
                    Calculated_Intake_Date__c = System.Today()
                )
            );
        }
        return newApplications;
    }
    
    private static List<Contact> createTestContactRecords(
        Integer startAtCount,
        Integer endBeforeCount
    ) {
        List<Contact> newContacts = new List<Contact>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newContacts.add(
                new Contact(
                    FirstName = FIRSTNAME + i,
                    LastName = i + LASTNAME,
                    BirthDate = Date.valueOf(BIRTHDAY),
                    Email = i + EMAIL,
                    QUT_Learner_Email__c = 'learner' + i + EMAIL,
                    QUT_Staff_Email__c = 'staff' + i + EMAIL,
                    Work_Email__c = 'work' + i + EMAIL,
                    hed__Preferred_Email__c = 'Alternate Email',
                    hed__AlternateEmail__c = i + EMAIL,
                    RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID 
                )
            );
        }
        return newContacts;
    }
    
    private static List<hed__Program_Enrollment__c> createTestProgramEnrollmentRecords(List<Contact> conList, String enrollmentStatus) {
        List<hed__Program_Enrollment__c> newProgramEnrollments= new List<hed__Program_Enrollment__c>();
        
        for (Contact con: conList) {
            newProgramEnrollments.add(
                new hed__Program_Enrollment__c(
                    Enrollment_Status__c = enrollmentStatus,
                    hed__Contact__c = con.Id
                )
            );
        }
        return newProgramEnrollments;
    }
}