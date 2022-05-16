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
      |                           |                       |              |                                             | 
*/
@IsTest(SeeAllData = false)
private class BuyerGroupFlowTest {
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    
    @testSetup static void setupMethod() {
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
        insert acc;
        WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
        insert testWebStore;
    } 
    @IsTest
    static void createBuyerGroupAndEntitlementTest() {

        Test.startTest();
        List<Account> acc = new List<Account>([SELECT Id FROM Account LIMIT 1]);
        for(Account a : acc){
            a.IsPartner = true;
        }
        update(acc);
        List<BuyerAccount> bacc = new List<BuyerAccount>([SELECT Id FROM BuyerAccount LIMIT 1]);
        for(BuyerAccount b : bacc){
            b.CommerceType = 'Buyer';
            b.IsActive=True;
        }
        update(bacc);

        Test.stopTest();
        System.Assert(![SELECT Id FROM BuyerGroup].isEmpty(), 'No Buyer Group was Created');
        System.Assert(![SELECT Id FROM BuyerGroupMember].isEmpty(), 'No Account was assigned to the Buyer Group');
        System.Assert(![SELECT Id FROM WebStoreBuyerGroup].isEmpty(), 'No Buyer Group was Assigned to the Store');
        System.Assert(![SELECT Id FROM CommerceEntitlementPolicy].isEmpty(), 'No Entitlement was created');
        System.Assert(![SELECT Id FROM CommerceEntitlementBuyerGroup].isEmpty(), 'No  Entitlement was created');
    }
}
