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
     | kenneth.f.alsay           | Aug 4, 2023           | DEPP-6304| Updated runAs user              |
*/


@isTest
public class ContactLookupCtrlTest {
    @testSetup static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<Account> accList = TestDataFactory.createTestAccountRecords(1);
            AccountsDAO.newInstance().insertRecords(accList, false, AccessLevel.USER_MODE);

            List<Contact> contacts = TestDataFactory.createTestContactRecords(2);
            contacts[0].AccountId = accList[0].Id;
            contacts[1].AccountId = accList[0].Id;
            ContactsDAO.newInstance().insertRecords(contacts, false, AccessLevel.USER_MODE);

            List<hed__Affiliation__c> affliatedContacts = TestDataFactory.createTestAffliatedContactRecords(2, accList[0].Id);
            for(Integer i = 0; i<contacts.size(); i++){
                affliatedContacts[i].hed__Contact__c = contacts[i].Id;
            }
            insert affliatedContacts;
        }  
    }
    
    @isTest
    static void getContactRecords(){
        List<Contact> contactList = new List<Contact>();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            List<Account> accList = [SELECT Id FROM Account];
            contactList = ContactLookupCtrl.getContactRecords(accList[0].Id);
            Test.stopTest();
        } 
        System.assertEquals(2, contactList.size(), 'Contacts were not created.');      
    }
}