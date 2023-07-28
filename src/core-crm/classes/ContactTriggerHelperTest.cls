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
      | mark.j.mahilum            | July 28, 2023         | DEPP-6106    | Added test class coverage for can nurture logic           |
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

    @isTest
    private static void updatePrimaryBusinessOrgContactTest(){
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
            for(Integer i = 0;i<conList.size(); i++){
                conList[i].hed__Primary_Organization__c = null;
            }
            update(conList);
            Test.stopTest();
            
            List<AccountContactRelation> acrt = new List<AccountContactRelation>([SELECT Id FROM AccountContactRelation WHERE Account.RecordTypeId =: BUSINESS_ACC_RECTYPEID AND IsActive = false]);
            System.assert(acrt.size() == 100,'Contacts where not updated');
        }
    }

    @isTest
    private static void testContactCanNurtureFlag() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Lead_Score_Threshold__c = 1;
            nurtureConfig.Status__c = 'Active';
            nurtureList.add(nurtureConfig);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);  
            
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(10);  
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;           
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();            
            List<Contact> updateContactList = new List<Contact>();
            for(Contact con: newContacts){
                Contact conRec = new Contact();
                conRec.Id = con.Id;
                conRec.Score__c = 3;
                updateContactList.add(conRec);
            }            
            Database.SaveResult[] srList = ContactsDAO.newInstance().updateRecords(updateContactList, false, AccessLevel.SYSTEM_MODE);
            
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }
            List<Contact> con = [SELECT Id,Can_Nurture__c FROM Contact WHERE RecordTypeId =: ContactsDAO.PERSON_RECORDTYPE_ID];
            System.assert(con[0].Can_Nurture__c,'Contacts can nurture flag not updated');
            
        }
    }

}