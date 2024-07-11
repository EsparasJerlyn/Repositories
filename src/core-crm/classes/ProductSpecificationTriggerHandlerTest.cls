/**
 * @description Tests the ProductSpecificationTriggerHandlerClass
 *
 * @see ProductSpecificationTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                                  |
      |---------------------------|-----------------------|-----------|-------------------------------------------------|
      | sebastianne.k.trias       | January 19, 2023      | DEPP-5087 | Created file                                    |
*/
@isTest
public with sharing class ProductSpecificationTriggerHandlerTest {
    
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static final String STR_QUALIFY = 'Qualify';
    private static final String STR_IN_PROGRESS = 'In Progress';

    @testSetup
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Account> accounts;
            accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;
            
            List<Contact> contacts;
            contacts = TestDataFactory.createTestContactRecords(2);
            insert contacts;
            
            List<Opportunity> opps;
            opps = TestDataFactory.createTestOpportunityRecords(2,accounts[0].Id,contacts[0].Id);
            for(Opportunity opp : opps){
                opp.StageName = 'Closed Won';
            }
            insert opps;
        }
    }

    @isTest
    static void validateInsertProductSpecificationTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            DmlException expectedException;
            Test.startTest();
                List<Contact> contacts = [Select Id, Name From Contact];
                List<Opportunity> opps = [Select Id, Name From Opportunity];
                List<Product_Specification__c> psList;
                psList = TestDataFactory.createTestProductSpecsRecords(2,contacts,opps);
                try{
                    insert psList;
                }
                catch(DmlException e){
                    expectedException = e;
                }
            Test.stopTest();
            System.assert(expectedException.getMessage().contains('A Product Specification is already linked to this Opportunity'),'Should contain A Product Specification is already linked to this Opportunity');
        }
    }
    
    @isTest
    static void validateUpdateProductSpecificationTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            DmlException expectedException;
            Test.startTest();
                List<Product_Specification__c> psList = [SELECT Id, Name, Opportunity_Name__c FROM Product_Specification__c];
                List<Opportunity> opps = [Select Id, Name From Opportunity];
                for(Product_Specification__c ps : psList){
                    ps.Opportunity_Name__c = opps[0].Id;
                }
                try{
                    update psList;
                }
                catch(DmlException e){
                    expectedException = e;
                }
            Test.stopTest();
            System.assert(expectedException.getMessage().contains('A Product Specification is already linked to this Opportunity'),'Should contain A Product Specification is already linked to this Opportunity');
        }
    }
}