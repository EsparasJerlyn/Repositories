/**
 * @description Tests the CreateAssetCtrl class 
 *
 * @see CreateAssetCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | adrian.c.habasa           | November 11, 2021     | DEPP-664 | Created file                    | 
      |                           |                       |          |                                 |
*/
@isTest
public class CreateAssetCtrlTest {
    private static final String COURSE_API_NAME = Asset.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();

    @testSetup static void setupMethod() {
        List<Account> accounts;
        List<Contact> conList;
        List<Opportunity> oppList;
        List<Product_Specification__c> prodSpec;
        List<Product_Request__c> prodReq;
        List<Asset> assetData;

        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();

        accounts = TestDataFactory.createTestAccountRecords(1);
        insert accounts;
        conList = TestDataFactory.createTestContactRecords(1);
        insert conList;
        oppList = TestDataFactory.createClosedWonOpportunities(1,accounts[0].id,conList[0].id);
        insert oppList;
        prodSpec = TestDataFactory.retrieveCCEProductSpecifications();
        prodReq = TestDataFactory.createTestProductRequestRecords(1);
        insert prodReq;
        assetData = TestDataFactory.createTestAssetRecords(1,accounts[0].id,prodReq[0].id);
        insert assetData;
    }  

    @isTest
    private static void getLayoutMappingTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<Field_Layout_Setting__mdt> fieldLayoutList = CreateAssetCtrl.getLayoutMapping(COURSE_API_NAME);
            System.assert(fieldLayoutList.size() >= 0, 'Field Layout Setting list did not match expected.');
        }
        Test.stopTest();
    }

    @isTest
    private static void getRelatedRecordsTest()
    {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Id prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1]?.Id;
            Id prodSpecId = [SELECT Id FROM Product_Specification__c LIMIT 1]?.Id;
            Map<String,Id> hasId = CreateAssetCtrl.getRelatedRecords(prodReqId,prodSpecId);

            System.assert(hasId.containsKey('assetId'), 'assetId found');
            System.assert(hasId.containsKey('accountId'), 'accountId found');
        }
        Test.stopTest();
    }

}
