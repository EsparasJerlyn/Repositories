/**
 * @description Test Class for Enable Partner and Buyer
 *
 * @see ../flows/Enable_Partner_and_Buyer
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eugene.andrew.abuan       | January  06, 2021     | DEPP-1391    | Created file                                | 
      |                           |                       |              |                                             | 
*/
@IsTest(SeeAllData = false)
public with sharing class Enable_Partner_and_Buyer_FlowTest {
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();

    @IsTest
    static void enablePartnerBuyerTest(){
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
        insert acc;

        Test.startTest();
        List <Account> acc1 = [SELECT IsPartner From Account LIMIT 1];
        for (Account a : acc1){
            Boolean isPartner = Boolean.valueOf(a.IsPartner);
        }
        Test.stopTest();
    }
}