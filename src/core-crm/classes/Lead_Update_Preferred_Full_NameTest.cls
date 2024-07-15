/**
 * @description Test Class for Lead Update Preferred Full Name flow
 *
 * @see ../flows/Lead_Update_Preferred_Full_Name
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | angelika.j.s.galang       | January 7, 2021       | DEPP-1435    | Created file                                | 
      |                           |                       |              |                                             | 
*/
@isTest
private class Lead_Update_Preferred_Full_NameTest {

    private static final String TEST_FIRST_NAME = 'TestCustomFirstName';
    private static final String TEST_RANDOM = 'TestRandom';

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void insertLeadAssignFirstNameTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next(); 
            insert acc;

            Lead leadRecord = TestDataFactory.createTestLeadRecords(1).iterator().next();
            leadRecord.Street = 'TestStreet';
            leadRecord.State = 'TestState';
            leadRecord.PostalCode = '1234';
            leadRecord.Country = 'TestCountry';

            leadRecord.FirstName = TEST_FIRST_NAME;

            Test.startTest();
            insert leadRecord;  
            Test.stopTest();
			
            Lead updatedLeadRecord = [Select Preferred_Given_Name__c From Lead Limit 1];
            System.assertEquals(TEST_FIRST_NAME, updatedLeadRecord.Preferred_Given_Name__c, 'Preferred Given Name not assigned as expected');
        }
    }

    @isTest
    private static void updateLeadPreferredGivenNameTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next(); 
            insert acc;

            Lead leadRecord = TestDataFactory.createTestLeadRecords(1).iterator().next();
            leadRecord.Street = 'TestStreet';
            leadRecord.State = 'TestState';
            leadRecord.PostalCode = '1234';
            leadRecord.Country = 'TestCountry';
            
            leadRecord.FirstName = TEST_FIRST_NAME;
            insert leadRecord;

            Test.startTest();
            leadRecord.Preferred_Given_Name__c = TEST_RANDOM;
            update leadRecord;
            Test.stopTest();

            System.assertEquals(TEST_RANDOM, leadRecord.Preferred_Given_Name__c, 'Preferred Given Name not updated as expected');
        }
    }
}
