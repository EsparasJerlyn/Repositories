/**
 * @description Test Class for Contact Potential Duplicate Ctrl
 *
 * @see ../class/ContactPotentialDuplicateCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eccarius.munoz            | May 27, 2022          | DEPP-1778    | Created file                                |
      |                           |                       |              |                                             |
      |                           |                       |              |                                             |
*/
@IsTest(SeeAllData = false)
private class ContactPotentialDuplicateCtrlTest {
    
    private @TestSetup
    static void makeData(){
        List<Contact> contacts = TestDataFactory.createTestContactRecords(3);        
        insert contacts;

        List<Potential_Duplicate__c> potentialDuplicates = new List<Potential_Duplicate__c>();
        potentialDuplicates.add(new Potential_Duplicate__c(Contact__c = contacts[0].Id, Duplicate_Contact__c = contacts[1].Id));
        potentialDuplicates.add(new Potential_Duplicate__c(Contact__c = contacts[0].Id, Duplicate_Contact__c = contacts[2].Id));
        insert potentialDuplicates;
    }

    @IsTest
    static void getSelectedContactTest(){
        List<Contact> contacts = [SELECT Id FROM Contact];
        Id recordId = contacts[0].Id;
        Test.startTest();
        List<ContactPotentialDuplicateCtrl.ContactWrapper> contactList = ContactPotentialDuplicateCtrl.getSelectedContact(recordId);
        Test.stopTest();
        System.assertEquals(true, contactList.size()>0, 'No contact record retrieved.');
    }

    @IsTest
    static void getPotentialDuplicateTest(){
        List<Contact> contacts = [SELECT Id FROM Contact];
        Id recordId = contacts[0].Id;
        Test.startTest();
        List<ContactPotentialDuplicateCtrl.ContactWrapper> contactList = ContactPotentialDuplicateCtrl.getPotentialDuplicate(recordId);
        Test.stopTest();
        System.assertEquals(true, contactList.size() > 0, 'No dupllicate record(s) retrieved.');
    }

    @IsTest
    static void mergeContactsTest(){
        List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact];
        Id recordId = contacts[1].Id;
        List<ContactPotentialDuplicateCtrl.ContactWrapper> contactList = ContactPotentialDuplicateCtrl.getSelectedContact(recordId);
        List<ContactPotentialDuplicateCtrl.ContactWrapper> duplicateContactList = ContactPotentialDuplicateCtrl.getPotentialDuplicate(recordId);
        Test.startTest();
        String response = ContactPotentialDuplicateCtrl.mergeContacts(duplicateContactList, contactList);
        Test.stopTest();
        System.assertEquals('Success', response, 'Failed to save records.');
    }
}
