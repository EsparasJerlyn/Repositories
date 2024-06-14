/**
 * @description Batch class complete SOA product requests
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin   	       | Aug. 11, 2022         | DEPP-3481              | Created file                 | 
 */
@isTest
public with sharing class AssetToCompleteBatchTest {
    private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
    private static final Id CORPORATEBUNDLE_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Corporate_Bundle').getRecordTypeId();
    private static final Id ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
    private static final Id PROGRAM_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Program').getRecordTypeId();
    private static final Id ACTIVITY_COURSE_ID = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(ACCT_UNIV_DEP)
      .getRecordTypeId();

    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();

    }
        
    @isTest
    private static void runToCompleteTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {

            List<Account> accountList = TestDataFactory.createTestAccountRecords(2);
            for(Account acc: accountList){
                acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
            }
            insert accountList;
    
            List<Account> accounts;
            accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;
            List<Contact> conList;
            conList = TestDataFactory.createTestContactRecords(1);
            insert conList;
    
            List<Opportunity> oppList = TestDataFactory.createClosedWonOpportunities(1,accounts[0].Id,conList.iterator().next()?.Id);
            insert oppList; // Product Specifications were created after insert
    
            List<Product_Specification__c> prodSpecList = TestDataFactory.retrieveCCEProductSpecifications();
    
            List<Product_Request__c> soaRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
            for(Product_Request__c pr : soaRequest){
                pr.RecordTypeId = CORPORATEBUNDLE_ID;        
            }
            insert soaRequest;
    
            Asset aInsert = new Asset();
            aInsert.Name = accountList[0].Name + ' ' + String.valueofGmt(System.now());
            aInsert.AccountId = accountList[0].Id;
            aInsert.Product_Request__c = soaRequest[0].Id;
            aInsert.End_Date__c = Date.Today();
            insert aInsert;
            
            List<Product_Request__c> courseRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
            for(Product_Request__c pr : courseRequest){
                pr.RecordTypeId = ACTIVITY_ID;        
            }
            insert courseRequest;

            List<hed__Course__c> courses;
            courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,courseRequest[0].Id);
            for(hed__Course__c c: courses){
                c.RecordTypeId = ACTIVITY_COURSE_ID;
            }
            insert courses;

            List<Product_Request__c> programRequest;
            programRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
            programRequest[0].Product_Request_Name__c = 'PROGRAM REQUEST';
            programRequest[0].RecordTypeId = PROGRAM_ID;
            insert programRequest;

            List<hed__Program_Plan__c> programPlanList;
            programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
            for(hed__Program_Plan__c prog: programPlanList){
                prog.Product_Request__c = programRequest[0].Id;
            }
            insert programPlanList;

            List<Associated_Products__c> assocProdList = new List<Associated_Products__c>();
            List<Product2> prod = new List<Product2>([SELECT Id From Product2 WHERE Course__c IN: courses]);
            assocProdList.add(new Associated_Products__c(Product__c = prod[0].Id, Product_Request__c = soaRequest[0].Id, IsActive__c = true));
            insert assocProdList;

            Test.startTest();

            AssetToCompleteBatch batch = new AssetToCompleteBatch();
            Database.executeBatch(batch);

            Test.stopTest();

            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'AssetToCompleteBatch'].isEmpty() , 'AssetToCompleteBatch Job was not executed');
        }
    }
}