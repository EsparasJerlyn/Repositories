/**
 * @description Tests the LoqateMobileValidationBatch
 *
 * @see LoqateMobileValidationBatch
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | roy.nino.s.regala         | May 31, 2022          | DEPP-2105| Created file                    | 
*/
@isTest
private class LoqateMobileValidationBatchTest {
    
    private static final String LEAD_API_NAME = Lead.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
	private static final String CONTACT_API_NAME = Contact.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
    private static final String AU_LOCALE = 'Australia (+61)';
    private static final String NZ_LOCALE = 'New Zealand (+64)';
    private static final String NONE_STATUS = 'None';


    @testSetup static void setup() {
    

        List<Contact> contacts = TestDataFactory.createTestContactRecords(5);
        for(Contact con: contacts){
            con.Company_Name__c = 'Test Comapny';
            con.ContactMobile_Locale__c = AU_LOCALE;
            con.ContactMobile_Validation__c = 'None';
            con.Mobile_No_Locale__c = '123456';
        }
        List<Contact> contactsNz = TestDataFactory.createTestContactRecords(5);
        for(Contact con: contactsNz){
            con.FirstName = 'Test NZ';
            con.Company_Name__c = 'Test Comapny2';
            con.ContactMobile_Locale__c = NZ_LOCALE;
            con.ContactMobile_Validation__c = 'None';
            con.Mobile_No_Locale__c = '123456';
        }
        contacts.addAll(contactsNz);
        insert contacts;

        List<Lead> leads = TestDataFactory.createTestLeadRecords(5);
        for(Lead lead: leads){
            lead.LeadMobile_Locale__c = AU_LOCALE;
            lead.LeadMobile_Validation__c = 'None';
            lead.Mobile_No_Locale__c = '123456';
        }
        List<Lead> leadsNZ = TestDataFactory.createTestLeadRecords(5);
        for(Lead lead: leadsNZ){
            lead.LastName = 'Test NZ';
            lead.LeadMobile_Locale__c = NZ_LOCALE;
            lead.LeadMobile_Validation__c = 'None';
            lead.Mobile_No_Locale__c = '123456';
        }
        leads.addAll(leadsNZ);
        insert leads;

        TestDataFactoryUser.generateUserSystemAdministrator();

    }

    @isTest
    private static void validateContactPhoneFieldsTest(){
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
		System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();

                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                Database.executeBatch(new LoqateMobileValidationBatch('Contact'),10);

                
            Test.stopTest();
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'LoqateMobileValidationBatch'].isEmpty() , 'LoqateMobileValidationBatch Job was not executed');
        }
    }
    @isTest
    private static void validateLeadPhoneFieldsTest(){
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
		System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();

                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                Database.executeBatch(new LoqateMobileValidationBatch('Lead'),10);

            Test.stopTest();
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'LoqateMobileValidationBatch'].isEmpty() , 'LoqateMobileValidationBatch Job was not executed');
        }
    }



}
