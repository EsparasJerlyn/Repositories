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
      | marygrace.li@qut.edu.au   | May 19, 2022          | DEPP-2675| Added filter for AccountId      | 
*/


@isTest
public class ContactLookupCtrlTest {
	private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();

    @testSetup static void setupMethod() {
       System.runAs(currentUser) { 
        Account acc = TestDataFactory.createTestAccount(false);
        insert acc;

        List<Contact> contacts = TestDataFactory.createTestContactRecords(2);
        contacts[0].AccountId = acc.Id;
        contacts[1].AccountId = acc.Id;

        Test.startTest();
        insert(contacts);
        Test.stopTest();
       }
    }  


    @IsTest 
    static void getContactRecords(){
       List<Contact> contactList = new List<Contact>();
        User currUsr = [
              SELECT Id
              FROM User
              WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
              LIMIT 1
        ];
        
            System.runAs(currUsr) {
            
           	Test.startTest(); 
          	Id accountId = [SELECT Id FROM ACCOUNT WHERE OwnerId =: currUsr.Id LIMIT 1].Id;
                
            contactList = ContactLookupCtrl.getContactRecords(accountId);
            Test.stopTest();
            System.assertEquals(2, contactList.size(), 'Contacts were not created.');
      }
    }
}