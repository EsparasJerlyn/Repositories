/**
 * @description Test Class for LeadWithLeadScoreDetails
 *
 * @see LeadWithLeadScoreDetails
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | julie.jane.alegre         | Septembere 04, 2023   | DEPP-5965    | Created file                                |
*/
@isTest
private class LeadWithLeadScoreDetailsTest {
    @testSetup
    static void setupMethod(){     
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator'});
        System.runAs(TestDataFactory.getProgramAdminUser()){ 
            List<Lead> leads = TestDataFactory.createTestLeadRecords(100);
            insert leads;
        }
    }
    
    @isTest 
    private static void createLeadScoreDetailToContactTest(){ 
        List<Lead> leads = [SELECT Id FROM Lead LIMIT 100];
        System.runAs(TestDataFactory.getProgramAdminUser()){ 
            Test.startTest();  
            convertLead(leads);
            Test.stopTest();
            List<Lead_Score_Detail__c> listOfNewLeadScore = [SELECT Id, Contact__c FROM Lead_Score_Detail__c WHERE Contact__c != null LIMIT 100];
            List<Contact> contactList = [SELECT Id FROM Contact WHERE Lead_Score_Detail__c != null LIMIT 100];
            System.assert(listOfNewLeadScore.size() > 0, 'No lead score detail is created.');
            System.assert(contactList.size() > 0, 'No contacts record is updated');
        }     
    }

    private static void convertLead(List<Lead> leads){
        List<Database.LeadConvert> leadstoConvert = new List<Database.LeadConvert>(); 
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        for(Lead lead : leads) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.id);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            leadstoConvert.add(lc);
        }
        Database.convertLead(leadstoConvert);  
    }
}
