/**
 * @description Test Class for OPE Design Completion Flow
 *
 * @see ../flows/OPE_Design_Complete_Prog_Plan_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eccarius.munoz            | January 24, 2022      | DEPP-1477    | Created File                                |
      |                           |                       |              |                                             |
*/
@isTest
private class OPE_Design_Complete_Prog_Plan_FlowTest{

    private static Id opeProgramReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Program').getRecordTypeId();
    private static Id opeProgramPlanReqId = Schema.SObjectType.hed__Program_Plan__c.getRecordTypeInfosByDeveloperName().get('Program').getRecordTypeId();
    private static Integer numberOfRecords = 100;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void updateOPEProgramTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Integer numberOfCompleted = 0;

            createProgramPlan(opeProgramReqId);

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            Test.startTest();

            List<Product_Request__c> productRequests = [SELECT Id FROM Product_Request__c LIMIT 100];

            Date startDate = date.today().addDays(1);
            Date endDate = startDate.addDays(1);

            List<hed__Program_Plan__c> programPlansToUpdate = [SELECT Id, OPE_Design_Complete__c  FROM hed__Program_Plan__c LIMIT 100];
            for(Integer i = 0 ; i < programPlansToUpdate.size() ; i++){
                programPlansToUpdate[i].Name = 'test' + i;
                programPlansToUpdate[i].RecordTypeId = opeProgramPlanReqId;
                programPlansToUpdate[i].Product_Request__c  = productRequests[i].Id;
                programPlansToUpdate[i].Code__c = 'test' + i;
                programPlansToUpdate[i].Program_Type__c  = 'Award Course';
                programPlansToUpdate[i].Owning_Faculty__c  = accounts[0].Id;
                programPlansToUpdate[i].hed__Start_Date__c  = startDate;
                programPlansToUpdate[i].hed__End_Date__c  = endDate;
                programPlansToUpdate[i].Overviewv2__c  = 'test' + i;
                programPlansToUpdate[i].Core_Conceptsv2__c  = 'test' + i;
                programPlansToUpdate[i].Courseloop_Full_URL__c  = 'test' + i;
                programPlansToUpdate[i].PP_Is_curriculum_approved__c  = true;
            }
            update programPlansToUpdate;

            List<hed__Program_Plan__c> programPlans = [SELECT Id, OPE_Design_Complete__c  FROM hed__Program_Plan__c LIMIT 100];

            for(hed__Program_Plan__c programPlan : programPlans){
                if(programPlan.OPE_Design_Complete__c == true){
                    numberOfCompleted++;
                }
            }

            Test.stopTest();

            System.assertEquals(numberOfRecords, numberOfCompleted,'Required fields must be completed.');
        }
    }

    @isTest
    private static void updateIncompleteOPEProgramTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Integer numberOfCompleted = 0;

            createProgramPlan(opeProgramReqId);

            Test.startTest();

            List<Product_Request__c> productRequests = [SELECT Id FROM Product_Request__c LIMIT 100];

            List<hed__Program_Plan__c> programPlansToUpdate = [SELECT Id, OPE_Design_Complete__c  FROM hed__Program_Plan__c LIMIT 100];
            for(Integer i = 0 ; i < programPlansToUpdate.size() ; i++){
                programPlansToUpdate[i].Name = 'test' + i;
                programPlansToUpdate[i].RecordTypeId = opeProgramPlanReqId;
                programPlansToUpdate[i].Product_Request__c  = productRequests[i].Id;
                programPlansToUpdate[i].Code__c = 'test' + i;
            }
            update programPlansToUpdate;

            List<hed__Program_Plan__c> programPlans = [SELECT Id, OPE_Design_Complete__c  FROM hed__Program_Plan__c LIMIT 100];

            for(hed__Program_Plan__c programPlan : programPlans){
                if(programPlan.OPE_Design_Complete__c == true){
                    numberOfCompleted++;
                }
            }

            Test.stopTest();

            System.assertEquals(0, numberOfCompleted,'Program Plan OPE Design Complete field should not be completed.');
        }
    }

    private static void createProgramPlan(String productRequestRecordType){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(numberOfRecords);
            for(Product_Request__c productRequest : productRequests){
                productRequest.RecordTypeId = productRequestRecordType;
            }
            insert productRequests;

            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(numberOfRecords);
            insert programPlans;
        }
    }
}