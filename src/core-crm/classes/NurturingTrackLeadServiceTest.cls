/**
 * @description Test class for NurturingTrackLeadService
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum       	       | July 25, 2023         | DEPP-6105              | Created file                 | 
 */
@isTest
public with sharing class NurturingTrackLeadServiceTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
        System.runAs(TestDataFactory.getProgramAdminUser()) {            
            List<Lead> newLeads = createTestLeadRecords(0, 3);    
            LeadsDAO.newInstance().insertRecords(newLeads, false, AccessLevel.SYSTEM_MODE);
            
            ApplicationsDAO.newInstance().insertRecords(
                createTestApplicationStudyLinkRecords(0, recordsCount,'New'),
                false,
                AccessLevel.SYSTEM_MODE
            );
            
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
            nurtureConfig.Cadence_Name__c = 'TEST 1';
            nurtureConfig.Lead_Score_Threshold__c = 3;
            nurtureConfig.Status__c = 'Active';
            nurtureList.add(nurtureConfig);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);       
        }
    }

    @isTest
    private static void testNurturingTrackLeadServiceMethod() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            
            Map<Id,Lead> leadToProcess = new Map<Id,Lead>();    
            List<Lead> leadList = [SELECT Id, Can_Nurture__c, Lead_Score__c, Calculated_Cadence__c FROM Lead LIMIT 1];
            for(Lead lead: leadList){
                leadToProcess.put(lead.Id,lead);
            }
            
            Test.startTest();       
            NurturingTrackLeadService.processLeadForEntryAndExit(leadToProcess);
            Test.stopTest();  
        }
    }
    
    private static List<hed__Application__c> createTestApplicationStudyLinkRecords(Integer startAtCount, Integer endBeforeCount, String applicationStatus) {
        List<hed__Application__c> newApplications = new List<hed__Application__c>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newApplications.add(
                new hed__Application__c(
                    FirstName__c = FIRSTNAME + i,
                    LastName__c = i + LASTNAME,
                    BirthDate__c = Date.valueOf(BIRTHDAY),
                    Email__c = 'work' + i + EMAIL,
                    Application_Status__c = applicationStatus,
                    RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID
                )
            );
        }
        return newApplications;
    }
    
    private static List<Lead> createTestLeadRecords(Integer startAtCount, Integer endBeforeCount) {
        List<Lead> newLeads = new List<Lead>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newLeads.add(
                new Lead(
                    FirstName = FIRSTNAME,
                    LastName = LASTNAME + i,
                    Email = i + EMAIL,
                    Can_Nurture__c = TRUE,
                    Calculated_Cadence__c = 'Test',
                    Work_Email__c = 'work' + i + EMAIL,
                    Company = 'Learner' + i
                )
            );
        }
        return newLeads;
    }

}