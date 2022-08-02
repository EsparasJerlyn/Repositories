/**
 * @description Test Class for LeadDuplicatesHelper
 *
 * @see LeadDuplicatesHelper
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | angelika.j.s.galang       | May 27, 2022          | DEPP-1455    | Created file                                |
      | alexander.cadalin         | June 22, 2022         | DEPP-3056    | leadDuplicateEmailsTestOnInsert             |
      |                           | June 24, 2022         | DEPP-3056    | removed global dupes handler tests          |
      |                           |                       |              | Copy from LeadTriggerHandlerTest            |
      |                           | July 30, 2022         | DEPP-3623    | Complete rework                             |
*/
@IsTest(SeeAllData = false)
private class ContactDuplicatesHelperTest {    
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String QUTEX = System.Label.QUTeX;
    private static final String CONTACT_RT_PERSON_CONTACT_NAME = System.Label.RT_Contact_Person;
    private static final Id CONTACT_RT_PERSON_CONTACT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONTACT_RT_PERSON_CONTACT_NAME).getRecordTypeId();
    private static Integer recordsCount = 20;
    
    @testSetup static void setup() {
        TestDataFactory.generateTestUsers();
        System.runAs(TestDataFactory.getProgramAdminUser()){
            Test.startTest();
            insert createTestContactRecords(0, recordsCount);
            Test.stopTest();
        }
    }
    
    /** TEST INSERT CONTACTS **/
    
    @isTest private static void testSingleInsertNoDuplicateEmail() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(createTestContactRecords(recordsCount, recordsCount + 1), false);
            Test.stopTest();
            
            System.assert(srList[0].isSuccess(), 'The record was not saved.');
        }
    }
    
    @isTest private static void testSingleInsertDuplicatesExisting() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(createTestContactRecords(0, 1), false);
            Test.stopTest();
            
            System.assert(!srList[0].isSuccess(), 'The record was saved.');
        }
    }
    
    @isTest private static void testSingleInsertCrossFieldsDuplicatesExisting() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> conList = new List<Contact>();
            conList.add(
            	new Contact(
                    LastName = 'Pepperoni',
                    Email = 'work' + randomInt(recordsCount) + EMAIL,
                    QUT_Learner_Email__c = randomInt(recordsCount) + EMAIL,
                    QUT_Staff_Email__c = 'learner' + randomInt(recordsCount) + EMAIL,
                    Work_Email__c = 'staff' + randomInt(recordsCount) + EMAIL
                )
            );
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(conList, false);
           	Test.stopTest();
            
            System.assert(!srList[0].isSuccess(), 'The record was saved.');
        }
    }
    
    @isTest private static void testBatchInsertNoDuplicates() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(createTestContactRecords(recordsCount, recordsCount * 2), false);
            Test.stopTest();
            
            for(Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }
    
    @isTest private static void testBatchInsertEachDuplicatesExisting() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(createTestContactRecords(0, recordsCount), false);
            Test.stopTest();
            
            for(Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }
    
	@isTest private static void testBatchInsertDuplicatesWithinBatch() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> newContacts = createTestContactRecords(0, recordsCount);
            for(Contact con : newContacts) {
                con.Email = EMAIL;
                con.QUT_Learner_Email__c = 'learner' + EMAIL;
                con.QUT_Staff_Email__C = 'staff' + EMAIL;
                con.Work_Email__c = 'work' + EMAIL;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(newContacts, false);
            Test.stopTest();
            
            for(Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }

    @isTest private static void testBatchInsertPartialDuplicatesExisting() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> newContacts = new List<Contact>();
            newContacts.addAll(createTestContactRecords(0, recordsCount / 2));
            newContacts.addAll(createTestContactRecords(recordsCount, recordsCount + (recordsCount / 2)));
            
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(newContacts, false);
            Test.stopTest();
            
            Integer rejected = 0;
            Integer saved = 0;
            for(Database.SaveResult sr : srList) {
                if(sr.isSuccess())
                    saved += 1;
                else 
                    rejected += 1;
            }
            System.assert(saved == newContacts.size() / 2, 'There are ' + saved + ' records saved out of ' + newContacts.size() / 2);
            System.assert(rejected == newContacts.size() / 2, 'There are ' + rejected + ' records rejected out of ' + newContacts.size() / 2);
        }
    }
    
    @isTest private static void testBatchInsertPartialDuplicatesWithinBatch() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> newContacts = createTestContactRecords(recordsCount, recordsCount * 2);
            for(Integer i = 0; i < recordsCount / 2; i++) {
                newContacts[i].Email = 'dupe' + EMAIL;
                newContacts[i].QUT_Learner_Email__c = 'dupelearner' + EMAIL;
                newContacts[i].QUT_Staff_Email__c = 'dupestaff' + EMAIL;
                newContacts[i].Work_Email__c = 'dupework' + EMAIL;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(newContacts, false);
            Test.stopTest();
            
            Integer rejected = 0;
            Integer saved = 0;
            for(Database.SaveResult sr : srList) {
                if(sr.isSuccess())
                    saved += 1;
                else 
                    rejected += 1;
            }
            System.assert(saved == (recordsCount / 2) + 1, 'There are ' + saved + ' records saved out of ' + recordsCount / 2);
            System.assert(rejected == (recordsCount / 2) - 1, 'There are ' + rejected + ' records rejected out of ' + recordsCount / 2);
        }    
    }
    
    @isTest private static void testBatchInsertDuplicatesWithinAndExisting() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> newContacts = createTestContactRecords(0, recordsCount);
            for(Integer i = 0; i < recordsCount / 2; i++) {
                newContacts[i].Email = EMAIL;
                newContacts[i].QUT_Learner_Email__c = 'learner' + EMAIL;
                newContacts[i].QUT_Staff_Email__c = 'staff' + EMAIL;
                newContacts[i].Work_Email__c = 'work' + EMAIL;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(newContacts, false);
            Test.stopTest();
            
            Boolean firstInserted = true;
            for(Database.SaveResult sr : srList) {
                if(!firstInserted) { // the first record should save because it doesn't exist yet even though it 
                	System.assert(!sr.isSuccess(), 'A record was saved.');
                }
                firstInserted = false;
            }
        }
    }
    
    /** TEST UPDATE LEADS **/
    
    @isTest private static void testSingleUpdateNoDuplicateEmail() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> conList = [
                SELECT
                	Id,
                	LastName,
                    Email,
                    QUT_Learner_Email__c,
                    QUT_Staff_Email__c,
                    Work_Email__c,
                    hed__Preferred_Email__c,
                    hed__AlternateEmail__c
                FROM Contact WHERE RecordTypeId = :CONTACT_RT_PERSON_CONTACT_ID LIMIT 1
            ];
            conList[0].Email = 'nodupeemail@mail.test';
            conList[0].QUT_Learner_Email__c = 'nodupelearneremail@mail.test';
            conList[0].QUT_Staff_Email__c = 'nodupestaffemail@mal.test';
            conList[0].Work_Email__c = 'nodupeworkemail@mail.test';
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(conList, false);
            Test.stopTest();
            
            System.assert(srList[0].isSuccess(), 'The record was not saved.');
        }
    }
    
    @isTest private static void testSingleUpdateDuplicatesExisting() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> conList = [
                SELECT
                	Id,
                	LastName,
                    Email,
                    QUT_Learner_Email__c,
                    QUT_Staff_Email__c,
                    Work_Email__c,
                    hed__Preferred_Email__c,
                    hed__AlternateEmail__c
                FROM Contact WHERE RecordTypeId = :CONTACT_RT_PERSON_CONTACT_ID LIMIT 2
            ];
            conList[0].Email = conList[1].Email;
            conList[0].QUT_Learner_Email__c = conList[1].QUT_Learner_Email__c;
            conList[0].QUT_Staff_Email__c = conList[1].QUT_Staff_Email__c;
            conList[0].Work_Email__c = conList[1].Work_Email__c;
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(conList, false);
            Test.stopTest();
            
            System.assert(!srList[0].isSuccess(), 'The record was saved.');
        }
    }
	
	@isTest private static void testSingleUpdateCrossFieldsDuplicatesExisting() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> conList = [
                SELECT
                	Id,
                	LastName,
                    Email,
                    QUT_Learner_Email__c,
                    QUT_Staff_Email__c,
                    Work_Email__c,
                    hed__Preferred_Email__c,
                    hed__AlternateEmail__c
                FROM Contact WHERE RecordTypeId = :CONTACT_RT_PERSON_CONTACT_ID LIMIT 2
            ];
            conList[0].Email = conList[1].QUT_Learner_Email__c;
            conList[0].QUT_Learner_Email__c = conList[1].QUT_Staff_Email__c;
            conList[0].QUT_Staff_Email__c = conList[1].Work_Email__c;
            conList[0].Work_Email__c = conList[1].Email;
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(conList, false);
            Test.stopTest();
            
            System.assert(!srList[0].isSuccess(), 'The record was saved.');
        }
    }
    
    @isTest private static void testBatchUpdateNoDuplicates() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> conList = [
                SELECT
                	Id,
                	LastName,
                    Email,
                    QUT_Learner_Email__c,
                    QUT_Staff_Email__c,
                    Work_Email__c,
                    hed__Preferred_Email__c,
                    hed__AlternateEmail__c
                FROM Contact WHERE RecordTypeId = :CONTACT_RT_PERSON_CONTACT_ID LIMIT :recordsCount
            ];
            for(Integer i = 0; i < recordsCount; i++) {
                conList[i].Email = 'new' + i + EMAIL;
                conList[i].QUT_Learner_Email__c = 'newlearner' + i + EMAIL;
                conList[i].QUT_Staff_Email__c = 'newstaff' + i + EMAIL;
                conList[i].Work_Email__c = 'newwork' + i + EMAIL;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(conList, false);
            Test.stopTest();
            
            for(Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }    
    
    @isTest private static void testBatchUpdateEachDuplicatesExisting() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> conList = [
                SELECT
                	Id,
                	LastName,
                    Email,
                    QUT_Learner_Email__c,
                    QUT_Staff_Email__c,
                    Work_Email__c,
                    hed__Preferred_Email__c,
                    hed__AlternateEmail__c
                FROM Contact WHERE RecordTypeId = :CONTACT_RT_PERSON_CONTACT_ID LIMIT :recordsCount
            ];
            List<Contact> conListToUpdate = new List<Contact>();
            for(Integer i = 0; i < recordsCount / 2; i++) {
                conList[i].Email = conList[i + (recordsCount / 2)].Email;
                conList[i].QUT_Learner_Email__c = conList[i + (recordsCount / 2)].QUT_Learner_Email__c;
                conList[i].QUT_Staff_Email__c = conList[i + (recordsCount / 2)].QUT_Staff_Email__c;
                conList[i].Work_Email__c = conList[i + (recordsCount / 2)].Work_Email__c;
                conListToUpdate.add(conList[i]);
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(conListToUpdate, false);
            Test.stopTest();
            
            
            for(Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }
    
	@isTest private static void testBatchUpdateDuplicatesWithinBatch() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> conList = [
                SELECT
                	Id,
                	LastName,
                    Email,
                    QUT_Learner_Email__c,
                    QUT_Staff_Email__c,
                    Work_Email__c,
                    hed__Preferred_Email__c,
                    hed__AlternateEmail__c
                FROM Contact WHERE RecordTypeId = :CONTACT_RT_PERSON_CONTACT_ID LIMIT :recordsCount
            ];
            for(Contact con : conList) {
                con.Email = 'dupe' + EMAIL;
                con.QUT_Learner_Email__c = 'dupelearner' + EMAIL;
                con.QUT_Staff_Email__c = 'dupestaff' + EMAIL;
                con.Work_Email__c = 'dupework' + EMAIL;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(conList, false);
            Test.stopTest();
            
            Boolean firstInserted = true;
            for(Database.SaveResult sr : srList) {
                if(!firstInserted)
	                System.assert(!sr.isSuccess(), 'A record was saved.');
                firstInserted = false;
            }
        }
    }
    
    @isTest private static void testBatchUpdatePartialDuplicatesExisting() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> conList = [
                SELECT
                	Id,
                	LastName,
                    Email,
                    QUT_Learner_Email__c,
                    QUT_Staff_Email__c,
                    Work_Email__c,
                    hed__Preferred_Email__c,
                    hed__AlternateEmail__c
                FROM Contact WHERE RecordTypeId = :CONTACT_RT_PERSON_CONTACT_ID LIMIT :recordsCount
            ];
            List<Contact> conListToUpdate = new List<Contact>();
            for(Integer i = 0; i < (recordsCount / 2) / 2; i++) {
                conList[i].Email = conList[i + (recordsCount / 2)].Email;
                conList[i].QUT_Learner_Email__c = conList[i + (recordsCount / 2)].QUT_Learner_Email__c;
                conList[i].QUT_Staff_Email__c = conList[i + (recordsCount / 2)].QUT_Staff_Email__c;
                conList[i].Work_Email__c = conList[i + (recordsCount / 2)].Work_Email__c;
                conListToUpdate.add(conList[i]);
            }
            for(Integer i = (recordsCount / 2) / 2; i < recordsCount / 2; i++) {
                conList[i].Email = 'newemail' + i + EMAIL;
                conList[i].QUT_Learner_Email__c = 'newlearneremail' + i + EMAIL;
                conList[i].QUT_Staff_Email__c = 'newstaffemail' + i + EMAIL;
                conList[i].Work_Email__c = 'newworkemail' + i + EMAIL;
                conListToUpdate.add(conList[i]);
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(conListToUpdate, false);
            Test.stopTest();
            
            Integer saved = 0;
            Integer rejected = 0;
            for(Database.SaveResult sr : srList) {
                if(sr.isSuccess())
                    saved += 1;
                else
                    rejected += 1;
            }
            
            System.assert(saved == (recordsCount / 2) / 2, 'There are only ' + saved + ' records out of ' + (recordsCount / 2) / 2 + ' saved.');
            System.assert(rejected == (recordsCount / 2) / 2, 'There are only ' + rejected + ' records out of ' + (recordsCount / 2) / 2 + ' rejected');
        }
    }
    
    @isTest private static void testBatchUpdatePartialDuplicatesWithinBatch() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> conList = [
                SELECT
                	Id,
                	LastName,
                    Email,
                    QUT_Learner_Email__c,
                    QUT_Staff_Email__c,
                    Work_Email__c,
                    hed__Preferred_Email__c,
                    hed__AlternateEmail__c
                FROM Contact WHERE RecordTypeId = :CONTACT_RT_PERSON_CONTACT_ID LIMIT :recordsCount
            ];
            List<Contact> conListToUpdate = new List<Contact>();
            for(Integer i = 0; i < recordsCount / 4; i++) {
                conList[i].Email = 'newemaildupe' + EMAIL;
                conList[i].QUT_Learner_Email__c = 'newlearneremaildupe' + EMAIL;
                conList[i].QUT_Staff_Email__c = 'newstaffemaildupe' + EMAIL;
                conList[i].Work_Email__c = 'newworkemaildupe' + EMAIL;
                conListToUpdate.add(conList[i]);
            }
            for(Integer i = recordsCount / 4; i < recordsCount / 2; i++) {
                conList[i].Email = 'newemail' + i + EMAIL;
                conList[i].QUT_Learner_Email__c = 'newlearneremaildupe' + i + EMAIL;
                conList[i].QUT_Staff_Email__c = 'newstaffemaildupe' + i + EMAIL;
                conList[i].Work_Email__c = 'newworkemail' + i + EMAIL;
                conListToUpdate.add(conList[i]);
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(conListToUpdate, false);
            Test.stopTest();
            
            Integer saved = 0;
            Integer rejected = 0;
            for(Database.SaveResult sr : srList) {
                if(sr.isSuccess())
                    saved += 1;
                else
                    rejected += 1;
            }
            
            System.assert(saved == (recordsCount / 4) + 1, 'There are only ' + saved + ' records out of ' + ((recordsCount / 4) + 1) + ' saved.');
            System.assert(rejected == (recordsCount / 4) - 1, 'There are only ' + rejected + ' records out of ' + ((recordsCount / 4) - 1) + ' rejected.');
        }    
    }
    
    @isTest private static void testBatchUpdateDuplicatesWithinAndExisting() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> conList = [
                SELECT
                	Id,
                	LastName,
                    Email,
                    QUT_Learner_Email__c,
                    QUT_Staff_Email__c,
                    Work_Email__c,
                    hed__Preferred_Email__c,
                    hed__AlternateEmail__c
                FROM Contact WHERE RecordTypeId = :CONTACT_RT_PERSON_CONTACT_ID LIMIT :recordsCount
            ];
            List<Contact> conListToUpdate = new List<Contact>();
            for(Integer i = 0; i < (recordsCount / 2) / 2; i++) {
                conList[i].Email = 'newemaildupe' + EMAIL;
                conList[i].QUT_Learner_Email__c = 'newlearneremaildupe' + EMAIL;
                conList[i].QUT_Staff_Email__c = 'newstaffemaildupe' + EMAIL;
                conList[i].Work_Email__c = 'newworkemaildupe' + EMAIL;
                conListToUpdate.add(conList[i]);
            }
            for(Integer i = (recordsCount / 2) / 2; i < recordsCount / 2; i++) {
                conList[i].Email = conList[i + recordsCount / 2].Email;
                conList[i].QUT_Learner_Email__c = conList[i + recordsCount / 2].QUT_Learner_Email__c;
                conList[i].QUT_Staff_Email__c = conList[i + recordsCount / 2].QUT_Staff_Email__c;
                conList[i].Work_Email__c = conList[i + recordsCount / 2].Work_Email__c;
                conListToUpdate.add(conList[i]);
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(conListToUpdate, false);
            Test.stopTest();
            
            for(Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }
    
    /** PRIVATE METHODS **/
    
    private static List<Contact> createTestContactRecords(Integer startAtCount, Integer endBeforeCount) {
        List<Contact> newContacts = new List<Contact>();
        for(Integer i = startAtCount; i < endBeforeCount; i++) {
            newContacts.add(
                new Contact(
                    LastName = LASTNAME + i,
                    Email = i + EMAIL,
                    QUT_Learner_Email__c = 'learner' + i + EMAIL,
                    QUT_Staff_Email__c = 'staff' + i + EMAIL,
                    Work_Email__c = 'work' + i + EMAIL,
                    hed__Preferred_Email__c = 'Alternate Email',
                    hed__AlternateEmail__c = i + EMAIL
                )
            );
        }
        return newContacts;
    }
    
    private static Integer randomInt(Integer max) {
        return (Integer)(Math.random() * max);
    }
}