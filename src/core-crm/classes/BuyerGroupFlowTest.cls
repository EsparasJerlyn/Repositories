/**
 * @description Test Class for CCE Buyer Groups and Entitlement Creation Flow
 *
 * @see ../flows/CCE_Buyer_Groups_and_Entitlements_Creation_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eugene.andrew.abuan       | December 10, 2021     | DEPP-100     | Created file                                | 
      | eugene.andrew.abuan       | August 19, 2022       | DEPP-2665    | Updated Test class for the updated flow     | 
*/
@isTest
private class BuyerGroupFlowTest {
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    
    @testSetup static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) { 
            WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
            insert testWebStore;
        }
    } 
    @isTest
    static void createBuyerGroupAndEntitlementTest() {
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
        insert acc;

        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){ 
        Test.startTest();
            System.Assert(![SELECT Id FROM BuyerGroup].isEmpty(), 'No Buyer Group was Created');
            System.Assert(![SELECT Id FROM BuyerGroupMember].isEmpty(), 'No Account was assigned to the Buyer Group');
            System.Assert(![SELECT Id FROM WebStoreBuyerGroup].isEmpty(), 'No Buyer Group was Assigned to the Store');
            System.Assert(![SELECT Id FROM CommerceEntitlementPolicy].isEmpty(), 'No Entitlement was created');
            System.Assert(![SELECT Id FROM CommerceEntitlementBuyerGroup].isEmpty(), 'No  Entitlement was created');
        Test.stopTest();
        }
    }
}
