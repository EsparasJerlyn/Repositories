/**
 * @description Test class for ContactTriggerMDMIntegration
 * @see classes/ContactTriggerMDMIntegration
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eccarius.munoz            | February 07, 2023     | DEPP-5040    | Created file                                | 
      |                           |                       |              |                                             | 
 */
@isTest
public with sharing class ContactTriggerMDMIntegrationTest {

    @testSetup
    static void setupData(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
    }

    @isTest
    private static void logMDMStudentsAfterContactInsertTest(){        
        
        Boolean hasError = false;
        String errorMessage;

        Test.startTest();
        
        Integration_Settings__c integrationSettings = new Integration_Settings__c(Allow_ESB_Integration__c = true);
        insert integrationSettings;

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            try{
                List<Contact> contacts = TestDataFactory.createTestContactRecords(2);
                if(Schema.sObjectType.Contact.isUpdateable()){
                    insert contacts;
                }
                
            }catch(Exception e){
                hasError = true;
                errorMessage = e.getMessage();
            }
        }
        Test.stopTest();
        System.assert(!hasError, 'Error in call out : ' + errorMessage);
    }

    @isTest
    private static void logMDMStudentsAfterContactUpdateTest(){

        Boolean hasError = false;
        String errorMessage;
        
        Test.startTest();

        Integration_Settings__c integrationSettings = new Integration_Settings__c(Allow_ESB_Integration__c = false);
        insert integrationSettings;

        TestDataFactory.createTestContactRecords(2);

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            try{
                List<Contact> contactList = [SELECT Id FROM Contact WHERE FirstName LIKE '%Test%' AND LastName LIKE '%Contact%' WITH SECURITY_ENFORCED];
                for(Contact con : contactList){
                    con.hed__Gender__c = 'Male';
                }
                if(Schema.sObjectType.Contact.isUpdateable()){
                    update contactList;
                }
            }catch(Exception e){
                hasError = true;
                errorMessage = e.getMessage();
            }
        }
        Test.stopTest();
        System.assert(!hasError, 'Error in call out : ' + errorMessage);
    }
}