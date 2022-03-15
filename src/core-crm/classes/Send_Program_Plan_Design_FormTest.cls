/**
 * @description Test Class for Send Program Plan Design  Flow
 *
 * @see ../flows/Send_Program_Plan_Design
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | adrian.c.habasa           | January 21, 2022      | DEPP-1463    | Created file                                |
      |                           |                       |              |                                             | 
      |                           |                       |              |                                             | 
*/
@IsTest(SeeAllData = false)
private class Send_Program_Plan_Design_FormTest {
    private static string PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static string PP_PROGRAM = System.Label.RT_ProgramPlan_Program;
    private static string PS_PROGRAM_SPEC = System.Label.RT_ProductSpecification_OPEProgramSpecification;

    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    private static Id opeProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get(PS_PROGRAM_SPEC).getRecordTypeId();
    private static Id opeProgProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static Id opeProgPlanId = Schema.SObjectType.hed__Program_Plan__c.getRecordTypeInfosByDeveloperName().get(PP_PROGRAM).getRecordTypeId();
  
    @isTest
    private static void emailProgramDesignCompletionTest()
    {
        System.runAs(currentUser)
        {
            Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test@mailinator.com');
            insert customEmail;
            List<Account> acc = TestDataFactory.createTestAccountRecords(1);
            insert acc;

            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            for(Integer i = 0 ; i < conList.size() ; i++){
                conList[i].Email = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert conList;

            List<Credential__c> credList = TestDataFactory.createTestCredentialRecords(1);
            insert credList;
            
            List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(1,acc[0].Id,conList.iterator().next()?.Id);
            insert oppList;

            List<Product_Specification__c> prodSpecList = TestDataFactory.createTestProductSpecsRecords(1,conList,oppList);
            for(Integer i = 0 ; i < prodSpecList.size() ; i++){
                prodSpecList[i].RecordTypeId = opeProdSpecId;
                prodSpecList[i].Stage__c = 'Idea';
                prodSpecList[i].Status__c = 'Idea Sent';
                prodSpecList[i].Requestor_Name__c = conList[i].Id;
            }
            insert prodSpecList;

            List<Product_Request__c> pr = TestDataFactory.createTestProductRequestRecords(1);
            for(Integer i = 0 ; i < pr.size() ; i++){
            pr[i].RecordTypeId = opeProgProdReqId;
            }
            insert pr;

            List<hed__Program_Plan__c> progPlan = TestDataFactory.createTestProgramPlanRecords(100);
            
            Date startDate = date.today().addDays(1);
            Date endDate = startDate.addDays(1);

            for(Integer i=0; i<progPlan.size(); i++)
            {
                progPlan[i].RecordTypeId = opeProgPlanId;
                progPlan[i].Overview__c = 'Test Overview';
                progPlan[i].Owning_Faculty__c = acc[0].Id;
                progPlan[i].Product_Request__c = pr[0].Id;
                progPlan[i].Accreditation_End_Date__c= Date.newInstance(2022, 01, 06);
                progPlan[i].Accreditation_Start_Date__c = Date.newInstance(2022, 01, 06);
                progPlan[i].hed__Start_Date__c = startDate;
                progPlan[i].hed__End_Date__c = endDate;
                progPlan[i].Name='Test Program Plan';
                progPlan[i].hed__Description__c = 'Test Description';
                progPlan[i].Who_Should_Participate__c = 'Test Participate';
                progPlan[i].Core_Concepts__c = 'Test Concept';
                progPlan[i].hed__Total_Required_Credits__c = 1.1;
                progPlan[i].Field_of_Education__c = 'Test Field';
                progPlan[i].Blue_Card_Required__c = true;
                progPlan[i].More_Details__c = 'Test Details';
                progPlan[i].Code__c ='123';
                progPlan[i].Program_Type__c= 'Prescribed Program';
                progPlan[i].PP_Is_curriculum_approved__c = true;
                progPlan[i].Courseloop_Full_URL__c = 'CourseLoop.com';
                progPlan[i].Credential__c=credList[0].Id;
                progPlan[i].PP_Design_Form_Status__c = 'Design Form Sent';
            }
            insert progPlan; 

            List<hed__Program_Plan__c> getProgPlan = new List<hed__Program_Plan__c>();
            List<hed__Program_Plan__c> progPlanRec = [SELECT id, PP_Design_Form_Status__c FROM hed__Program_Plan__c LIMIT 100];
            Test.startTest();
            for(hed__Program_Plan__c updateProgplan : progPlanRec){
                updateProgplan.PP_Design_Form_Status__c = 'Design Form Received';
                getProgPlan.add(updateProgplan);
            }
            update getProgPlan;
            Test.stopTest();
            
            System.assertEquals(0, Limits.getEmailInvocations(),'Number of email invocations not as expected');
        }
    }
}