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
      |                           |                       |          |                                 | 
*/
@IsTest(SeeAllData=false)
private class Lead_to_Opp_Conversion_std_MappingTest{
    
    private static final String STR_PROFILE = 'QUTeX';
    private static User  currentUser = TestDataFactory.createUserRecords(1, STR_PROFILE).iterator().next();
    private static String companyCategoryStr = 'Corporate';
    private static String descriptionStr = 'Test Description';
    private static String leadTypeStr = 'CCE Corporate Partner';
    private static Integer numberOfRecords = 100;
    
    @TestSetup
    static void setupMethod(){        
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
           
    @IsTest 
    private static void convertLeadToOppTest(){ 
        List<Lead> leads = [SELECT Id, Lead_Type__c FROM Lead LIMIT 100];
        
        System.runAs(currentUser){  
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
        List<Database.LeadConvertResult> ltc= Database.convertLead(leadstoConvert);  
    }
}