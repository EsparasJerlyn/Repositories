/**
 * @description Tests the Contact_Update_Marketing_Mobile_Locale flow
 *
 * @see Contact_Update_Marketing_Mobile_Locale flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | roy.nino.s.regala         | May 31, 2022          | DEPP-2105| Created file                    | 
      |                           |                       |          |                                 |
*/
@isTest
private class Contact_Update_Mobile_LocaleTest {

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void updatePhoneNumbersTest(){

        List<Contact> contacts = new List<Contact>();

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            contacts = TestDataFactory.createTestContactRecords(50);

            for(Contact c : contacts){
                c.Company_Name__c = 'test Company';
                c.ContactMobile_Validation__c = 'None';
                c.ContactMobile_Locale__c = 'Australia (+61)';
            }

            insert contacts;

        Test.startTest();
        List<Contact> contactsToUpdate = new List<Contact>([Select Id FROM Contact LIMIT 50]);
        for(Contact c: contactsToUpdate){
            c.ContactMobile_Validation__c = 'Valid';
        }
        update(contactsToUpdate);
        Test.stopTest();

        }
        system.assert(![SELECT Id FROM Contact Where Marketing_Mobile_Locale__c = 'en-AU'].isEmpty(), 'contact mobile locale should be en-au');
    } 

}
