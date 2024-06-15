/**
 * @description Test Class for BuyerGroupMemberRelatedListCtrlTest
 *
 * @see ../classes/BuyerGroupMemberRelatedListCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | roy.nino.s.regala         | August 8, 2022        | DEPP-2498    | Created file                                | 
      |                           |                       |              |                                             | 
*/
@isTest
private class BuyerGroupMemberRelatedListCtrlTest {
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    

    @testSetup
    static void setupMethod(){

        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();

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

        List<Product_Request__c> productRequestList = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
        for(Product_Request__c productRequest : productRequestList){
            productRequest.Product_Request_Status__c = 'Release';            
        }
        insert productRequestList;

        BuyerGroup bgInsert = new BuyerGroup();
        bgInsert.Name = accountList[0].Name + ' ' + String.valueofGmt(System.now());
        bgInsert.Product_Request__c = productRequestList[0].Id;
        insert bgInsert;

        BuyerGroupMember bgMemberInsert = new BuyerGroupMember();
        bgMemberInsert.BuyerGroupId = bgInsert.Id;
        bgMemberInsert.BuyerId = accountList[0].Id;
        insert bgMemberInsert;

        WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
        insert testWebStore;

        
    } 

    @isTest
    static void getSearchedAccountsTest() {
        List<Product_Request__c> prList = new List<Product_Request__c>([SELECT Id FROM Product_Request__c LIMIT 1]);
        List<Map<String,String>> searchResult = new List<Map<String,String>>();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            if(!prList.isEmpty()){
                Test.startTest();
                searchResult = BuyerGroupMemberRelatedListCtrl.getSearchedAccounts('TestAccount',prList[0].Id);
                Test.stopTest();
                
            }
            System.assert(!searchResult.isEmpty(),'no search results');
        }
    }

    @isTest
    static void createBuyerGroupMemberTest(){

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            List<BuyerGroup> bg = new List<BuyerGroup>([SELECT Id FROM BuyerGroup LIMIT 1]);
            List<Account> newAccount = TestDataFactory.createTestAccountRecords(1);
                for(Account acc: newAccount){
                    acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
                }
            insert newAccount;

            Boolean isCreated = BuyerGroupMemberRelatedListCtrl.createBuyerGroupMember(newAccount[0].Id,bg[0].Id);
            System.assert(isCreated, 'no buyer group member created');
            Test.stopTest();
        }
        
    }


    @isTest
    static void getBuyerGroupRecordTest(){

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            List<Product_Request__c> prList = new List<Product_Request__c>([SELECT Id FROM Product_Request__c LIMIT 1]);

            Id buyerGroupId = BuyerGroupMemberRelatedListCtrl.getBuyerGroupRecord(prList[0].Id);
            System.assert(buyerGroupId != null, 'no buyer group pulled');
            Test.stopTest();
        }
        
    }

    @isTest
    static void getRelatedBuyerGroupMembersListTest(){

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            List<Product_Request__c> prList = new List<Product_Request__c>([SELECT Id FROM Product_Request__c LIMIT 1]);

            List<BuyerGroupMember> bgMemberList = BuyerGroupMemberRelatedListCtrl.getRelatedBuyerGroupMembersList(prList[0].Id);
            System.assert(!bgMemberList.isEmpty(), 'no buyer group member pulled');
            Test.stopTest();
        }
        
    }
}
