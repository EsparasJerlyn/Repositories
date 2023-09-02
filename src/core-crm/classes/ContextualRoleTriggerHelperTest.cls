/**
 * @description Test Class for ContextualRoleTriggerHelper
 *
 * @see ApplicationService
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | July 23,2023          | DEPP-5799    | Created file                                |
*/
@isTest
private class ContextualRoleTriggerHelperTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }
    
    @isTest
    private static void testContextualRolesWithContactAndOpportunity() {
        
        System.runAs(TestDataFactory.getProgramAdminUser()) {            
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
        
        System.runAs(TestDataFactory.getProgramAdminUser()) {            
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