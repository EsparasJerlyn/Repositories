/**
 * @description Test Class for LeadService
 *
 * @see LeadService
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                               |
      |---------------------------|-----------------------|--------------|----------------------------------------------|
      | mark.j.mahilum            | June 13,2023          | DEPP-5798    | Created file                                 |
      | mark.j.mahilum            | July 28, 2023         | DEPP-6106    | Updated test class to cover can nurture logic|
*/
@isTest
private class LeadServiceTest {
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String COMPANY = 'Testcompany';
    private static final String LEAD_TYPE = 'Learner';
    private static Integer recordsCount = 5;

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });

        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            LeadsDAO.newInstance()
                .insertRecords(
                    createTestLeadRecords(0, recordsCount),
                    false,
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
        }
    }

    @isTest
    private static void testLeadBatchInsertLeadScoreBelowFifty() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .insertRecords(
                    createTestLeadRecords(recordsCount, recordsCount),
                    false,
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            
			Set<Id> leadIds = new Set<Id>();             
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');      
                if (sr.isSuccess()) { 
                    leadIds.add(sr.getId());
                }
            }
            
            for (Lead lead : [SELECT Id,Status FROM Lead WHERE Id IN :leadIds]) {  
                System.assertEquals('New', lead.Status,'Lead Status did not match');
            }
        }
    }
    
    @isTest
    private static void testLeadBatchUpdateLeadScoreAboveFifty() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            for (Integer i = 0; i < recordsCount; i++) {
                ldList[i].Email = 'new' + i + EMAIL;
                ldList[i].Work_Email__c = 'newwork' + i + EMAIL;
                ldList[i].Marketing_Interaction_Score__c  = 256.00;
            }

            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .updateRecords(ldList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
			
            Set<Id> leadIds = new Set<Id>();  
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
                if (sr.isSuccess()) { 
                    leadIds.add(sr.getId());
                }
            }
            
            for (Lead lead : [SELECT Id,Status FROM Lead WHERE Id IN :leadIds]) {  
                System.assertEquals('Engaging', lead.Status,'Lead Status did not match');
            }
        }
    }
    
    @isTest
    private static void testLeadBatchUpdateLeadScoreAboveOneHundred() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            for (Integer i = 0; i < recordsCount; i++) {
                ldList[i].Email = 'new' + i + EMAIL;
                ldList[i].Work_Email__c = 'newwork' + i + EMAIL;
                ldList[i].Marketing_Interaction_Score__c  = 300.00;
            }

            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .updateRecords(ldList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
			
            Set<Id> leadIds = new Set<Id>();  
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
                if (sr.isSuccess()) { 
                    leadIds.add(sr.getId());
                }
            }
            
            for (Lead lead : [SELECT Id,Status FROM Lead WHERE Id IN :leadIds]) {  
                System.assertEquals('Nurturing', lead.Status,'Lead Status did not match');
            }
        }
    }

    @isTest
    private static void testLeadBatchUpdateCanNurtureIsCheck() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Lead_Score_Threshold__c = 1;
            nurtureConfig.Status__c = 'Active';
            nurtureList.add(nurtureConfig);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);  
            
            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            for (Integer i = 0; i < recordsCount; i++) {
                ldList[i].Email = 'new' + i + EMAIL;
                ldList[i].Work_Email__c = 'newwork' + i + EMAIL;
                ldList[i].Marketing_Interaction_Score__c  = 300.00;
            }
            
            Test.startTest();
            Database.SaveResult[] srList = LeadsDAO.newInstance()
                .updateRecords(ldList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            Set<Id> leadIds = new Set<Id>();  
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not saved.');
                if (sr.isSuccess()) { 
                    leadIds.add(sr.getId());
                }
            }
            
            for (Lead lead : [SELECT Id,Can_Nurture__c FROM Lead WHERE Id IN :leadIds]) {  
                System.assert(lead.Can_Nurture__c,'Can Nurture is not ticked');
            }
        }
    }

    private static List<Lead> createTestLeadRecords(Integer startAtCount, Integer endBeforeCount) {
        List<Lead> newLeads = new List<Lead>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newLeads.add(
                new Lead(
                    LastName = LASTNAME + i,
                    Email = i + EMAIL,
                    Work_Email__c = 'work' + i + EMAIL,
                    Company = COMPANY + i,
                    Lead_Type__c = LEAD_TYPE
                )
            );
        }
        return newLeads;
    }
}