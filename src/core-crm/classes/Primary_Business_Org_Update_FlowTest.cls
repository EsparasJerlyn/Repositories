/**
 * @description Test Class for Contact Primary Business Organization Update Flow
 * 
 * @see ../flows/Contact_Primary_Business_Organization_Update
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | roy.nino.s.regala         | January 18, 2022      | DEPP-1178    | Created file                                | 
      |                           |                       |              |                                             | 
*/
@IsTest(SeeAllData = false)
private class Primary_Business_Org_Update_FlowTest {
    
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    private static final Id ADMINISTRATIVE_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Administrative').getRecordTypeId();
    private static final String STR_QUTEX = 'QUTeX';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTEX).iterator().next();  

    @IsTest
    private static void changePrimaryBusinessOrg(){
        List<Contact> conList = TestDataFactory.createTestContactRecords(100);
        System.runAs(currentUser){
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        
            acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
            insert acc;
            
            for(Contact con : conList){
                con.hed__Primary_Organization__c = acc?.Id;
            }
        
            insert conList;

            Account secondAcc = new Account(Name ='Test 001', RecordTypeId = BUSINESS_ACC_RECTYPEID);
            insert secondAcc;

            for(Contact con : conList){
                con.hed__Primary_Organization__c = secondAcc?.Id;
            }

            Test.startTest();
            update conList;
            Test.stopTest();
        }
        	List<AccountContactRelation> insertedACRList = [SELECT Id FROM AccountContactRelation WHERE ContactId IN:conList];

            List<AccountContactRelation> updatedACRList = [SELECT Id FROM AccountContactRelation WHERE ContactId IN :conList AND IsActive = False];

            List<Account> finalAccountsList = [SELECT Id FROM Account];

    }

    @IsTest
    private static void populatePrimaryBusinessOrg(){
        List<Contact> conList = TestDataFactory.createTestContactRecords(100);
        System.runAs(currentUser){
        
            insert conList;

            Account secondAcc = new Account(Name ='Test 001', RecordTypeId = BUSINESS_ACC_RECTYPEID);
            insert secondAcc;

            for(Contact con : conList){
                con.hed__Primary_Organization__c = secondAcc?.Id;
            }

            Test.startTest();
            update conList;
            Test.stopTest();
        }
        	List<AccountContactRelation> insertedACRList = [SELECT Id FROM AccountContactRelation WHERE ContactId IN:conList];

            List<AccountContactRelation> updatedACRList = [SELECT Id FROM AccountContactRelation WHERE ContactId IN :conList AND IsActive = False];

            List<Account> finalAccountsList = [SELECT Id FROM Account];

    }

    @IsTest
    private static void removePrimaryBusinessOrg(){
        List<Contact> conList = TestDataFactory.createTestContactRecords(100);
        System.runAs(currentUser){
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        
            acc.RecordTypeId = BUSINESS_ACC_RECTYPEID;
            insert acc;
            
            for(Contact con : conList){
                con.hed__Primary_Organization__c = acc?.Id;
            }
        
            insert conList;

            for(Contact con : conList){
                con.hed__Primary_Organization__c = null;
            }

            Test.startTest();
            update conList;
            Test.stopTest();
        }
        	List<AccountContactRelation> insertedACRList = [SELECT Id FROM AccountContactRelation WHERE ContactId IN:conList];

            List<Account> finalAccountsList = [SELECT Id FROM Account];

    }

    
}