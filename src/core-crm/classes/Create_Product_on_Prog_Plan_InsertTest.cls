/**
 * @description Test Class for Create Product on Program Plan Insert flow
 *
 * @see ../flows/Create_Product_on_Program_Plan_Insert
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | angelika.j.s.galang       | January 28, 2022      | DEPP-1407    | Created file                                | 
      |                           |                       |              |                                             | 
*/
@isTest
private class Create_Product_on_Prog_Plan_InsertTest {
    private static final String PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static Id opeProgramRequest = Schema.SObjectType.hed__Program_Plan__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }
    
    @isTest
    private static void createProductOnProgramPlanInsertTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            hed__Program_Plan__c programPlan = TestDataFactory.createTestProgramPlanRecords(1).iterator().next();
            programPlan.RecordTypeId = opeProgramRequest;
            
            Test.startTest();
            insert programPlan;
            Test.stopTest();
            
            Product2 product = [SELECT Name, Program_Plan__c, Family, IsActive FROM Product2 LIMIT 1];
            System.assertEquals(programPlan.Name, product.Name, 'Name did not match expected: '+programPlan.Name);
            System.assertEquals(programPlan.Id, product.Program_Plan__c, 'Program Plan ID did not match expected: '+programPlan.Id);
            System.assertEquals('Education', product.Family, 'Family did not match expected: Education');
            System.assertEquals(true, product.IsActive, 'IsActive did not match expected: true');
        }
    }
}