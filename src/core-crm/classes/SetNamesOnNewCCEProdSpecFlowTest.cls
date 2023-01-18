@isTest
private class SetNamesOnNewCCEProdSpecFlowTest {
    private static final Id ID_PRODSPEC_CCE = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
    private static final String PROGRAM_NAME = 'Test Program';
    @TestSetup
    static void setup(){
        TestDataFactory.generateTestUsers();
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
        System.runAs(TestDataFactory.getProgramAdminUser()){
            Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
            Product_Specification__c prs = new Product_Specification__c(
                RecordTypeId = ID_PRODSPEC_CCE,
                Opporunity_Name__c = oppId,
                Stage__c = 'Define'
            );
            Test.startTest();
            insert prs;
            Test.stopTest();
            Product_Specification__c prsPost = [
                SELECT Id, Program_Name__c, Product_Specification_Name__c 
                FROM Product_Specification__c WHERE Id = :prs.Id
            ];
            System.assert(
                prsPost.Program_Name__c == PROGRAM_NAME && 
                prsPost.Product_Specification_Name__c == PROGRAM_NAME, 
                'The Product Specification Name was not updated from an empty value.'
            );
        }
    }
}