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
    private static void getQUTeXAccountId()
    {
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


}