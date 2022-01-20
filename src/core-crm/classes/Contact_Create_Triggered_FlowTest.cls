/**
 * @description Test Class for Contact Create Triggered Flow 
 *
 * @see ../flows/Contact_Create_Triggered_Flow
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
@IsTest(SeeAllData = false)
private class Contact_Create_Triggered_FlowTest {
    
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    private static final String STR_QUTEX = 'QUTeX';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTEX).iterator().next();  

    @testSetup static void setupMethod() {
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
        insert acc;
    } 

    @IsTest
    private static void insertContactTest(){
        System.runAs(currentUser){
            Account acc = [SELECT Id From Account LIMIT 1];
            
            List<Contact> conList = TestDataFactory.createTestContactRecords(100);
            for(Contact con : conList){
                con.AccountId = acc?.Id;
            }

            Test.startTest();
            insert(conList);
            Test.stopTest();
			
            Map<Id,Contact> insertedConMap = new Map<Id,Contact>([SELECT Id,AccountId FROM Contact LIMIT 100]);

            List<hed__Affiliation__c> insertedAffiliationList = [SELECT Id FROM hed__Affiliation__c WHERE hed__Contact__c IN :insertedConMap.keyset()];
            System.assert(insertedAffiliationList.size() == 100,'Affiliation records created did not match expected');
        }
    }

    @IsTest
    private static void insertContactWithPrimaryBusinesssOrgTest(){
        System.runAs(currentUser){
            Account acc = [SELECT Id From Account LIMIT 1];
            
            List<Contact> conList = TestDataFactory.createTestContactRecords(100);
            for(Contact con : conList){
                con.hed__Primary_Organization__c = acc?.Id;
            }

            Test.startTest();
            insert(conList);
            Test.stopTest();
			
            List<AccountContactRelation> insertedACRList = [SELECT Id FROM AccountContactRelation WHERE ContactId IN :conList AND AccountId =: acc.Id];
            System.assert(insertedACRList.size() == 100,'Account Contact Relation records created did not match expected');
            List<Account> finalAccountsList = [SELECT Id FROM Account];
            System.assert(finalAccountsList.size() == 1,'Administrative accounts were not deleted');
        }
    }
}