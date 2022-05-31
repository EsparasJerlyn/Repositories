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
@IsTest(SeeAllData = false)
private class LoqateMobileValidationBatchTest {
    
    private static final String LEAD_API_NAME = Lead.SObjectType.getDescribe().getLocalName();
	private static final String CONTACT_API_NAME = Contact.SObjectType.getDescribe().getLocalName();
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
        insert contacts;

        List<Lead> leads = TestDataFactory.createTestLeadRecords(5);
        for(Lead lead: leads){
            lead.LeadMobile_Locale__c = AU_LOCALE;
            lead.LeadMobile_Validation__c = 'None';
            lead.Mobile_No_Locale__c = '123456';
        }
        insert leads;
        
    }

    @IsTest
    private static void validateContactPhoneFieldsTest(){
        Test.startTest();

            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Id batchJobId = Database.executeBatch(new LoqateMobileValidationBatch('Contact'));

        Test.stopTest();
    }
    @IsTest
    private static void validateLeadPhoneFieldsTest(){
        Test.startTest();

            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Id batchJobId = Database.executeBatch(new LoqateMobileValidationBatch('Lead'));

        Test.stopTest();
    }



}
