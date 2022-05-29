/**
 * @description Test Class for Lead Potential Duplicate Ctrl
 *
 * @see ../class/LeadPotentialDuplicateCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eccarius.munoz            | May 27, 2022          | DEPP-1778    | Created file                                |
      |                           |                       |              |                                             |
      |                           |                       |              |                                             |
*/
@IsTest(SeeAllData = false)
private class LeadPotentialDuplicateCtrlTest {
    private @TestSetup
    static void makeData(){
        List<Account> accounts = TestDataFactory.createTestAccountRecords(2);          
        List<Lead> leads = TestDataFactory.createTestLeadRecords(2);
        for(Lead lead : leads){   
            lead.Company_Category__c = 'Corporate';
            lead.LinkedIn_Profile_URL__c = 'test@test.com';
        }        
        insert accounts;
        insert leads;

        List<Contact> contacts = TestDataFactory.createTestContactRecords(1);        
        insert contacts;

        List<Potential_Duplicate__c> potentialDuplicates = new List<Potential_Duplicate__c>();
        potentialDuplicates.add(new Potential_Duplicate__c(Lead__c  = leads[0].Id, Duplicate_Lead__c = leads[1].Id));
        potentialDuplicates.add(new Potential_Duplicate__c(Duplicate_Lead__c = leads[0].Id, Contact__c = contacts[0].Id));
        insert potentialDuplicates;
    }

    @IsTest
    static void getSelectedLeadTest(){
        List<Lead> leads = [SELECT Id FROM Lead];
        Id recordId = leads[0].Id;
        Test.startTest();
        List<LeadPotentialDuplicateCtrl.LeadContactWrapper> leadList = LeadPotentialDuplicateCtrl.getSelectedLead(recordId);
        Test.stopTest();
        System.assertEquals(true, leadList.size()>0, 'No lead record retrieved.');
    }

    @IsTest
    static void getLeadPotentialDuplicateTest(){
        List<Lead> leads = [SELECT Id FROM Lead];
        Id recordId = leads[0].Id;
        Test.startTest();
        List<LeadPotentialDuplicateCtrl.LeadContactWrapper> leadList = LeadPotentialDuplicateCtrl.getLeadPotentialDuplicate(recordId);
        Test.stopTest();
        System.assertEquals(true, leadList.size() > 0, 'No dupllicate record(s) retrieved.');
    }

    @IsTest
    static void mergeLeadsTest(){
        List<Lead> leads = [SELECT Id FROM Lead];
        Id recordId = leads[0].Id;
        List<LeadPotentialDuplicateCtrl.LeadContactWrapper> leadList = LeadPotentialDuplicateCtrl.getLeadPotentialDuplicate(recordId);
        Test.startTest();
        String response = LeadPotentialDuplicateCtrl.mergeLeads(leadList);
        Test.stopTest();
        System.assertEquals('Success', response, 'Failed to save records.');
    }
}
