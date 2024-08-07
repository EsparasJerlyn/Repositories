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
      |                             |                       |          |                                 |
*/
@isTest
private class Contact_Update_Triggered_FlowTest {

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void updateToUnvalidatedTest(){

        List<Contact> contacts = new List<Contact>();

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            contacts = TestDataFactory.createTestContactRecords(50);

            for(Contact c : contacts){
                c.ContactPhone_Validation__c = 'Valid';
                c.ContactMobile_Validation__c = 'Valid';
                c.ContactWorkPhone_Validation__c = 'Valid';
                c.Phone = '12345';
                c.MobilePhone = '12345';
                c.Personal_Mobile__c = '12345';
            }
            insert contacts;

            Test.startTest();
            List<Contact> contactsToUpdate = new List<Contact>([Select Id, ContactPhone_Validation__c, ContactMobile_Validation__c, ContactWorkPhone_Validation__c FROM Contact]);
  
            for(Contact c: contactsToUpdate){
                c.ContactPhone_Locale__c = 'Albania (355)';
                c.ContactMobile_Locale__c = 'Albania (355)';
                c.ContactWorkPhone_Locale__c = 'Albania (355)';
            }
            update(contactsToUpdate);
            Test.stopTest();

            System.assert(![SELECT Id FROM Contact Where ContactPhone_Validation__c = 'Unvalidated'].isEmpty(), 'ContactPhone Validation Status should be Unvalidated');
            System.assert(![SELECT Id FROM Contact Where ContactMobile_Validation__c = 'Unvalidated'].isEmpty(), 'ContactMobile Validation Status should be Unvalidated');
            System.assert(![SELECT Id FROM Contact Where ContactWorkPhone_Validation__c = 'Unvalidated'].isEmpty(), 'ContactWorkPhone Validation Status should be Unvalidated');
        }
    }
    
    @isTest
    private static void updateToNoneTest(){
       List<Contact> contacts = new List<Contact>();

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            contacts = TestDataFactory.createTestContactRecords(50);
            for(Contact c : contacts){
                c.ContactPhone_Validation__c = 'Unvalidated';
                c.ContactMobile_Validation__c = 'Unvalidated';
                c.ContactWorkPhone_Validation__c = 'Unvalidated';
                c.ContactMobile_Locale__c = 'Philippines (the) (63)';
                c.ContactWorkPhone_Locale__c = 'Philippines (the) (63)';
                c.ContactPhone_Locale__c = 'Philippines (the) (63)';   
            }
            insert contacts;

            Test.startTest();
            List<Contact> contactsToUpdate = new List<Contact>([Select Id, ContactPhone_Validation__c, ContactMobile_Validation__c, ContactWorkPhone_Validation__c FROM Contact]);
            for(Contact c: contactsToUpdate){
                    c.ContactMobile_Locale__c = 'Australia (+61)';
                    c.ContactWorkPhone_Locale__c = 'Australia (+61)';
                    c.ContactPhone_Locale__c = 'Australia (+61)';
            }
            update(contactsToUpdate);

            Test.stopTest();
            system.assert(![SELECT Id FROM Contact Where ContactPhone_Validation__c = 'None'].isEmpty(), 'ContactPhone Validation Status should be None');
            system.assert(![SELECT Id FROM Contact Where ContactMobile_Validation__c = 'None'].isEmpty(), 'ContactMobile Validation Status should be None');
            System.assert(![SELECT Id FROM Contact Where ContactWorkPhone_Validation__c = 'None'].isEmpty(), 'ContactWorkPhone Validation Status should be None');
        }
	}
}