/**
 * @description Test Class to for OutreachCaseImportCtrlTest
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | julie.jane.alegre              | May 24, 2024          | DEPP-7526              | Created file                 |
 */
@isTest
private class OutreachCaseImportCtrlTest {

    @testSetup
    static void setup() {
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactoryUser.generateUserStudentSuccessOutreachManager();
    }


    @isTest
    static void testListOfCases() {
        System.runAs(TestDataFactoryUser.selectUserStudentSuccessOutreachManager) {
            //Create Engagement List Configuration record
            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            //Create Engagement List Criteria record
            List<Engagement_List_Criteria__c> criteriaList = new List<Engagement_List_Criteria__c>();
            Engagement_List_Criteria__c criteria = new Engagement_List_Criteria__c();
            criteria.Engagement_List_Configuration__c = configs[0].Id;
            criteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_IMPORTED;
            criteria.Engagement_List_Criteria_Title__c = 'Test Criteria';
            criteriaList.add(criteria);
            EngagementListCriteriasDAO.newInstance().insertRecords(criteriaList, true, AccessLevel.SYSTEM_MODE);

            //Create Contact record
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);

            //Create Case record
            Id studentRetentionId = GroupsDAO.newInstance().getQueueByName(GroupsDAO.STUDENT_RETENTION_QUEUE);
            List<Case> caseList = new List<Case>();
            Case outreachCase = TestDataFactory.createTestOutreachCaseRecord(configs[0], studentRetentionId, contactList[0].Id);
            caseList.add(outreachCase);
            CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.SYSTEM_MODE);

            Test.startTest();
            List<OutreachCaseImportCtrl.CaseWrapper> result = OutreachCaseImportCtrl.listOfCases(configs[0].Id);
            Test.stopTest();
            System.assert(result.size() > 0, 'No case records retrieved.');
            System.assertEquals(result[0].getCase().Id, outreachCase.Id, 'Case record retrieved did not match.');
        }
    }
    
    
    @IsTest
    static void testListOfStudents() {
        System.runAs(TestDataFactoryUser.selectUserStudentSuccessOutreachManager) {
            List<String> studentIds = new List<String>{ '12345678', '87654321','12354688' };

            Test.startTest();
            List<StudentIdValidator.ValidationResult> results = OutreachCaseImportCtrl.listOfStudents(studentIds);
            Test.stopTest();

            System.assertEquals(studentIds.size(), results.size(), 'Expected a validation result for each student ID');
            for (StudentIdValidator.ValidationResult result : results) {
                if(result.getResultCode() == 'INVALID'){
                    System.assert(result.getId() == null, 'Student does not exist.');
                }
            }
        
        } 
    }


    @IsTest
    static void testListOfCasesbyStudentIds() {

        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            String criteriaName = 'Test Criteria for Import';
            //Create Engagement List Configuration record
            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);
            
            //Create Contact records
            List<Contact> contactList = new List<Contact>();
            List<String> studentIds = new List<String>();
            for(Integer i = 1; i <= 5; i++){
                Contact contact =  new Contact();
                contact.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                contact.QUT_Student__c = true;
                contact.QUT_Student_ID__c = '000000' + i;
                contact.LastName = 'Test User ' + i;
                studentIds.add(contact.QUT_Student_ID__c);
                contactList.add(contact);
            }
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);
            OutreachCaseImportCtrl.listOfCasesByStudentIds(studentIds, criteriaName, configs[0].Id);
            Test.stopTest();
            List<Case> outreachCaseList =  CasesDAO.newInstance().getCasesByEngagementListConfigurationIds(configs[0].Id, AccessLevel.SYSTEM_MODE);
            System.assertEquals(contactList.size(), outreachCaseList.size(), 'All contact records should have an outreach case record.');
            
        }
    }

    @IsTest
    static void testListOfCasesById() {

        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            String criteriaName = 'Test Criteria for Import';
            //Create Engagement List Configuration record
            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);
            
            //Create Contact records
            List<Contact> contactList = new List<Contact>();
            List<String> studentIds = new List<String>();
            for(Integer i = 1; i <= 5; i++){
                Contact contact =  new Contact();
                contact.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                contact.QUT_Student__c = true;
                contact.QUT_Student_ID__c = '000000' + i;
                contact.LastName = 'Test User ' + i;
                studentIds.add(contact.QUT_Student_ID__c);
                contactList.add(contact);
            }
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);
            OutreachCaseImportCtrl.listOfCasesByStudentIds(studentIds, criteriaName, configs[0].Id);
            List<Case> outreachCaseList =  CasesDAO.newInstance().getCasesByEngagementListConfigurationIds(configs[0].Id, AccessLevel.SYSTEM_MODE);
            List<String> caseIds = new List<String>();
            for(Case caseRec: outreachCaseList){
                caseIds.add(caseRec.Id);
            }
            List<Case> caseListById = OutreachCaseImportCtrl.listOfCasesById(caseIds);
            Test.stopTest();
            System.assertEquals(caseIds.size(), caseListById.size(), 'Not all case records are retrieved.');
            
        }
    }
    
}