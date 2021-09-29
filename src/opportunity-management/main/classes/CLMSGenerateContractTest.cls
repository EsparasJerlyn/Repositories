/**
 * @description Tests the CLMS Generate Contract class 
 *
 * @see CLMSGenerateContract
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | angelika.j.s.galang       | September 14, 2021    | DEP1-22      | Created file                                | 
      |                           |                       |              |                                             | 
*/
@IsTest(SeeAllData = false)
private class CLMSGenerateContractTest {

    private static final String STR_QUTeX = 'QUTeX';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTeX).iterator().next();

    @testSetup static void setupMethod() {
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        insert acc;

        Contact con = TestDataFactory.createTestContactRecords(1).iterator().next();
        insert con;

        List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(100,acc?.Id,con?.Id);

        Test.startTest();
        insert(oppList);
        Test.stopTest();
    }   

    @IsTest
    private static void generateContractTest(){
        Test.startTest();
        System.runAs(currentUser){
            List<Opportunity> oppList = new List<Opportunity>([Select Id From Opportunity LIMIT 100]);
            List<CLMSGenerateContract.ContractRequest> contractRequestList = new List<CLMSGenerateContract.ContractRequest>();

            for(Opportunity opp : oppList){
                CLMSGenerateContract.ContractRequest contractReq = new CLMSGenerateContract.ContractRequest();
                contractReq.Opportunity_Id = opp.Id;
                contractRequestList.add(contractReq);
            }

            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            List<CLMSGenerateContract.ContractResponse> contractResponseList = CLMSGenerateContract.generateContract(contractRequestList);

            for(CLMSGenerateContract.ContractResponse contractRes : contractResponseList){
                System.assertEquals('OK', contractRes.status, 'Status doesnt match');
                System.assertEquals('1234', contractRes.CLMS_Agreement_Id, 'Contract Id doesnt match');
                System.assertEquals('5678', contractRes.CLMS_Agreement_URL, 'Contract URL doesnt match');
            }
            
        }
        Test.stopTest();
    }

}
