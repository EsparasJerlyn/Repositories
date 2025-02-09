/**
 * @description Test Class for Remove Marketing Cloud Flag
 *
 * @see RemoveMarketingCloudFlag.cls
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eugene.andrew.abuan	      | October 23, 2022      | NA           | Created file                                |
      |                           |                       |              |                                             |
*/
@isTest
private class RemoveMarketingCloudFlagTest {

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserIndustryPartnershipManager();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
           List<Contact> contacts = TestDataFactory.createTestContactRecords(200);
            for(Contact c : contacts){
                c.Sync_To_MC__c = true;
                c.Do_Not_Sync_To_MC_Override__c = true;
            }
            ContactsDAO.newInstance().insertRecords(contacts, false, AccessLevel.SYSTEM_MODE);
        }
    }

    @isTest
    static void invalidateFieldsForObjectTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();

            // Start the batch job
            RemoveMarketingCloudFlag batch = new RemoveMarketingCloudFlag();
            batch.invalidateFieldsForObject('Contact');
    
            Test.stopTest();
    
            // Verify that the records were processed
            List<Contact> updatedRecords = [SELECT Id, Sync_to_MC__c FROM Contact WHERE Sync_to_MC__c = true];
            System.assertEquals(0, updatedRecords.size(), 'All records should have Sync_to_MC__c set to false');
        }
    }

    @isTest
    static void invalidateFieldsForObjectExceptionTest(){
        String expectedMessage = 'sObject requested does not exist or user has no access to it';
        String resultMessage;
        try{
             System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager){
                 Test.startTest();
                 // Start the batch job
                 RemoveMarketingCloudFlag batch = new RemoveMarketingCloudFlag();
                 batch.invalidateFieldsForObject('Invalid_Object_Name__c');
                 Test.stopTest();
             }
         }catch(Exception e){
             resultMessage = e.getMessage();
         }finally{
             System.assertEquals(expectedMessage, resultMessage, 'Exception message should match.');
         }
    }
}