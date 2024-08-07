/**
 * @description Test Class for LeadWithCaseHelper
 *
 * @see LeadWithCaseHelper
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | roy.nino.s.regala         | Oct 17, 2022          | DEPP-4220    | Created file                                |
*/
@isTest
private class LeadWithCaseHelperTest {
    
    @testSetup
    static void setupMethod(){     
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactory.loadEDATriggers();
        Test.stopTest(); 

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){ 
            List<Lead> leads = TestDataFactory.createTestLeadRecords(100);
            insert leads;
            List<Case> cases = TestDataFactory.createTestCaseRecords(100,leads,null);
            for(Case c : cases){
                c.Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC;
            }
            insert cases;
        }
        
    }
           
    @isTest 
    private static void convertLeadToContactTest(){ 
        List<Lead> leads = [SELECT Id FROM Lead LIMIT 100];
        
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){ 

            Test.startTest();  
            convertLead(leads);
            Test.stopTest();

            system.assert(![SELECT Id FROM Case WHERE ContactId != null].isEmpty(), 'New Contact is not related to Case');
            
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