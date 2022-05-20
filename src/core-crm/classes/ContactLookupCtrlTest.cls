/**
 * @description Tests the Contact Lookup Controller class 
 *
 * @see ContactLookupCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email           | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | marygrace.li@qut.edu.au   | September 20, 2021    | DEP1-158 | Created file                    |  
*/


@isTest
public class ContactLookupCtrlTest {

    private static User  currentUser = TestDataFactory.createUserRecords(1,'System Administrator').iterator().next();

    @testSetup static void setupMethod() {
        List<contact> contacts = new List<contact>(); 
        contacts = TestDataFactory.createTestContactRecords(2);

        Test.startTest();
        insert(contacts);
        Test.stopTest();
    }  


    @isTest
    static void getContactRecords(){
       List<Contact> contactList = new List<Contact>();
        System.runAs(currentUser) {
            Test.startTest();
            contactList = ContactLookupCtrl.getContactRecords();
            Test.stopTest();
        }
		System.assertEquals(2, contactList.size(), 'Contacts were not created.');
    }
}