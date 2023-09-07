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
      | julie.jane.alegre         | Sept 07, 2023         | DEPP-5965    | Add test method testCreateLeadScoreDetail    |
*/
@isTest
private class LeadServiceTest {
    private static Integer recordsCount = 5;
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String COMPANY = 'Testcompany';
    private static final String LEAD_TYPE = 'Learner';

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator','QUT_Domestic_Future_Student_Agent' });

        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            LeadsDAO.newInstance()
                .insertRecords(
                    TestDataFactory.createTestLeadRecords(0, recordsCount),
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
                    TestDataFactory.createTestLeadRecords(recordsCount, recordsCount),
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
            
            for (Lead lead : LeadsDAO.newInstance().getLeadsWithLimit(recordsCount)) {  
                System.assertEquals('New', lead.Status,'Lead Status did not match');
                System.assert(String.isBlank(lead.Future_Student_Journey_Status__c),'Lead Future_Student_Journey_Status__c did not match');
            }
        }
    }
    
    @isTest
    private static void testLeadBatchUpdateLeadScoreAboveFifty() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Lead_Score_Detail__c lcd = new Lead_Score_Detail__c();
            lcd.Total_Lead_Score__c = 70;
            insert lcd;

            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            for (Integer i = 0; i < recordsCount; i++) {
                ldList[i].Email = 'new' + i + EMAIL;
                ldList[i].Work_Email__c = 'newwork' + i + EMAIL;
                ldList[i].Lead_Score_Detail__c = lcd.Id;
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
            
            for (Lead lead : LeadsDAO.newInstance().getLeadsWithLimit(recordsCount)) {  
                System.assertEquals('Engaging', lead.Status,'Lead Status did not match');
                System.assertEquals('Explore', lead.Future_Student_Journey_Status__c,'Lead Future_Student_Journey_Status__c did not match');
            }
        }
    }
    
    @isTest
    private static void testLeadBatchUpdateLeadScoreAboveOneHundred() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Lead_Score_Detail__c lcd = new Lead_Score_Detail__c();
            lcd.Total_Lead_Score__c = 300;
            insert lcd;

            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            for (Integer i = 0; i < recordsCount; i++) {
                ldList[i].Email = 'new' + i + EMAIL;
                ldList[i].Work_Email__c = 'newwork' + i + EMAIL;
                ldList[i].Lead_Score_Detail__c = lcd.Id;
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
            
            for (Lead lead :LeadsDAO.newInstance().getLeadsWithLimit(recordsCount)) {  
                System.assertEquals('Nurturing', lead.Status,'Lead Status did not match');
                System.assertEquals('Explore', lead.Future_Student_Journey_Status__c,'Lead Future_Student_Journey_Status__c did not match');
            }
        }
    }

    @isTest
    private static void testLeadBatchUpdateCanNurtureIsCheck() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {

            Lead_Score_Detail__c lcd = new Lead_Score_Detail__c();
            lcd.Total_Lead_Score__c = 300;
            insert lcd;
            
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
                ldList[i].Lead_Score_Detail__c = lcd.Id;
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
            
            for (Lead lead :LeadsDAO.newInstance().getLeadsWithLimit(recordsCount)) {  
                System.assert(lead.Can_Nurture__c,'Can Nurture is not ticked');
            }
        }
    }

    @isTest
    private static void testGetLeadCalculatedCadence() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            
            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            for (Integer i = 0; i < recordsCount; i++) {
                ldList[i].Email = 'new' + i + EMAIL;
                ldList[i].Work_Email__c = 'newwork' + i + EMAIL;
                ldList[i].Calculated_Cadence__c = 'Test Cadences automated';
            }
            Test.startTest();
            LeadsDAO.newInstance().updateRecords(ldList, false, AccessLevel.SYSTEM_MODE);                
            Test.stopTest();
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'SalesCadenceCalloutService'].isEmpty() , 'SalesCadenceCalloutService Queueable Job was not executed');
        }
    }    
    @isTest
    private static void testCreateLeadScoreDetail() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Account> accounts = TestDataFactory.createTestAccountRecords(recordsCount);     
            AccountsDAO.newInstance().insertRecords(accounts, false, AccessLevel.USER_MODE);     
            List<Lead> leads = TestDataFactory.createTestLeadRecords(recordsCount);
            for(Lead lead : leads){   
                lead.Company_Category__c = 'Corporate';
                lead.Description = 'Test Description';
                lead.Lead_Type__c = 'CCE Corporate Partner';
            }   
            LeadsDAO.newInstance().insertRecords(leads, false, AccessLevel.USER_MODE);
            Test.startTest();
            convertLead(leads);
            Test.stopTest();
            List<Lead_Score_Detail__c> lsdList = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailWithLimit(recordsCount);
            System.assert(lsdList.size() > 0, 'No record created');

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