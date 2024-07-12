/**
 * @description Test Class for Contact Update Preferred Full Name flow
 *
 * @see ../flows/Contact_Update_Preferred_Full_Name
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | angelika.j.s.galang       | December 20, 2021     | DEPP-1144    | Created file                                | 
      |                           |                       |              |                                             | 
*/
@isTest
private class Contact_Update_Preferred_Full_NameTest {

    private static final String TEST_FIRST_NAME = 'TestCustomFirstName';
    private static final String TEST_RANDOM = 'TestRandom';

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void insertContactAssignFirstNameTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Contact con = TestDataFactory.createTestContactRecords(1).iterator().next();
            con.FirstName = TEST_FIRST_NAME;

            Test.startTest();
            insert con;  
            Test.stopTest();
			
            Contact updatedCon = [Select Preferred_Given_Name__c From Contact Limit 1];
            System.assertEquals(TEST_FIRST_NAME, updatedCon.Preferred_Given_Name__c, 'Preferred Given Name not assigned as expected');
        }
    }

    @isTest
    private static void updateContactPreferredGivenNameTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Contact con = TestDataFactory.createTestContactRecords(1).iterator().next();
            con.FirstName = TEST_FIRST_NAME;
            insert con;

            Test.startTest();
            con.Preferred_Given_Name__c = TEST_RANDOM;
            update con;
            Test.stopTest();

            System.assertEquals(TEST_RANDOM, con.Preferred_Given_Name__c, 'Preferred Given Name not updated as expected');
        }
    }
}