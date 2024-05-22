/**
 * @description Test class for ELCEvaluatorTest
 * @ELCEvaluator
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | julie.jane.alegre              | May 14, 2024          | DEPP-8490              | Created file                 |
 */
@isTest
public with sharing class ELCEvaluatorBatchTest {

    @TestSetup
    static void setupMethod(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Student_Success_Outreach_Manager', 'QUT_ESB' });
    }
    
    @isTest
    static void testBatchExecutionTest() {                 
        //Contact with Completed Cadence
        System.runAs(TestDataFactory.getESBIntegrationUser()) {  
            
            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Criteria__c> criteriaList = new List<Engagement_List_Criteria__c>();
            Engagement_List_Criteria__c criteria = new Engagement_List_Criteria__c();
            criteria.Engagement_List_Configuration__c = configs[0].Id;
            criteria.Status__c = 'Active';
            criteria.Completed_Cadence__c = 'Domestic Accepted and Admitted';
            criteria.Key_Date__c = 'Completed Cadence Date';
            criteria.Key_Date_Offset_Lower_Boundary__c = 1;
            criteria.Start_Date__c = Date.today().addDays(-1);
            criteria.End_Date__c = Date.today().addDays(1);
            criteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
            criteria.Engagement_List_Criteria_Title__c = 'Test Criteria';
            criteriaList.add(criteria);
            EngagementListCriteriasDAO.newInstance().insertRecords(criteriaList, true, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Criteria__c> criterias = EngagementListCriteriasDAO.newInstance().findActiveEntryCriteria(EngagementListCriteriasDAO.RECORD_TYPE_DEVELOPER_NAME_ENTRY_CRITERIA, Date.today(), AccessLevel.SYSTEM_MODE);

            //Create contact 
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);

            //Create Completed Cadence records
            List<Nurture_Track_Configuration__c> initialNurtureList = TestDataFactory.createNurtureTrackConfigRecords(1);
            List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
            for(Nurture_Track_Configuration__c nurtureTrackConfig : initialNurtureList){
                nurtureList.add(
                    new Nurture_Track_Configuration__c(
                        Id = nurtureTrackConfig.Id,
                        Cadence_Name__c = 'Domestic Accepted and Admitted',
                        Lead_Score_Threshold__c = 3
                    )
                );
            }
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, true, AccessLevel.SYSTEM_MODE);    

            List<Completed_Cadence__c> completedCadenceList = TestDataFactory.createCompletedCadence('Successful',nurtureList[0].Id,new Set<Id>{contactList[0].Id});
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList,true,AccessLevel.SYSTEM_MODE);

            Test.startTest();

            List<ELCEvaluationJob> evalJobList =  new List<ELCEvaluationJob>();
            evalJobList.add(
                new eLCEvaluationJob(
                    criterias[0], 
                    Date.today()
                )
            );
            
            ELCEvaluatorBatch batchable = new ELCEvaluatorBatch(evalJobList);
            Database.executeBatch(batchable);    

            Test.stopTest();

            List<Case> outreachCases = CasesDAO.newInstance().getOpenOutreachCasesByConfigAndContactIds(new Set<Id>{contactList[0].Id}, configs[0].Id, AccessLevel.SYSTEM_MODE);
            
            System.assertEquals(1, outreachCases.size(), 'No outreach case created.');
           
        }
    }

}