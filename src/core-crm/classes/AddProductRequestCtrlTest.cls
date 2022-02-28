/**
 * @description Tests the Add Product Request Controller Test Class
 *
 * @see AddProductRequestCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | roy.nino.s.regala         | October 01, 2021      | DEPP40,42 | Created file                    | 
      | adrian.c.habasa           | January 20, 2022      | DEPP-1471 | Added Test Class Method         | 
*/
@isTest(SeeAllData=false)
private class AddProductRequestCtrlTest {

    private static final String PRODUCT_REQ_API_NAME = Product_Request__c.SObjectType.getDescribe().getLocalName();
    private static final String ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final Id ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(ACTIVITY).getRecordTypeId();
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    
    static testMethod void testGetFieldLayoutSettings() {
        Test.startTest();
        System.runAs(currentUser){
            AddProductRequestCtrl.MetadataDetails getMetadata = new AddProductRequestCtrl.MetadataDetails();
            getMetadata = AddProductRequestCtrl.getFieldLayoutSettings('Product_Request__c',false);
            system.assert( !getMetadata.fieldLayoutMap.isEmpty(), 'unable to get recordtype and layout metadata');
        }
        Test.stopTest();
    }

    static testMethod void testGetFieldLayoutSettingsError() {
        Test.startTest();
        try{
            System.runAs(currentUser){
                AddProductRequestCtrl.MetadataDetails getMetadata = new AddProductRequestCtrl.MetadataDetails();
                getMetadata = AddProductRequestCtrl.getFieldLayoutSettings(null,null);
            }
        }catch(Exception e){
            system.assertEquals('Error while getting record type and layout mapping.',e.getMessage(),'Exception should have been thrown');
        }
        Test.stopTest();
    }

    @isTest
    private static void testGetQUTeXAccountId(){
        Test.startTest();
        System.runAs(currentUser){
           List<Account> acc= TestDataFactory.createTestAccountRecords(1);
           Account a = new Account(Name = 'QUTeX');
           acc.add(a);
           insert acc;
           String accId=AddProductRequestCtrl.getAccountId();
           system.assert(!String.isBlank(accId),'No QUTeX Account Found');
        }
        Test.stopTest();
    }

    @isTest
    private static void testGetRecordTypes(){
        System.runAs(currentUser){
            Test.startTest();
            List<Map<String,String>> recordTypeMap = AddProductRequestCtrl.getRecordTypes(PRODUCT_REQ_API_NAME,new List<Id>{ACTIVITY_ID});
            Test.stopTest();
            System.assertEquals(ACTIVITY, recordTypeMap[0].get('label'), 'Record type did not match as expected');
        }
    }
}