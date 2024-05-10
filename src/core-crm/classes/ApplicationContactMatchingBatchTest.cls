/**
 * @description Test Class for ApplicationContactMatchingBatch.
 *  
 * @see ApplicationContactMatchingBatch
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | May 06,2024           | DEPP-7989    | Created File                                |
*/
@isTest
private class ApplicationContactMatchingBatchTest {
    
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
        Test.stopTest();
    }
    
    @isTest
    private static void testApplicationBatchInsertNoMatchContact() {
        System.runAs(TestDataFactory.getESBIntegrationUser()) {
            Test.startTest();
            Database.SaveResult[] srList = ApplicationsDAO.newInstance()
                .insertRecords(
                    TestDataFactory.createTestApplicationStudyLinkRecords(recordsCount, recordsCount * 2,'Existing'),
                    false,
                    AccessLevel.SYSTEM_MODE
                );
            Test.stopTest();
            
            //check if application are associated with contact
            System.assertEquals(
                [select id from hed__Application__c where hed__applicant__c !=null].size(),
                srList.size(),
                'Contact created is not match'
            );
            
            //check if the application are all processed
            System.assertEquals(
                [select id from hed__Application__c where Batch_Process__c = 'Processed'].size(),
                srList.size(),
                'Contact created is not match'
            );
        }
    }
}