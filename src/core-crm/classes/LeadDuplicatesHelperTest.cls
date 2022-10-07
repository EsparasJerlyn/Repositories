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
@isTest
private class LeadDuplicatesHelperTest {    
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String COMPANY = 'Testcompany';
    private static final String LEAD_TYPE = 'CCE Corporate Partner';
    private static final String QUTEX = System.Label.QUTeX;
    private static User currentUser = TestDataFactory.createUserRecords(1, QUTEX)[0];
    private static Integer recordsCount = 100;
    
    @testSetup static void setup() {
        insert createTestLeadRecords(0, recordsCount);
    }
    
    /** TEST INSERT LEADS **/
    
    @isTest private static void testSingleInsertNoDuplicateEmail() {
        System.runAs(currentUser) {
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(createTestLeadRecords(100, 101), false);
            Test.stopTest();
            
            System.assert(srList[0].isSuccess(), 'The record was not saved.');
        }
    }
    
    @isTest private static void testSingleInsertDuplicatesExisting() {
        System.runAs(currentUser) {
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(createTestLeadRecords(0, 1), false);
            Test.stopTest();
            
            System.assert(!srList[0].isSuccess(), 'The record was saved.');
        }
    }
    
    @isTest private static void testSingleInsertCrossFieldsDuplicatesExisting() {
        System.runAs(currentUser) {
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
            Database.SaveResult[] srList = Database.insert(ldList, false);
           	Test.stopTest();
            
            System.assert(!srList[0].isSuccess(), 'The record was saved.');
        }
    }
    
    @isTest private static void testBatchInsertNoDuplicates() {
        System.runAs(currentUser) {
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(createTestLeadRecords(recordsCount, recordsCount * 2), false);
            Test.stopTest();
            
            for(Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }
    
    @isTest private static void testBatchInsertEachDuplicatesExisting() {
        System.runAs(currentUser) {
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(createTestLeadRecords(0, recordsCount), false);
            Test.stopTest();
            
            for(Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }
    
	@isTest private static void testBatchInsertDuplicatesWithinBatch() {
        System.runAs(currentUser) {
            List<Lead> newLeads = createTestLeadRecords(0, recordsCount);
            for(Lead ld : newLeads) {
                ld.Email = EMAIL;
                ld.Work_Email__c = 'work' + EMAIL;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(newLeads, false);
            Test.stopTest();
            
            for(Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }

    @isTest private static void testBatchInsertPartialDuplicatesExisting() {
        System.runAs(currentUser) {
            List<Lead> newLeads = new List<Lead>();
            newLeads.addAll(createTestLeadRecords(0, recordsCount / 2));
            newLeads.addAll(createTestLeadRecords(recordsCount, recordsCount + (recordsCount / 2)));
            
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(newLeads, false);
            Test.stopTest();
            
            Integer dupesNotSaved = 0;
            Integer goodSaved = 0;
            for(Database.SaveResult sr : srList) {
                if(sr.isSuccess())
                    goodSaved += 1;
                else 
                    dupesNotSaved += 1;
            }
            System.assert(goodSaved == newLeads.size() / 2, 'There are ' + goodSaved + ' records saved out of ' + newLeads.size() / 2);
            System.assert(dupesNotSaved == newLeads.size() / 2, 'There are ' + dupesNotSaved + ' records saved out of ' + newLeads.size() / 2);
        }
    }
    
    @isTest private static void testBatchInsertPartialDuplicatesWithinBatch() {
		System.runAs(currentUser) {
            List<Lead> newLeads = createTestLeadRecords(recordsCount, recordsCount * 2);
            for(Integer i = 0; i < newLeads.size() / 2; i++) {
                newLeads[i].Email = EMAIL;
                newLeads[i].Work_Email__c = 'work' + EMAIL;
            }
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(newLeads, false);
            Test.stopTest();
            
            Integer dupesNotSaved = 0;
            Integer goodSaved = 0;
            for(Database.SaveResult sr : srList) {
                if(sr.isSuccess())
                    goodSaved += 1;
                else 
                    dupesNotSaved += 1;
            }
            System.assert(goodSaved == newLeads.size() / 2, 'There are ' + goodSaved + ' records saved out of ' + newLeads.size() / 2);
            System.assert(dupesNotSaved == newLeads.size() / 2, 'There are ' + dupesNotSaved + ' records saved out of ' + newLeads.size() / 2);
        }    
    }
    
    @isTest private static void testBatchInsertDuplicatesWithinAndExisting() {
        System.runAs(currentUser) {
            List<Lead> newLeads = createTestLeadRecords(0, recordsCount);
            for(Integer i = 0; i < recordsCount / 2; i++) {
                newLeads[i].Email = EMAIL;
                newLeads[i].Work_Email__c = 'work' + EMAIL;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(newLeads, false);
            Test.stopTest();
            
            for(Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }
    
    /** TEST UPDATE LEADS **/
    
    @isTest private static void testSingleUpdateNoDuplicateEmail() {
        System.runAs(currentUser) {
            List<Lead> ldList = [SELECT Id, Email, Work_Email__c FROM Lead LIMIT 1];
            ldList[0].Email = 'nodupeemail@mail.test';
            ldList[0].Work_Email__c = 'nodupeworkemail@mail.test';
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(ldList, false);
            Test.stopTest();
            
            System.assert(srList[0].isSuccess(), 'The record was not saved.');
        }
    }
    
    @isTest private static void testSingleUpdateDuplicatesExisting() {
        System.runAs(currentUser) {
            List<Lead> ldList = [SELECT Id, Email, Work_Email__c FROM Lead LIMIT 2];
            ldList[0].Email = ldList[1].Email;
            ldList[0].Work_Email__c = ldList[1].Work_Email__c;
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(ldList, false);
            Test.stopTest();
            
            System.assert(!srList[0].isSuccess(), 'The record was saved.');
        }
    }
	// 84
	@isTest private static void testSingleUpdateCrossFieldsDuplicatesExisting() {
        System.runAs(currentUser) {
            List<Lead> ldList = [SELECT Id, Email, Work_Email__c FROM Lead LIMIT 2];
            ldList[0].Email = ldList[1].Work_Email__c;
            ldList[0].Work_Email__c = ldList[1].Email;
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(ldList, false);
            Test.stopTest();
            
            System.assert(!srList[0].isSuccess(), 'The record was saved.');
        }
    }
    
    @isTest private static void testBatchUpdateNoDuplicates() {
        System.runAs(currentUser) {
            List<Lead> ldList = [SELECT Id, Email, Work_Email__c FROM Lead LIMIT :recordsCount];
            for(Integer i = 0; i < recordsCount; i++) {
                ldList[i].Email = 'new' + i + EMAIL;
                ldList[i].Work_Email__c = 'newwork' + i + EMAIL;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(ldList, false);
            Test.stopTest();
            
            for(Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
            }
        }
    }    
    
    @isTest private static void testBatchUpdateEachDuplicatesExisting() {
        System.runAs(currentUser) {
            List<Lead> ldList = [SELECT Id, Email, Work_Email__c FROM Lead LIMIT :recordsCount];
            List<Lead> ldListToUpdate = new List<Lead>();
            for(Integer i = 0; i < recordsCount / 2; i++) {
                ldList[i].Email = ldList[i + (recordsCount / 2)].Email;
                ldList[i].Work_Email__c = ldList[i + (recordsCount / 2)].Work_Email__c;
                ldListToUpdate.add(ldList[i]);
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(ldListToUpdate, false);
            Test.stopTest();
            
            for(Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }
    
	@isTest private static void testBatchUpdateDuplicatesWithinBatch() {
        System.runAs(currentUser) {
            List<Lead> ldList = [SELECT Id, Email, Work_Email__c FROM Lead LIMIT :recordsCount];
            for(Lead ld : ldList) {
                ld.Email = EMAIL;
                ld.Work_Email__c = 'work' + EMAIL;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(ldList, false);
            Test.stopTest();
            
            for(Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }
    
    @isTest private static void testBatchUpdatePartialDuplicatesExisting() {
        System.runAs(currentUser) {
            List<Lead> ldList = [SELECT Id, Email, Work_Email__c FROM Lead LIMIT :recordsCount];
            List<Lead> ldListToUpdate = new List<Lead>();
            for(Integer i = 0; i < (recordsCount / 2) / 2; i++) {
                ldList[i].Email = ldList[i + (recordsCount / 2)].Email;
                ldList[i].Work_Email__c = ldList[i + (recordsCount / 2)].Work_Email__c;
                ldListToUpdate.add(ldList[i]);
            }
            for(Integer i = (recordsCount / 2) / 2; i < recordsCount / 2; i++) {
                ldList[i].Email = 'newemail' + i + EMAIL;
                ldList[i].Email = 'newworkemail' + i + EMAIL;
                ldListToUpdate.add(ldList[i]);
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(ldListToUpdate, false);
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
		System.runAs(currentUser) {
            List<Lead> ldList = [SELECT Id, Email, Work_Email__c FROM Lead LIMIT :recordsCount];
            List<Lead> ldListToUpdate = new List<Lead>();
            for(Integer i = 0; i < (recordsCount / 2) / 2; i++) {
                ldList[i].Email = 'newemaildupe' + EMAIL;
                ldList[i].Work_Email__c = 'newworkemaildupe' + EMAIL;
                ldListToUpdate.add(ldList[i]);
            }
            for(Integer i = (recordsCount / 2) / 2; i < recordsCount / 2; i++) {
                ldList[i].Email = 'newemail' + i + EMAIL;
                ldList[i].Email = 'newworkemail' + i + EMAIL;
                ldListToUpdate.add(ldList[i]);
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(ldListToUpdate, false);
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
            System.assert(rejected == (recordsCount / 2) / 2, 'There are only ' + rejected + ' records out of ' + (recordsCount / 2) / 2 + ' rejected.');
        }    
    }
    
    @isTest private static void testBatchUpdateDuplicatesWithinAndExisting() {
        System.runAs(currentUser) {
            List<Lead> ldList = [SELECT Id, Email, Work_Email__c FROM Lead LIMIT :recordsCount];
            List<Lead> ldListToUpdate = new List<Lead>();
            for(Integer i = 0; i < (recordsCount / 2) / 2; i++) {
                ldList[i].Email = 'newemaildupe' + EMAIL;
                ldList[i].Work_Email__c = 'newworkemaildupe' + EMAIL;
                ldListToUpdate.add(ldList[i]);
            }
            for(Integer i = (recordsCount / 2) / 2; i < recordsCount / 2; i++) {
                ldList[i].Email = ldList[i + recordsCount / 2].Email;
                ldList[i].Email = ldList[i + recordsCount / 2].Work_Email__c;
                ldListToUpdate.add(ldList[i]);
            }
            
            Test.startTest();
            Database.SaveResult[] srList = Database.update(ldListToUpdate, false);
            Test.stopTest();
            
            for(Database.SaveResult sr : srList) {
                System.assert(!sr.isSuccess(), 'A record was saved.');
            }
        }
    }
    
    /** PRIVATE METHODS **/
    
    private static List<Lead> createTestLeadRecords(Integer startAtCount, Integer endBeforeCount) {
        List<Lead> newLeads = new List<Lead>();
        for(Integer i = startAtCount; i < endBeforeCount; i++) {
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