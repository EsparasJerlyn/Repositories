/**
 * @description Test Class for ProgramEnrollmentTriggerHandler
 *
 * @see ProgramEnrollmentTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | July 23,2023          | DEPP-5799    | Created file                                |
*/
@isTest
private class ProgramEnrollmentTriggerHandlerTest {
    
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> newContacts = createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Database.SaveResult[] srList = Database.insert(createTestProgramEnrollmentRecords(newContacts,'Admitted'));
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }

    
    @isTest
    private static void testProgramEnrollmentWithContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> newContacts = createTestContactRecords(0, 1);            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(createTestProgramEnrollmentRecords(newContacts,'Admitted'));
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }
    
    @isTest
    private static void testProgramUpdateRemoveContact() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            Id contactId = ContactsDAO.newInstance().getPersonContactsWithLimit(1).iterator().next()?.Id;                
            List<hed__Program_Enrollment__c> existingProgramEnrollmentList = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =:contactId]; 
            
            for(hed__Program_Enrollment__c app: existingProgramEnrollmentList){                           
                app.hed__Contact__c = null;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(existingProgramEnrollmentList,false);
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
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
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