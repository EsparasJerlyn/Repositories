/**
 * @description Tests Lead to Opportunity Conversion Mapping Flow
 *
 * @see Lead_to_Opp_Conversion_standard_Mapping
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | eccarius.karl.munoz       | November 05, 2021     | DEPP-740 | Created file                    | 
      | rhea.b.torres             | June 05, 2023         |          | Fix All Test Class pipeline     |
      |                           |                       |          | error to run as proper persona  |
      |                           |                       |          |                                 | 
*/
@isTest
private class Lead_to_Opp_Conversion_std_MappingTest{
    
    private static String companyCategoryStr = 'Corporate';
    private static String descriptionStr = 'Test Description';
    private static String leadTypeStr = 'CCE Corporate Partner';
    private static Integer numberOfRecords = 100;
    
    @testSetup
    static void setupMethod(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Account> accounts = TestDataFactory.createTestAccountRecords(numberOfRecords);          
            List<Lead> leads = TestDataFactory.createTestLeadRecords(numberOfRecords);
            for(Lead lead : leads){   
                lead.Company_Category__c = companyCategoryStr;
                lead.Description = descriptionStr;
                lead.Lead_Type__c = leadTypeStr;
            }        
            insert accounts;    
            insert leads;
        }
    }
           
    @isTest 
    private static void convertLeadToOppTest(){ 
        
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) { 
            List<Lead> leads = [SELECT Id, Lead_Type__c FROM Lead LIMIT 100];
            Test.startTest();  
            convertLead(leads);
            Test.stopTest();

            List<Opportunity> opportunities = [SELECT Id, Description, Type FROM Opportunity WHERE StageName = 'Qualify'];
            System.assertEquals(numberOfRecords, opportunities.size(), 'All converted leads to opps must have Qualify StageName');
            for(Opportunity opportunity : opportunities){
                System.assertEquals(descriptionStr, opportunity.Description, 'Opportunity Description must be the same from Lead Description.');
                System.assertEquals(leadTypeStr, opportunity.Type, 'Opportunity Type must be the same from Lead Type.');
            }               
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