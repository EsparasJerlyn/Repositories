/**
 * @description Tests the Contact_Update_Triggered_Flow
 *
 * @see Contact_Update_Triggered_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | roy.nino.s.regala         | November 03, 2021     | DEPP-735 | Created file                    | 
      |                           |                       |          |                                 |
*/
@IsTest(SeeAllData = false)
private class Contact_Update_Triggered_FlowTest {
    
    private static final String STR_QUTEX = 'QUTeX';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTeX).iterator().next();

    @isTest
    private static void updatePhoneNumbersTest(){

        List<Contact> contacts = new List<Contact>();

        System.runAs(currentUser){
            contacts = TestDataFactory.createTestContactRecords(100);

            for(Contact c : contacts){
                c.ContactPhone_Validation__c = 'Valid';
                c.ContactMobile_Validation__c = 'Valid';
                c.ContactWorkPhone_Validation__c = 'Valid';
                c.ContactPersonalMobile_Validation__c = 'Valid';
            }

            insert contacts;

        Test.startTest();
        List<Contact> contactsToUpdate = new List<Contact>([Select Id FROM Contact]);
        for(Contact c: contactsToUpdate){
                c.Phone = '12345';
                c.MobilePhone = '12345';
                c.Personal_Mobile__c = '12345';
                c.hed__WorkPhone__c = '12345';
        }
        update(contactsToUpdate);
        Test.stopTest();

        }
        system.assert(![SELECT Id FROM Contact Where ContactPhone_Validation__c = 'None'].isEmpty(), 'ContactPhone Validation Status should be None');
        system.assert(![SELECT Id FROM Contact Where ContactMobile_Validation__c = 'None'].isEmpty(), 'ContactMobile Validation Status should be None');
        system.assert(![SELECT Id FROM Contact Where ContactWorkPhone_Validation__c = 'None'].isEmpty(), 'ContactWorkPhone Validation Status should be None');
        system.assert(![SELECT Id FROM Contact Where ContactPersonalMobile_Validation__c = 'None'].isEmpty(), 'ContactPersonalMobile Validation Status should be None');
    } 

}
