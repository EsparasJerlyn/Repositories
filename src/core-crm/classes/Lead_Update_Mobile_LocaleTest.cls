/**
 * @description Tests the Lead_Update_Marketing_Mobile_Locale flow
 *
 * @see Lead_Update_Marketing_Mobile_Locale flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | roy.nino.s.regala         | May 31, 2022          | DEPP-2105| Created file                    | 
      |                           |                       |          |                                 |
*/
@isTest
private class Lead_Update_Mobile_LocaleTest {

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void updatePhoneNumbersTest(){

        List<Lead> leads = new List<Lead>();

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            leads = TestDataFactory.createTestLeadRecords(50);

            for(Lead l : leads){
                l.LeadMobile_Validation__c = 'None';
                l.LeadMobile_Locale__c = 'Australia (+61)';
                l.City = '';
            }

            insert leads;

        Test.startTest();
        List<lead> leadsToUpdate = new List<Lead>([Select Id FROM Lead LIMIT 50]);
        for(lead l: leadsToUpdate){
            l.LeadMobile_Validation__c = 'Valid';
        }
        update(leadsToUpdate);
        Test.stopTest();

        }
        system.assert(![SELECT Id FROM Lead Where Marketing_Mobile_Locale__c = 'en-AU'].isEmpty(), 'Lead mobile locale should be en-au');
    } 

}
