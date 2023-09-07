/**
 * @description Test class for LeadScoreDetailTriggerHandler
 * @see LeadScoreDetailTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | julie.jane.alegre              | Sept 07, 2023         | DEPP-5965              | Created file                                     |
 */
@isTest
private class LeadScoreDetailTriggerHandlerTest {
    private static Integer numberOfRecords = 100;

    @testSetup
    static void setupMethod(){  
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }
    @isTest 
    private static void linkLeadScoreDetailToContactTest(){ 
        System.runAs(TestDataFactory.getProgramAdminUser()){ 
            Test.startTest();
            List<Lead_Score_Detail__c> lsdToInsert = new List<Lead_Score_Detail__c>();
            List<Contact> contactList = TestDataFactory.createTestContactRecords(numberOfRecords);
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.SYSTEM_MODE);
            
            for(Integer i = 0; i < numberOfRecords; i++){
                lsdToInsert.add( new Lead_Score_Detail__c(
                    Contact__c = contactList[i].Id
                ));
            }
            LeadScoreDetailsDAO.newInstance().insertRecords(lsdToInsert, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            List<Contact> updatedContact = ContactsDAO.newInstance().getPersonContactsWithLimit(numberOfRecords);
            for(Contact contact: updatedContact){
                System.assert(contact.Lead_Score_Detail__c != null, 'No contact is updated');
            }
        }     
    }
}
