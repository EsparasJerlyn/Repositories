@isTest
private class NullifyLMSIntegrationStatusFlowTest {
    private static final Id ID_RT_PRS_OPE = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('OPE').getRecordTypeId();
    private static final Id ID_RT_ACC_BO = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();
    @TestSetup
    static void setup(){
        TestDataFactory.generateTestUsers();
    }

    @isTest
    static void nullLMSIntegration() {
        System.runAs(TestDataFactory.getProgramAdminUser()){
            Account acc = new Account(
                RecordTypeId = ID_RT_ACC_BO,
                Name = 'Tester Account',
                Organization_Unit_Level__c = '2'
            );
            insert acc;
            Contact con = TestDataFactory.createTestContact(true, acc.Id);
            Product_Specification__c prs = new Product_Specification__c(
                RecordTypeId = ID_RT_PRS_OPE,
                Requestor_Name__c = con.Id,
                Status__c = 'Design',
                Stage__c = 'Design',
                Existing_Product__c = 'No',
                Financial_Viability__c = 'No',
                Market_Need__c = 'No',
                QUTeX_Capacity__c = 'No',
                QUT_Faculty_Capacity__c = 'No',
                Supporting_Comments__c = 'You are amazing.',
                Product_Type__c = 'Program;Module;Short Course;Activity',
                Requires_Director_Endorsement__c = 'Not Required'
            );
            insert prs;
            Product_Request__c prr = new Product_Request__c(
                Product_Request_Name__c = 'Test Product',
                Product_Request_Status__c = 'Define',
                Product_Specification__c = prs.Id
            );
            insert prr;
            List<hed__Course__c> crss = TestDataFactory.createTestCourseRecords(
                1,
                acc.Id,
                prr.Id
            );
            insert crss;
            List<hed__Term__c> trms = TestDataFactory.createTestTermRecords(
                1,
                acc.Id
            );
            insert trms;
            List<hed__Course_Offering__c> ofrs = TestDataFactory.createTestCourseOfferingRecord(
                1,
                crss,
                trms
            );
            insert ofrs;
            Test.startTest();
            ofrs[0].hed__Start_Date__c += 2;
            update ofrs;
            Test.stopTest();
            Id ofrId = ofrs[0].Id;
            hed__Course_Offering__c ofrPost = [SELECT Id, LMS_Integration_Status__c FROM hed__Course_Offering__c WHERE Id = :ofrId LIMIT 1];
            System.assert(ofrPost.LMS_Integration_Status__c == null, 'LMS_Integration_Status was not cleared.');
        }
    }
}