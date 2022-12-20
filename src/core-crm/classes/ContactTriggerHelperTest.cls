/**
 * @description Test Class for ContactTriggerHelper
 *
 * @see ../fContactTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                            |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------------|
      | angelika.j.s.galang       | November 3, 2021      | DEPP-734     | Created file                                              | 
      | roy.nino.s.regala         | January  18,2022      | DEPP-1178    | Updated for logic when primary bussiness org is populated | 
      |                           |                       |              |                                                           |
*/
@isTest
private class ContactTriggerHelperTest {
    
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    private static final Id ADMINISTRATIVE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Administrative').getRecordTypeId();

    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactory.generateTestUsers();
        Test.stopTest();

        List<Account> accountList = new List<Account>();
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
        accountList.add(acc);
        insert accountList;
        
    } 

    @isTest
    private static void insertContactTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()){
            List<Account> accList = [SELECT Id, RecordTypeId From Account WHERE RecordTypeId =: BUSINESS_ACC_RECTYPEID OR RecordTypeId =: ADMINISTRATIVE];
            Id adminAccount;
            Id businessAccount;
            for(Account acc: accList){
                if(acc.RecordTypeId == BUSINESS_ACC_RECTYPEID){
                    businessAccount = acc.Id;
                }else if(acc.RecordTypeId == ADMINISTRATIVE){
                    adminAccount = acc.Id;
                }
            }            
            
            List<Contact> conList = TestDataFactory.createTestContactRecords(100);
            for(Integer i = 0;i<conList.size(); i++){
                conList[i].hed__Primary_Organization__c = businessAccount;
            }

            Test.startTest();
            insert(conList);
            Test.stopTest();
            
            List<AccountContactRelation> acrt = new List<AccountContactRelation>([SELECT Id FROM AccountContactRelation WHERE Account.RecordTypeId =: BUSINESS_ACC_RECTYPEID]);
            System.assert(acrt.size() == 100,'Contacts where not updated');
        }
    }

}