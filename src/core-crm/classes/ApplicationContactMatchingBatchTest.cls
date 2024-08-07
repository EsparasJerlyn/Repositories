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
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
    }
    
    @isTest
    private static void testApplicationBatchInsertNoMatchContact() {
        
        ImplementationSelector.DAO.setMock(new ConMatchingServiceConfigurationsDAOMock());
        String developerName = ConMatchingServiceConfigurationsDAO.APPLICATION_BATCH;
        Contact_Matching_Service_Configuration__mdt customMetaData = (Contact_Matching_Service_Configuration__mdt) JSON.deserialize(
            '{"IsActive__c":"true","Size__c":"200","DeveloperName":"' + developerName + '"}',
            Contact_Matching_Service_Configuration__mdt.class
        );
        ConMatchingServiceConfigurationsDAO.newInstance()
            .insertRecords(
                new List<Contact_Matching_Service_Configuration__mdt>{ customMetaData },
                true,
                AccessLevel.SYSTEM_MODE
            );

        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
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