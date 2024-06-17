/**
 * @description test class for duplicatecheckerhelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2023        | DEPP-5567              | Created File                 | 
 */
@isTest
private class DuplicateCheckerHelperTest {
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
    private static void testLeadSingleInsertNoDuplicateEmail() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .insertRecords(
                    createTestLeadRecords(recordsCount, recordsCount + 1),
                    false,
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(srList[0].isSuccess(), 'The record was not saved.');
        }
    }

    @isTest
    private static void testLeadSingleInsertDuplicatesExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .insertRecords(createTestLeadRecords(0, 1), false, AccessLevel.USER_MODE);
            Test.stopTest();

            System.assert(!srList[0].isSuccess(), 'The record was saved.');
        }
    }

    @isTest
    private static void testLeadSingleInsertCrossFieldsDuplicatesExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> ldList = new List<Lead>();
            ldList.add(
                new Lead(
                    LastName = 'Pepperoni',
                    Email = 'work' + 5 + EMAIL,
                    Work_Email__c = 4 + EMAIL,
                    Company = COMPANY,
                    Lead_Type__c = LEAD_TYPE
                )
            );
            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .insertRecords(ldList, false, AccessLevel.USER_MODE);
            Test.stopTest();

            System.assert(!srList[0].isSuccess(), 'The record was saved.');
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
            List<Lead> leadToUpdate = new List<Lead>();
            for (Lead ld : newLeads) {
                leadToUpdate.add(
                    new Lead(Id = ld.Id, Email = EMAIL, Work_Email__c = 'work' + EMAIL)
                );
            }

            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .insertRecords(leadToUpdate, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }

    @isTest
    private static void testLeadBatchInsertDuplicatesWithinAndExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> newLeads = createTestLeadRecords(0, recordsCount);
            List<Lead> leadToUpdate = new List<Lead>();
            for (Integer i = 0; i < recordsCount / 2; i++) {
                leadToUpdate.add(
                    new Lead(Id = newLeads[i].Id, Email = EMAIL, Work_Email__c = 'work' + EMAIL)
                );
            }

            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .insertRecords(leadToUpdate, false, AccessLevel.USER_MODE);
            Test.stopTest();

            for (Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }

    @isTest
    private static void testLeadSingleUpdateNoDuplicateEmail() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(1);
            lead leadToUpdate = new Lead(
                Id = ldList[0].Id,
                Email = 'nodupeemail@mail.test',
                Work_Email__c = 'nodupeworkemail@mail.test'
            );

            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .updateRecords(new List<Lead>{ leadToUpdate }, false, AccessLevel.USER_MODE);
            Test.stopTest();

            System.assert(srList[0].isSuccess(), 'The record was not saved.');
        }
    }

    @isTest
    private static void testLeadSingleUpdateDuplicatesExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(2);
            lead leadToUpdate = new Lead(
                Id = ldList[0].Id,
                Email = ldList[1].Email,
                Work_Email__c = ldList[1].Work_Email__c
            );

            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .updateRecords(new List<Lead>{leadToUpdate}, false, AccessLevel.USER_MODE);
            Test.stopTest();

            System.assert(!srList[0].isSuccess(), 'The record was saved.');
        }
    }

    @isTest
    private static void testLeadSingleUpdateCrossFieldsDuplicatesExisting() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(2);
            lead leadToUpdate = new Lead(
                Id = ldList[0].Id,
                Email = ldList[1].Work_Email__c,
                Work_Email__c = ldList[1].Email
            );
            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .updateRecords(new List<Lead>{leadToUpdate}, false, AccessLevel.USER_MODE);
            Test.stopTest();

            System.assert(!srList[0].isSuccess(), 'The record was saved.');
        }
    }

    @isTest
    private static void testLeadBatchUpdateNoDuplicates() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            List<Lead> leadToUpdate = new List<Lead>();
            for (Integer i = 0; i < recordsCount; i++) {

                leadToUpdate.add(
                    new Lead(Id = ldList[i].Id, Email = 'new' + i + EMAIL, Work_Email__c = 'newwork' + i + EMAIL)
                );
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
