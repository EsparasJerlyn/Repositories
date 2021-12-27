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
@IsTest(SeeAllData=false)
private class Prod_Spec_Not_Proceeding_Notif_FlowTest{
    
    private static final String STR_PROFILE = 'QUTeX';
    private static User  currentUser = TestDataFactory.createUserRecords(1, STR_PROFILE).iterator().next();
    private static Integer numberOfRecords = 100;
          
    @IsTest 
    private static void insertUpdateLeadRecordTest(){  
        System.runAs(currentUser){

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
            }
            insert productSpecifications;

            Test.startTest(); 
            List<Product_Specification__c> productSpecificationList = [SELECT Id, Not_Proceeding_Comments__c, Stage__c, Status__c FROM Product_Specification__c];
            for(Product_Specification__c productSpecs : productSpecificationList){
                productSpecs.Stage__c = 'Not Proceeding';
                productSpecs.Status__c = 'Doesnt meet Qualification';
                productSpecs.Not_Proceeding_Comments__c = 'Test';
            }
            update productSpecificationList;
                      
            Test.stopTest();
            System.assertEquals(0, Limits.getEmailInvocations());
        }        
    } 
}