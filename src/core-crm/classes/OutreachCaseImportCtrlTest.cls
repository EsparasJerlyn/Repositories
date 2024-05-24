/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class OutreachCaseImportCtrlTest {

    @testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
    }


    @isTest
    static void testListOfCases() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
        List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
        Engagement_List_Configuration__c config = new Engagement_List_Configuration__c(Name = 'Test Outreach Config');
        configs.add(config);
        insert configs;

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        contactList[0].QUT_Student__c = true;
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);

        Id ownerId = GroupsDAO.newInstance().getQueueByName(GroupsDAO.STUDENT_RETENTION_QUEUE);
        Case outreachCase = TestDataFactory.createTestOutreachCaseRecord(configs[0], ownerId, contactList[0].Id);
        List<Case> caseList = new List<Case>();
        caseList.add(outreachCase);
        CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.SYSTEM_MODE);

        List<Case> result = new List<Case>();
        Test.startTest();
            result = OutreachCaseImportCtrl.listOfCases(config.Id.toString());
        Test.stopTest();

        System.assert(result.size()>0, 'List of Cases should not be null');
        System.assertEquals(CasesDAO.OUTREACH_RECTYPE_ID, result[0].RecordTypeId, 'Case RecordTypeId does not match');
        
        }
    }
    
    
    @IsTest
    static void testListOfStudents() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
        List<String> studentIds = new List<String>{ '12345678', '87654321' };

        Test.startTest();

        List<StudentIdValidator.ValidationResult> results = OutreachCaseImportCtrl.listOfStudents(studentIds);

        Test.stopTest();

        System.assertEquals(studentIds.size(), results.size(), 'Expected a validation result for each student ID');

        for (StudentIdValidator.ValidationResult result : results) {
            
            System.assert(result.getResultCode() == 'INVALID', 'Expected the Student ID to be invalid: ' + result.getStudentId());
        }
    }
    }


    @IsTest
    static void testListOfCasesbyStudentIds() {
        List<Contact> contactList = TestDataFactory.createTestContactRecords(4);
        for (Contact con : contactList) {
            con.QUT_Student_Id__c = 'SID' + con.Id;
        }
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);
    
        List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
        configs.add(new Engagement_List_Configuration__c(Name = 'Test Outreach Config'));
        EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);
    
        String criteria = 'Test Title,Test Description';
        Id configId = configs[0].Id;
    
        Case testOutreachCase = new Case(
            ContactId = contactList[0].Id, 
            RecordTypeId = CasesDAO.OUTREACH_RECTYPE_ID,
            Status = 'Validated'
        );
        insert testOutreachCase;
    
        Engagement_List_Criteria__c criteriaRecord = new Engagement_List_Criteria__c();
        criteriaRecord.Engagement_List_Configuration__c = configId;
        criteriaRecord.Engagement_List_Criteria_Title__c = criteria.split(',')[0];
        criteriaRecord.Description__c = criteria.split(',')[1];
        criteriaRecord.RecordTypeId = Schema.SObjectType.Engagement_List_Criteria__c.getRecordTypeInfosByName().get('Imported').getRecordTypeId();
        insert criteriaRecord;
    
        Test.startTest();
    
        List<OutreachCaseImportCtrl.OutreachCases> result = OutreachCaseImportCtrl.listOfCasesbyStudentIds(
            new List<String>{contactList[0].QUT_Student_Id__c},
            criteria,
            configId
        );
    
        Test.stopTest();
    
        System.assertEquals(1, result.size(), 'Expected one OutreachCase result');
    
        OutreachCaseImportCtrl.OutreachCases oc = result[0];
        System.debug(oc);
    
        System.assertEquals(testOutreachCase.Id, oc.getCase().Id, 'Expected Case ID to match');
        System.assertEquals('Validated', oc.getProcessResultCode(), 'Expected Validation Result to be Validated');
    }
    
}