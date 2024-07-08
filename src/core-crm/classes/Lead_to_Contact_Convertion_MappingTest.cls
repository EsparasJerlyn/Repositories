/**
 * @description Tests Lead to Contact Convertion Mapping Flow
 *
 * @see Lead_to_Contact_Convertion_Mapping
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | eccarius.karl.munoz       | November 04, 2021     | DEPP-739 | Created file                    | 
      |                           |                       |          |                                 | 
*/
@isTest
private class Lead_to_Contact_Convertion_MappingTest{
    
    private static String companyCategoryStr = 'Corporate';
    private static String linkedInProfileUrlStr = 'test@test.com';
    private static Integer numberOfRecords = 100;
    
    @testSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();        
        List<Account> accounts = TestDataFactory.createTestAccountRecords(numberOfRecords);          
        List<Lead> leads = TestDataFactory.createTestLeadRecords(numberOfRecords);
        for(Lead lead : leads){   
            lead.Company_Category__c = companyCategoryStr;
            lead.LinkedIn_Profile_URL__c = linkedInProfileUrlStr;
        }        
        insert accounts;
        insert leads;
    }
           
    @isTest 
    private static void convertLeadToContactTest(){ 
        List<Lead> leads = [SELECT Id FROM Lead LIMIT 100];
        
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){  
            Test.startTest();  
            convertLead(leads);
            Test.stopTest();
            
            List<Contact> contacts = [SELECT Id, LinkedIn_Profile_URL__c FROM Contact LIMIT 100];           
            for(Contact contact : contacts){                
                System.assertEquals(linkedInProfileUrlStr, contact.LinkedIn_Profile_URL__c,'Not equal');
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
