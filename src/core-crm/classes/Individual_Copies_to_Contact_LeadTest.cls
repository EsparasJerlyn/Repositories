/**
 * @description Test Class for Individual Copies to Contact Lead
 *
 * @see ../flows/Individual_Copies_to_Contact_Lead
 *                      |                       |              |                                                           |
*/
@isTest
private class Individual_Copies_to_Contact_LeadTest {
   
    @testSetup static void setupMethod() {
        Test.startTest();
            TestDataFactoryUser.generateUserQUTMarketingCloud();
            
        Test.stopTest();
        
        insert(TestDataFactory.createTestContactRecords(1));
		insert(TestDataFactory.createTestLeadRecords(1));
        insert(TestDataFactory.createTestIndividualRecords(1));

        Lead lead = [SELECT Id, IndividualId FROM Lead];
        Contact contact = [SELECT Id, IndividualId FROM Contact LIMIT 1];
        Individual individual = [SELECT Id FROM Individual];
        
        lead.IndividualId = individual.Id;
        contact.IndividualId = individual.Id;
        
        update lead;
        update contact;
    } 

    @isTest
    private static void updateIndividualRecord(){
         System.runAs(TestDataFactoryUser.selectUserQUTMarketingCloud) {
            DateTime currentTime = System.now();

            Individual individual = [SELECT Id, HasOptedOutSolicit, Dont_Market_DateTime__c, Dont_Market_Reason__c FROM Individual];
            
            Test.startTest();

            individual.HasOptedOutSolicit = true;
            individual.Dont_Market_DateTime__c = currentTime;
            individual.Dont_Market_Reason__c = 'Dont_Market_Reason';
            update individual;
            
            Test.stopTest();

            Lead lead = [SELECT Id, IndividualId, Dont_Market__c, Dont_Market_DateTime__c, Dont_Market_Reason__c FROM Lead];
            Contact contact = [SELECT Id, IndividualId, Dont_Market__c, Dont_Market_DateTime__c, Dont_Market_Reason__c FROM Contact LIMIT 1];

            System.assertEquals(true, lead.Dont_Market__c, 'Dont_Market__c should be updated');
            System.assertEquals(currentTime, lead.Dont_Market_DateTime__c, 'Dont_Market_DateTime__c should be updated');
            System.assertEquals('Dont_Market_Reason', lead.Dont_Market_Reason__c, 'Dont_Market_Reason__c should be updated');
            System.assertEquals(true, contact.Dont_Market__c, 'Dont_Market__c should be updated');
            System.assertEquals(currentTime, contact.Dont_Market_DateTime__c, 'Dont_Market_DateTime__c should be updated');
            System.assertEquals('Dont_Market_Reason', contact.Dont_Market_Reason__c, 'Dont_Market_Reason__c should be updated');
         }
    }

}