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
    private static Integer numberOfRecords = 50;

    @testSetup
    static void setupMethod(){  
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
        Test.stopTest();
            List<Account> accounts = TestDataFactory.createTestAccountRecords(numberOfRecords);     
            AccountsDAO.newInstance().insertRecords(accounts, false, AccessLevel.USER_MODE);     
            List<Lead> leads = TestDataFactory.createTestLeadRecords(numberOfRecords);
            for(Lead lead : leads){   
                lead.Company_Category__c = 'Corporate';
                lead.Description = 'Test Description';
                lead.Lead_Type__c = 'CCE Corporate Partner';
            }   
            LeadsDAO.newInstance().insertRecords(leads, false, AccessLevel.USER_MODE);
    }
    @isTest 
    private static void linkLeadScoreDetailToContactTest(){ 
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){ 
            List<Lead> leads = LeadsDAO.newInstance().getLeadsWithLimit(numberOfRecords);
            Test.startTest();
            convertLead(leads);
            Test.stopTest();
            List<Contact> updatedContact = ContactsDAO.newInstance().getPersonContactsWithLimit(numberOfRecords);
            for(Contact contact: updatedContact){
                System.assert(contact.Lead_Score_Detail__c != null, 'No contact is updated');
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
