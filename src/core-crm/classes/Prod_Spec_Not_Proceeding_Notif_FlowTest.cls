/**
 * @description Tests Product Specification Not Proceeding Notification Flow
 *
 * @see Product_Specification_Not_Proceeding_Notification
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | eccarius.karl.munoz       | December 24, 2021     | DEPP-248 | Created file                    | 
      |                           |                       |          |                                 | 
*/
@isTest
private class Prod_Spec_Not_Proceeding_Notif_FlowTest{
    private static Integer numberOfRecords = 100;

    @testSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest 
    private static void insertUpdateLeadRecordTest(){
        Id opeProductSpecsId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('OPE').getRecordTypeId();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            
            Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
            insert customEmail;

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            insert accounts;
    
            List<Contact> contacts = TestDataFactory.createTestContactRecords(numberOfRecords);
            Integer ctr = 1;
            for(Contact contact : contacts){
                contact.Email = ctr + 'test@mailinator.com';
                ctr++;
            }
            insert contacts;
    
            List<Opportunity> opportunities = TestDataFactory.createTestOpportunityRecords(numberOfRecords, accounts[0].Id, contacts.iterator().next()?.Id);
            insert opportunities;
            
            List<Product_Specification__c> productSpecifications = TestDataFactory.createTestProductSpecsRecords(numberOfRecords, contacts, opportunities);
            for(Product_Specification__c productSpecification : productSpecifications){
                productSpecification.Stage__c = 'Idea';
                productSpecification.Requestor_Name__c = contacts[0].Id;
                productSpecification.Endorsed_by__c = contacts[0].Id;
                productSpecification.Idea_Summary__c = 'Test';
                productSpecification.RecordTypeId = opeProductSpecsId;
            }
            insert productSpecifications;

            Test.startTest(); 
            List<Product_Specification__c> productSpecificationList = [SELECT Id, Not_Proceeding_Comments__c, Stage__c, Status__c, RecordType.Name 
                                                                       FROM Product_Specification__c 
                                                                       WHERE RecordTypeId=:opeProductSpecsId];
            for(Product_Specification__c productSpecs : productSpecificationList){
                productSpecs.Stage__c = 'Not Proceeding';
                productSpecs.Status__c = 'Doesnt meet Qualification';
                productSpecs.Not_Proceeding_Comments__c = 'Test';
            }
            update productSpecificationList;
                      
            Test.stopTest();
            System.assertEquals(0, Limits.getEmailInvocations(), 'Email Invocations != 0');
        }        
    } 
}