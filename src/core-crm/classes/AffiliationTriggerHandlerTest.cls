/**
 * @description Test Class for AffiliationTriggerHander
 *
 * @see AffiliationTriggerHander
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | July 18,2023          | DEPP-5799    | Created file                                |
*/
@isTest
private class AffiliationTriggerHandlerTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator' });      
        System.runAs(TestDataFactory.getProgramAdminUser()) {  
            Account acc = TestDataFactory.createTestAccount(false);
            acc.RecordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID;
            insert acc;
            
            List<hed__Affiliation__c> affliatedContacts = TestDataFactory.createTestAffliatedContactRecords(1, acc.Id);           
            insert affliatedContacts;
        }
    }
    
    @isTest
    private static void testAffiliationWithContact() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {            
            Account acc = TestDataFactory.createTestAccount(false);
            acc.RecordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID;
            insert acc;
            
            List<Contact> newContacts = createTestContactRecords(0, 1);     
            newContacts[0].AccountId = acc.Id;
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);

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
        System.runAs(TestDataFactory.getProgramAdminUser()) {   
            
            List<Contact> newContacts = createTestContactRecords(0, 1);     
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
			List<hed__Affiliation__c> updateAffliatedContacts = [SELECT Id FROM hed__Affiliation__c]; 	
            updateAffliatedContacts[0].hed__Contact__c = newContacts[0].Id;
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(updateAffliatedContacts);
            Test.stopTest();
            
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }
        }
    }  
    
    @isTest
    private static void testAffiliationWithOutContact() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {            
            Account acc = TestDataFactory.createTestAccount(false);
            acc.RecordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID;
            insert acc;
            
            List<hed__Affiliation__c> affliatedContacts = TestDataFactory.createTestAffliatedContactRecords(1, acc.Id);            
            insert affliatedContacts;
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(affliatedContacts);
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
}