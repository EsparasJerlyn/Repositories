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
      | roy.nino.s.regala         | April 23, 2023        | DEPP-5567    | Applied DAO framework                       |
      | roy.nino.s.regala         | April 23, 2023        | DEPP-5567    | removed simple testmethods to reduce pmd    |
*/
@isTest
private class ContactDuplicatesHelperTest {
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static Integer recordsCount = 20;

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            ContactsDAO.newInstance()
                .insertRecords(
                    createTestContactRecords(0, recordsCount),
                    false,
                    AccessLevel.USER_MODE
                );
        }
    }

    /** TEST INSERT CONTACTS **/

    @isTest
    private static void testBatchInsertNoDuplicates() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            Database.SaveResult[] srList = ContactsDAO.newInstance()
                .insertRecords(
                    createTestContactRecords(recordsCount, recordsCount * 2),
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
    private static void testBatchInsertEachDuplicatesExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            Database.SaveResult[] srList = ContactsDAO.newInstance()
                .insertRecords(
                    createTestContactRecords(0, recordsCount),
                    false,
                    AccessLevel.USER_MODE
                );
            Test.stopTest();

            for (Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }

    @isTest
    private static void testBatchInsertDuplicatesWithinBatch() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> newContacts = createTestContactRecords(0, recordsCount);
            for (Contact con : newContacts) {
                con.Email = EMAIL;
                con.QUT_Learner_Email__c = 'learner' + EMAIL;
                con.QUT_Staff_Email__C = 'staff' + EMAIL;
                con.Work_Email__c = 'work' + EMAIL;
            }

            Test.startTest();
            Database.SaveResult[] srList = ContactsDAO.newInstance()
                .insertRecords(newContacts, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }

    @isTest
    private static void testBatchInsertPartialDuplicatesExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> newContacts = new List<Contact>();
            newContacts.addAll(createTestContactRecords(0, recordsCount / 2));
            newContacts.addAll(
                createTestContactRecords(recordsCount, recordsCount + (recordsCount / 2))
            );

            Test.startTest();
            Database.SaveResult[] srList = ContactsDAO.newInstance()
                .insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            Integer rejected = 0;
            Integer saved = 0;
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    saved += 1;
                } else {
                    rejected += 1;
                }
            }
            System.assert(
                saved == newContacts.size() / 2,
                'There are ' + saved + ' records saved out of ' + newContacts.size() / 2
            );
            System.assert(
                rejected == newContacts.size() / 2,
                'There are ' + rejected + ' records rejected out of ' + newContacts.size() / 2
            );
        }
    }

    @isTest
    private static void testBatchInsertPartialDuplicatesWithinBatch() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> newContacts = createTestContactRecords(recordsCount, recordsCount * 2);
            for (Integer i = 0; i < recordsCount / 2; i++) {
                newContacts[i].Email = 'dupe' + EMAIL;
                newContacts[i].QUT_Learner_Email__c = 'dupelearner' + EMAIL;
                newContacts[i].QUT_Staff_Email__c = 'dupestaff' + EMAIL;
                newContacts[i].Work_Email__c = 'dupework' + EMAIL;
            }

            Test.startTest();
            Database.SaveResult[] srList = ContactsDAO.newInstance()
                .insertRecords(newContacts, false, AccessLevel.USER_MODE);
            Test.stopTest();

            Integer rejected = 0;
            Integer saved = 0;
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    saved += 1;
                } else {
                    rejected += 1;
                }
            }
            System.assert(
                saved == (recordsCount / 2),
                'There are ' + saved + ' records saved out of ' + recordsCount / 2
            );
            System.assert(
                rejected == (recordsCount / 2),
                'There are ' + rejected + ' records rejected out of ' + recordsCount / 2
            );
        }
    }

    @isTest
    private static void testBatchInsertDuplicatesWithinAndExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> newContacts = createTestContactRecords(0, recordsCount);
            
            for (Integer i = 0; i < recordsCount / 2; i++) {
                newContacts[i].Email = EMAIL;
                newContacts[i].QUT_Learner_Email__c = 'learner' + EMAIL;
                newContacts[i].QUT_Staff_Email__c = 'staff' + EMAIL;
                newContacts[i].Work_Email__c = 'work' + EMAIL;
            }

            Test.startTest();
            Database.SaveResult[] srList = ContactsDAO.newInstance()
                .insertRecords(newContacts, false, AccessLevel.USER_MODE);
            Test.stopTest();

            Boolean firstInserted = true;
            for (Database.SaveResult sr : srList) {
                if (!firstInserted) {
                    // the first record should save because it doesn't exist yet even though it
                    System.assert(!sr.isSuccess(), 'A record was saved.');
                }
                firstInserted = false;
            }
        }
    }

    @isTest
    private static void testBatchUpdateNoDuplicates() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> conList = ContactsDAO.newInstance()
                .getPersonContactsWithLimit(recordsCount);
            List<Contact> conToUpdate = new List<Contact>();
            for (Integer i = 0; i < recordsCount; i++) {
                conToUpdate.add(new Contact(
                    id = conList[i].Id,
                    Email = 'new' + i + EMAIL,
                    QUT_Learner_Email__c =  'newlearner' + i + EMAIL,
                    QUT_Staff_Email__c = 'newstaff' + i + EMAIL,
                    Work_Email__c = 'newwork' + i + EMAIL
                ));
            }

            Test.startTest();
            Database.SaveResult[] srList = ContactsDAO.newInstance()
                .updateRecords(conToUpdate, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }

    @isTest
    private static void testBatchUpdatePartialDuplicatesExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> conList = ContactsDAO.newInstance()
                .getPersonContactsWithLimit(recordsCount);
            List<Contact> conListToUpdate = new List<Contact>();
            for (Integer i = 0; i < (recordsCount / 2) / 2; i++) {
                conListToUpdate.add(new Contact(
                    id = conList[i].Id,
                    Email = conList[i + (recordsCount / 2)].Email,
                    QUT_Learner_Email__c =  conList[i + (recordsCount / 2)]
                    .QUT_Learner_Email__c,
                    QUT_Staff_Email__c = conList[i + (recordsCount / 2)].QUT_Staff_Email__c,
                    Work_Email__c = conList[i + (recordsCount / 2)].Work_Email__c
                ));
            }
            for (Integer i = (recordsCount / 2) / 2; i < recordsCount / 2; i++) {
                conListToUpdate.add(new Contact(
                    id = conList[i].Id,
                    Email = 'newemail' + i + EMAIL,
                    QUT_Learner_Email__c =  'newlearneremail' + i + EMAIL,
                    QUT_Staff_Email__c = 'newstaffemail' + i + EMAIL,
                    Work_Email__c = 'newworkemail' + i + EMAIL
                ));
            }

            Test.startTest();
            Database.SaveResult[] srList = ContactsDAO.newInstance()
                .updateRecords(conListToUpdate, false, AccessLevel.USER_MODE);
            Test.stopTest();

            Integer saved = 0;
            Integer rejected = 0;
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    saved += 1;
                } else {
                    rejected += 1;
                }
            }

            System.assert(
                saved == (recordsCount / 2) / 2,
                'There are only ' + saved + ' records out of ' + (recordsCount / 2) / 2 + ' saved.'
            );
            System.assert(
                rejected == (recordsCount / 2) / 2,
                'There are only ' +
                    rejected +
                    ' records out of ' +
                    (recordsCount / 2) / 2 +
                    ' rejected'
            );
        }
    }

    @isTest
    private static void testBatchUpdatePartialDuplicatesWithinBatch() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> conList = ContactsDAO.newInstance()
                .getPersonContactsWithLimit(recordsCount);
            List<Contact> conListToUpdate = new List<Contact>();
            for (Integer i = 0; i < recordsCount / 4; i++) {
                conListToUpdate.add(new Contact(
                    id = conList[i].Id,
                    Email = 'newemaildupe' + EMAIL,
                    QUT_Learner_Email__c =  'newlearneremaildupe' + EMAIL,
                    QUT_Staff_Email__c = 'newstaffemaildupe' + EMAIL,
                    Work_Email__c = 'newworkemaildupe' + EMAIL
                ));
            }
            for (Integer i = recordsCount / 4; i < recordsCount / 2; i++) {
                conListToUpdate.add(new Contact(
                    id = conList[i].Id,
                    Email = 'newemail' + i + EMAIL,
                    QUT_Learner_Email__c =  'newlearneremaildupe' + i + EMAIL,
                    QUT_Staff_Email__c = 'newstaffemaildupe' + i + EMAIL,
                    Work_Email__c = 'newworkemail' + i + EMAIL
                ));
            }

            Test.startTest();
            Database.SaveResult[] srList = ContactsDAO.newInstance()
                .updateRecords(conListToUpdate, false, AccessLevel.USER_MODE);
            Test.stopTest();

            Integer saved = 0;
            Integer rejected = 0;
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    saved += 1;
                } else {
                    rejected += 1;
                }
            }

            System.assert(
                saved == (recordsCount / 4),
                'There are only ' + saved + ' records out of ' + ((recordsCount / 4)) + ' saved.'
            );
            System.assert(
                rejected == (recordsCount / 4),
                'There are only ' +
                    rejected +
                    ' records out of ' +
                    ((recordsCount / 4)) +
                    ' rejected.'
            );
        }
    }

    @isTest
    private static void testBatchUpdateDuplicatesWithinAndExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Contact> conList = ContactsDAO.newInstance()
                .getPersonContactsWithLimit(recordsCount);
            List<Contact> conListToUpdate = new List<Contact>();
            for (Integer i = 0; i < (recordsCount / 2) / 2; i++) {
                conListToUpdate.add(new Contact(
                    id = conList[i].Id,
                    Email = 'newemaildupe' + EMAIL,
                    QUT_Learner_Email__c = 'newlearneremaildupe' + EMAIL,
                    QUT_Staff_Email__c = 'newstaffemaildupe' + EMAIL,
                    Work_Email__c = 'newworkemaildupe' + EMAIL
                ));
            }
            for (Integer i = (recordsCount / 2) / 2; i < recordsCount / 2; i++) {
                conListToUpdate.add(new Contact(
                    id = conList[i].Id,
                    Email = conList[i + recordsCount / 2].Email,
                    QUT_Learner_Email__c =  conList[i + recordsCount / 2]
                    .QUT_Learner_Email__c,
                    QUT_Staff_Email__c = conList[i + recordsCount / 2].QUT_Staff_Email__c,
                    Work_Email__c = conList[i + recordsCount / 2].Work_Email__c
                ));
            }

            Test.startTest();
            Database.SaveResult[] srList = ContactsDAO.newInstance()
                .updateRecords(conListToUpdate, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }

    /** PRIVATE METHODS **/

    private static List<Contact> createTestContactRecords(
        Integer startAtCount,
        Integer endBeforeCount
    ) {
        List<Contact> newContacts = new List<Contact>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
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
        return (Integer) (Math.random() * max);
    }
}
