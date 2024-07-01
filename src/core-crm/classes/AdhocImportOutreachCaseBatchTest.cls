/**
 * @description Test class for AdhocImportOutreachCaseBatch
 * @AdhocImportOutreachCaseBatch
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | julie.jane.alegre              | July 01, 2024         | DEPP-9499              | Created file                 |
 */
@isTest
public with sharing class AdhocImportOutreachCaseBatchTest {
    @TestSetup
    static void setupMethod(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserQUTESB){
            //Create Contact records
            List<Contact> contactList = new List<Contact>();
            for(Integer i = 1; i <= 5; i++){
                Contact contact =  new Contact();
                contact.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                contact.QUT_Student__c = true;
                contact.QUT_Student_ID__c = '000000' + i;
                contact.LastName = 'Test User ' + i;
                contactList.add(contact);
            }
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);

        }

    }
    @isTest
    static void batchExecutionTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB){
            //List of Contact studentIds
            List<String> studentIds = new List<String>{'0000001', '0000002', '0000003', '0000004','0000005'};

            //Create Engagement List Configuration record
            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'AdhocImportOutreachCaseBatch Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            //Create Engagement List Criteria record
            List<Engagement_List_Criteria__c> criteriaList = new List<Engagement_List_Criteria__c>();
            Engagement_List_Criteria__c criteria = new Engagement_List_Criteria__c();
            criteria.Engagement_List_Configuration__c = configs[0].Id;
            criteria.Status__c = 'Active';
            criteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_IMPORTED;
            criteria.Engagement_List_Criteria_Title__c = 'AdhocImportOutreach Criteria';
            criteriaList.add(criteria);
            EngagementListCriteriasDAO.newInstance().insertRecords(criteriaList, true, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Criteria__c> criterias = EngagementListCriteriasDAO.newInstance().findActiveEngagementListCriteriasByRecordtype(EngagementListCriteriasDAO.RECORD_TYPE_ID_IMPORTED, Date.today(), AccessLevel.SYSTEM_MODE);

            Test.startTest();
            AdhocImportOutreachCaseBatch batchable = new AdhocImportOutreachCaseBatch(studentIds, criterias[0], configs[0].Id);
            Database.executeBatch(batchable);    
            Test.stopTest();

            List<Case> outreachCaseList =  CasesDAO.newInstance().getCasesByEngagementListConfigurationIds(configs[0].Id, AccessLevel.SYSTEM_MODE);
            List<Engagement_List_Event__c> eventList = EngagementListEventsDAO.newInstance().getEngagmentListEventByCaseId(new Set<Id>{outreachCaseList[0].Id}, AccessLevel.SYSTEM_MODE);
            
            System.assertEquals(5, outreachCaseList.size(), 'No outreach cases created');
            System.assertEquals(outreachCaseList[0].Id, eventList[0].Case__c, 'No Engagement List Event created');
            
        }

    }
    
}
