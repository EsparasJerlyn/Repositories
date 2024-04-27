@isTest
private class SetNamesOnNewCCEProdSpecFlowTest {
    private static final Id ID_PRODSPEC_CCE = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
    private static final String PROGRAM_NAME = 'Test Program';
    @TestSetup
    static void setup(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Account acc = TestDataFactory.createTestAccount(true);
        Contact con = TestDataFactory.createTestContact(true, acc.Id);
        List<Opportunity> opps = TestDataFactory.createTestOpportunityRecords(1, acc.Id, con.Id);
        opps[1].Program_Name__c = PROGRAM_NAME;
        opps[1].StageName = 'Closed Won';
        opps[1].Status__c = 'Contract Signed';
        insert opps;
    }

    @isTest
    static void testSetName() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Product_Specification__c prsPost = TestDataFactory.retrieveCCEProductSpecifications();
            System.assert(
                prsPost.Program_Name__c == PROGRAM_NAME && 
                prsPost.Product_Specification_Name__c == PROGRAM_NAME, 
                'The Product Specification Name was not updated from an empty value.'
            );
            Test.stopTest();
        }
    }
}