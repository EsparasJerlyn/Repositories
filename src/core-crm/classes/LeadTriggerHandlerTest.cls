/**
 * @description Test Class for Lead Trigger Handler
 *
 * @see LeadTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | angelika.j.s.galang       | May 27, 2022          | DEPP-1455    | Created file                                |
      | alexander.cadalin         | June 22, 2022         | DEPP-3056    | leadDuplicateEmailsTestOnInsert             |
      |                           | June 24, 2022         | DEPP-3056    | removed global dupes handler tests          |
*/
@IsTest(SeeAllData = false)
private class LeadTriggerHandlerTest {
    
    private static final String LEAD = 'Lead.';
    private static final String CONTACT = 'Contact.';
    private static final String FIRST_NAME = 'FirstName';
    private static final String EMAIL = 'Email@email.com.invalid';
    private static final String LAST_NAME = 'LastName';
    private static final String QUTEX = System.Label.QUTeX;
    private static User currentUser = TestDataFactory.createUserRecords(1, QUTEX).iterator().next();

    @testSetup static void setupMethod() {
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next(); 
        insert acc;

        List<Lead> leadRecords = new List<Lead>();

        Lead leadRecord1 = TestDataFactory.createTestLeadRecords(1).iterator().next();
        leadRecord1.FirstName = LEAD + FIRST_NAME;
        leadRecord1.Email = LEAD + EMAIL;
        leadRecord1.LastName = LEAD + LAST_NAME;
        leadRecords.add(leadRecord1);

        Lead leadRecord2 = TestDataFactory.createTestLeadRecords(1).iterator().next();
        leadRecord2.Email = LEAD + EMAIL;
        leadRecord2.LastName = LEAD + LAST_NAME;
        leadRecords.add(leadRecord2);

        insert leadRecords;

        leadRecord2.FirstName = LEAD + FIRST_NAME;
        update leadRecord2;
    }
    
    // @IsTest
    // private static void leadToLeadDuplicatesExactMatchTest() {
    //     System.runAs(currentUser){
    //         Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next(); 
    //         insert acc; 
            
    //         List<Lead> existingLeads = new List<Lead>([SELECT Id FROM Lead]);

    //         Lead duplicateLead = TestDataFactory.createTestLeadRecords(1).iterator().next();
    //         duplicateLead.FirstName = LEAD + FIRST_NAME;
    //         duplicateLead.Email = LEAD + EMAIL;
    //         duplicateLead.LastName = LEAD + LAST_NAME;

    //         Test.startTest();
    //         insert duplicateLead;
    //         Test.stopTest();

    //         System.assertEquals(
    //             2,
    //             [
    //                 SELECT count() 
    //                 FROM Potential_Duplicate__c
    //                 WHERE Lead__c IN : existingLeads
    //             ],
    //             'There should be 2 potential duplicates created'
    //         );
    //     }
    // }

    // @IsTest
    // private static void leadToContactDuplicatesExactMatchTest() {
    //     DmlException expectedException;
    //     System.runAs(currentUser){
    //         Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next(); 
    //         insert acc; 

    //         Contact contactRecord = TestDataFactory.createTestContactRecords(1).iterator().next();
    //         contactRecord.FirstName = CONTACT + FIRST_NAME;
    //         contactRecord.Email = CONTACT + EMAIL;
    //         contactRecord.LastName = CONTACT + LAST_NAME;
    //         insert contactRecord;

    //         Lead duplicateLead = TestDataFactory.createTestLeadRecords(1).iterator().next();
    //         duplicateLead.FirstName = CONTACT + FIRST_NAME;
    //         duplicateLead.Email = CONTACT + EMAIL;
    //         duplicateLead.LastName = CONTACT + LAST_NAME;

    //         Test.startTest();
    //         try {
    //             insert duplicateLead;
    //         } catch (DmlException d) {
    //             expectedException = d;
    //         }
    //         Test.stopTest();

    //         System.assertNotEquals(
    //             null,
    //             expectedException,
    //             'The record should be validated'
    //         );
    //     }
    // }

    // @IsTest
    // private static void leadToContactDuplicatesPartialMatchTest() {
    //     System.runAs(currentUser){
    //         Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next(); 
    //         insert acc; 

    //         Contact contactRecord = TestDataFactory.createTestContactRecords(1).iterator().next();
    //         contactRecord.FirstName = CONTACT + FIRST_NAME;
    //         contactRecord.Email = CONTACT + EMAIL;
    //         contactRecord.LastName = CONTACT + LAST_NAME;
    //         insert contactRecord;

    //         Lead duplicateLead = TestDataFactory.createTestLeadRecords(1).iterator().next();
    //         duplicateLead.Email = CONTACT + EMAIL;
    //         duplicateLead.LastName = CONTACT + LAST_NAME;

    //         Test.startTest();
    //         insert duplicateLead;
    //         Test.stopTest();

    //         System.assertEquals(
    //             1,
    //             [
    //                 SELECT count() 
    //                 FROM Potential_Duplicate__c
    //                 WHERE Contact__c = :contactRecord.Id
    //             ],
    //             'There should be 1 potential duplicate created'
    //         );
    //     }
    // }
    
    @IsTest
    private static void leadDuplicateEmailsTestOnInsert() {
        System.runAs(currentUser) {
            Lead halcey = new Lead(
            	FirstName = 'Halcey',
                LastName = 'Smith',
                Status = 'New',
                Lead_Type__c = 'CCE Corporate Partner',
                Company = 'Twin Smith',
                Email = 'hal.smith@email.test',
                Work_Email__c = 'hal.smith@work.test'
            );
            insert halcey;
            
            test.startTest();
            Lead halcyon = new Lead(
                FirstName = 'Halcyon',
                LastName = 'Smith',
                Status = 'New',
                Lead_Type__c = 'CCE Corporate Partner',
                Company = 'Twin Smith',
                Email = 'hal.smith@email.test',
                Work_Email__c = 'hal.smith@work.test'
            );
            Database.SaveResult sr = Database.Insert(halcyon, false);
            test.stopTest();
            
            System.assert(!sr.isSuccess(), 'Halcyon\'s lead record was created.');
        }
    }
    
    @IsTest
    private static void leadDuplicateEmailsTestOnUpdate() {
        System.runAs(currentUser) {
            List<Lead> leads = new List<Lead>();
            leads.add(new Lead(
            	FirstName = 'Halcey',
                LastName = 'Smith',
                Status = 'New',
                Lead_Type__c = 'CCE Corporate Partner',
                Company = 'Twin Smith',
                Email = 'hal.smith@email.test',
                Work_Email__c = 'hal.smith@work.test'
            ));
            leads.add(new Lead(
            	FirstName = 'Halcyon',
                LastName = 'Smith',
                Status = 'New',
                Lead_Type__c = 'CCE Corporate Partner',
                Company = 'Twin Smith',
                Email = 'halc.smith@email.test'
            ));
            insert leads;
            
            test.startTest();
            leads[1].Email = 'hal.smith@email.test';
            leads[1].Work_Email__c = 'hal.smith@work.test';
            Database.SaveResult sr = Database.Update(leads[1], false);
            test.stopTest();
            
            System.assert(!sr.isSuccess(), 'Halcyon\'s lead record was created.');
        }
    }
}