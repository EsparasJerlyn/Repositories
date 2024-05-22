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
            
            //Create Engagement List Configuration record
            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test 01';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);
            System.debug('configs: ' + configs);

            //Create Engagement List Criteria
            List<Engagement_List_Criteria__c> engagementListCriteriaList = new List<Engagement_List_Criteria__c>();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            engagementListCriteria.Completed_Cadence__c = 'Domestic Accepted and Admitted';
            // engagementListCriteria.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            engagementListCriteria.Key_Date__c = 'Completed Cadence Date';
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = 1;
            engagementListCriteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA;
            engagementListCriteria.Engagement_List_Configuration__c = configs[0].Id;
            engagementListCriteria.Engagement_List_Criteria_Title__c = 'Engagement List Test Record 1';
            engagementListCriteria.Status__c = 'Active';
            engagementListCriteriaList.add(engagementListCriteria);
            EngagementListCriteriasDAO.newInstance().insertRecords(engagementListCriteriaList, true, AccessLevel.SYSTEM_MODE);
            System.debug('engagementListCriteriaList: ' + engagementListCriteriaList);
            
            //Create contact 
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL);          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);
            System.debug('contactList: ' + contactList);

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
            System.debug('completedCadenceList: ' + completedCadenceList);

            // //Create Program Enrollment records
            // List<hed__Program_Plan__c> programPlanListCreated = TestDataFactory.createTestProgramPlanRecords(1);
            // programPlanListCreated[0].Category_Type__c = 'Graduate Certificate';
            // ProgramPlansDAO.newInstance().insertRecords(programPlanListCreated,true,AccessLevel.SYSTEM_MODE);
    
            // List<hed__Program_Enrollment__c> programEnrollmentListCreated = TestDataFactory.createTestProgramEnrollmentRecords(1);
            // programEnrollmentListCreated[0].Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
            // programEnrollmentListCreated[0].Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
            // programEnrollmentListCreated[0].Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
            // programEnrollmentListCreated[0].hed__Contact__c = contactList[0].Id;
            // programEnrollmentListCreated[0].hed__Program_Plan__c = programPlanListCreated[0].Id;
            // ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentListCreated,true,AccessLevel.SYSTEM_MODE);

            Test.startTest();
            List<ELCEvaluationJob> evalJobList =  new List<ELCEvaluationJob>();
            ELCEvaluationJob eLCEvaluationJob =  new eLCEvaluationJob(engagementListCriteriaList[0], Date.today());
            evalJobList.add(eLCEvaluationJob);
            
            ELCEvaluatorBatch batchable = new ELCEvaluatorBatch(evalJobList);
            Database.executeBatch(batchable);    
            Test.stopTest();
            List<Case> caseList = CasesDAO.newInstance().getOpenOutreachCasesByConfigAndContactIds(new Set<Id>{contactList[0].Id}, configs[0].Id, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Event__c> eventList = EngagementListEventsDAO.newInstance().getEngagmentListEventByCaseId(caseList[0].Id, AccessLevel.SYSTEM_MODE);
            
            System.debug('caseList: ' + caseList);
            System.debug('eventList: ' + eventList);
            // System.assert(caseList.size() > 0, 'No record');
            // System.assertEquals(contactList[0].Id, caseList[0].ContactId, 'Outreach case should be created.');
            // System.assert(eventList.size() > 0, 'No record');
            // System.assertEquals(caseList[0].Id, eventList[0].Case__c, 'Outreach case should be created.');

        }
        
    }

}