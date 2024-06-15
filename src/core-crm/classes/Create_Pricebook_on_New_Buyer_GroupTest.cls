/**
 * @description test class for Create Pricebook for SOA Flow
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala   	       | August 9, 2022        | DEPP-2498              | Created file                 | 
      | alexander.cadalin   	       | August 18, 2022       | ST Fix                 | Changed buyer group name     |
 */
@isTest
public with sharing class Create_Pricebook_on_New_Buyer_GroupTest {
    private static final Id SOA_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Standing_Offer_Arrangement').getRecordTypeId();
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(ACCT_UNIV_DEP)
      .getRecordTypeId();

    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
    }
        
    @isTest
    private static void createBuyerGroupTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {

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
            insert oppList;
    
            List<Product_Specification__c> prodSpecList = TestDataFactory.retrieveCCEProductSpecifications();
    
            List<Product_Request__c> soaRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
            for(Product_Request__c pr : soaRequest){
                pr.RecordTypeId = SOA_ID;        
            }
            insert soaRequest;

            Test.startTest();

            BuyerGroup bgInsert = new BuyerGroup();
            bgInsert.Name = soaRequest[0].Product_Request_Name__c;
            bgInsert.Product_Request__c = soaRequest[0].Id;
            insert bgInsert;
        
            System.assert(
                ![SELECT Id FROM BuyerGroupPriceBook WHERE BuyerGroupId =: bgInsert.Id].isEmpty(),
                'Buyer group price book not set'
            );

            Test.stopTest();

        }
    }
}