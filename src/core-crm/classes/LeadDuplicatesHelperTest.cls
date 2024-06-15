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
*/
@isTest
private class LeadDuplicatesHelperTest {
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String COMPANY = 'Testcompany';
    private static final String LEAD_TYPE = 'CCE Corporate Partner';
    private static Integer recordsCount = 20;

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            LeadsDAO.newInstance()
                .insertRecords(
                    createTestLeadRecords(0, recordsCount),
                    false,
                    AccessLevel.USER_MODE
                );
        }
    }

    @isTest
    private static void testLeadBatchInsertNoDuplicates() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .insertRecords(
                    createTestLeadRecords(recordsCount, recordsCount * 2),
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
    private static void testLeadBatchInsertEachDuplicatesExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .insertRecords(
                    createTestLeadRecords(0, recordsCount),
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
    private static void testLeadBatchInsertDuplicatesWithinBatch() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> newLeads = createTestLeadRecords(0, recordsCount);
            for (Lead ld : newLeads) {
                ld.Email = EMAIL;
                ld.Work_Email__c = 'work' + EMAIL;
            }

            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .insertRecords(newLeads, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }

    @isTest
    private static void testLeadBatchInsertPartialDuplicatesExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> newLeads = new List<Lead>();
            newLeads.addAll(createTestLeadRecords(0, recordsCount / 2));
            newLeads.addAll(createTestLeadRecords(recordsCount, recordsCount + (recordsCount / 2)));

            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .insertRecords(newLeads, false, AccessLevel.USER_MODE);
            Test.stopTest();

            Integer dupesNotSaved = 0;
            Integer goodSaved = 0;
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    goodSaved += 1;
                } else {
                    dupesNotSaved += 1;
                }
            }
            System.assert(
                goodSaved == newLeads.size() / 2,
                'There are ' + goodSaved + ' records saved out of ' + newLeads.size() / 2
            );
            System.assert(
                dupesNotSaved == newLeads.size() / 2,
                'There are ' + dupesNotSaved + ' records saved out of ' + newLeads.size() / 2
            );
        }
    }

    @isTest
    private static void testLeadBatchInsertPartialDuplicatesWithinBatch() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> newLeads = createTestLeadRecords(recordsCount, recordsCount * 2);
            for (Integer i = 0; i < newLeads.size() / 2; i++) {
                newLeads[i].Email = EMAIL;
                newLeads[i].Work_Email__c = 'work' + EMAIL;
            }
            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .insertRecords(newLeads, false, AccessLevel.USER_MODE);
            Test.stopTest();

            Integer dupesNotSaved = 0;
            Integer goodSaved = 0;
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    goodSaved += 1;
                } else {
                    dupesNotSaved += 1;
                }
            }
            System.assert(
                goodSaved == newLeads.size() / 2,
                'There are ' + goodSaved + ' records saved out of ' + newLeads.size() / 2
            );
            System.assert(
                dupesNotSaved == newLeads.size() / 2,
                'There are ' + dupesNotSaved + ' records saved out of ' + newLeads.size() / 2
            );
        }
    }

    @isTest
    private static void testLeadBatchInsertDuplicatesWithinAndExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> newLeads = createTestLeadRecords(0, recordsCount);
            for (Integer i = 0; i < recordsCount / 2; i++) {
                newLeads[i].Email = EMAIL;
                newLeads[i].Work_Email__c = 'work' + EMAIL;
            }

            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .insertRecords(newLeads, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }

    @isTest
    private static void testLeadBatchUpdateNoDuplicates() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            List<Lead> leadToUpdate = new List<Lead>();
            for (Integer i = 0; i < recordsCount; i++) {
                leadToUpdate.add(new Lead(
                    Id = ldList[i].Id,
                    Email ='new' + i + EMAIL,
                    Work_Email__c ='newwork' + i + EMAIL
                ));
            }

            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .updateRecords(leadToUpdate, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }

    @isTest
    private static void testLeadBatchUpdatePartialDuplicatesExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            List<Lead> ldListToUpdate = new List<Lead>();
            for (Integer i = 0; i < (recordsCount / 2) / 2; i++) {
                ldListToUpdate.add(new Lead(
                    Id = ldList[i].Id,
                    Email = ldList[i + (recordsCount / 2)].Email,
                    Work_Email__c = ldList[i + (recordsCount / 2)].Work_Email__c
                ));
            }
            for (Integer i = (recordsCount / 2) / 2; i < recordsCount / 2; i++) {
                ldListToUpdate.add(new Lead(
                    Id = ldList[i].Id,
                    Email = 'newemail' + i + EMAIL,
                    Work_Email__c = 'newworkemail' + i + EMAIL
                ));
            }

            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .updateRecords(ldListToUpdate, false, AccessLevel.USER_MODE);
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
    private static void testLeadBatchUpdatePartialDuplicatesWithinBatch() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            List<Lead> ldListToUpdate = new List<Lead>();
            for (Integer i = 0; i < (recordsCount / 2) / 2; i++) {
                ldListToUpdate.add(new Lead(
                    Id = ldList[i].Id,
                    Email = 'newemaildupe' + EMAIL,
                    Work_Email__c = 'newworkemaildupe' + EMAIL
                ));
            }
            for (Integer i = (recordsCount / 2) / 2; i < recordsCount / 2; i++) {
                ldListToUpdate.add(new Lead(
                    Id = ldList[i].Id,
                    Email = 'newemail' + i + EMAIL,
                    Work_Email__c = 'newworkemail' + i + EMAIL
                ));
            }

            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .updateRecords(ldListToUpdate, false, AccessLevel.USER_MODE);
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
                    ' rejected.'
            );
        }
    }

    @isTest
    private static void testLeadBatchUpdateDuplicatesWithinAndExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            List<Lead> ldListToUpdate = new List<Lead>();
            for (Integer i = 0; i < (recordsCount / 2) / 2; i++) {
                ldListToUpdate.add(new Lead(
                    Id = ldList[i].Id,
                    Email = 'newemaildupe' + EMAIL,
                    Work_Email__c = 'newworkemaildupe' + EMAIL
                ));
            }
            for (Integer i = (recordsCount / 2) / 2; i < recordsCount / 2; i++) {
                ldListToUpdate.add(
                    new Lead(
                        Id = ldList[i].Id,
                        Email = ldList[i + recordsCount / 2].Email,
                        Work_Email__c = ldList[i + recordsCount / 2].Work_Email__c
                    )
                );
            }

            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .updateRecords(ldListToUpdate, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }

    private static List<Lead> createTestLeadRecords(Integer startAtCount, Integer endBeforeCount) {
        List<Lead> newLeads = new List<Lead>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newLeads.add(
                new Lead(
                    LastName = LASTNAME + i,
                    Email = i + EMAIL,
                    Work_Email__c = 'work' + i + EMAIL,
                    Company = COMPANY + i,
                    Lead_Type__c = LEAD_TYPE
                )
            );
        }
        return newLeads;
    }
}
