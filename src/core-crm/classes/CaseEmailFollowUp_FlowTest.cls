/**
 * @description Test Class for Case Email Follow Up Flow
 *
 * @see ../flows/Case_Email_Follow_Up_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | February 26, 2024     | DEPP-7866    | Created file                                |
      |                           |                       |              |                                             |
*/
@isTest
public with sharing class CaseEmailFollowUp_FlowTest {
    private static final String STR_EMAIL_TEMPLATE = 'Test Email Template';
    
    @testSetup
    static void makeData(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_International_Future_Student_Agent', 'QUT_Domestic_Future_Student_Agent' });
    }
    
    @IsTest
    static void caseOriginEmailInternationalCaseTest(){
        System.runAs(TestDataFactory.getInternationalFutureStudentAgent()) {
            EmailTemplate template = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String,String>{
                STR_EMAIL_TEMPLATE => 'FS International Email Template Test'
            }).iterator().next();
            insert template;
            
            List<Case> internationalCases = TestDataFactory.createTestCaseRecords(CasesDAO.INTERNATIONALFS_RECTYPE_ID, 'Test International Case', 1);           
            List<Case> caseList = new List<Case>();
            caseList.addAll(internationalCases);
            
            for(Case c : caseList){
                c.Origin = 'Email';
                c.Priority = 'Low';
                c.Category__c = 'Student life';
                c.Status = 'Created';
                c.SuppliedEmail = 'test333111CaseRec@mailinator.com';
            }
            
            CasesDAO.newInstance().insertRecords(caseList, false, AccessLevel.SYSTEM_MODE);    
            
            FlowEmailMergeField mergeFields = new FlowEmailMergeField();
            mergeFields.mergeField = '{{{Case.SuppliedMail}}}';
            mergeFields.mergeFieldValue = caseList[0].SuppliedEmail;
            
            CaseEmailFlowHelper.EmailParameters emailParams = new CaseEmailFlowHelper.EmailParameters();
            emailParams.recipientEmailAddresses= new List<String>{'test@test.com.invalid'};
            emailParams.emailTemplateDeveloperName = template.DeveloperName;
            emailParams.mergeFields = new List<FlowEmailMergeField>{mergeFields};
            emailParams.emailSubject = '';
            emailParams.orgWideEmailAddressId = '';
            emailParams.recordId = caseList[0].Id;

            Test.startTest();
            CaseEmailFlowHelper.sendCustomEmail(new List<CaseEmailFlowHelper.EmailParameters>{emailParams});
            Test.stopTest();

            System.assertEquals(0, Limits.getEmailInvocations(),'Number of email invocations not as expected');
        }
    }
    
    @IsTest
    static void caseOriginWebsiteInternationalCaseTest(){
        System.runAs(TestDataFactory.getInternationalFutureStudentAgent()) {
            EmailTemplate template = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String,String>{
                STR_EMAIL_TEMPLATE => 'FS International Email Template Test'
            }).iterator().next();
            insert template;
            
            List<Case> internationalCases = TestDataFactory.createTestCaseRecords(CasesDAO.INTERNATIONALFS_RECTYPE_ID, 'Test International Case', 1);           
            List<Case> caseList = new List<Case>();
            caseList.addAll(internationalCases);
            
            for(Case c : caseList){
                c.Origin = 'Website';
                c.Priority = 'Low';
                c.Category__c = 'Student life';
                c.Status = 'Created';
                c.SuppliedEmail = 'test333111CaseRec@mailinator.com';
            }
            
            CasesDAO.newInstance().insertRecords(caseList, false, AccessLevel.SYSTEM_MODE);    
            
            FlowEmailMergeField mergeFields = new FlowEmailMergeField();
            mergeFields.mergeField = '{{{Case.SuppliedMail}}}';
            mergeFields.mergeFieldValue = caseList[0].SuppliedEmail;
            
            CaseEmailFlowHelper.EmailParameters emailParams = new CaseEmailFlowHelper.EmailParameters();
            emailParams.recipientEmailAddresses= new List<String>{'test@test.com.invalid'};
            emailParams.emailTemplateDeveloperName = template.DeveloperName;
            emailParams.mergeFields = new List<FlowEmailMergeField>{mergeFields};
            emailParams.emailSubject = '';
            emailParams.orgWideEmailAddressId = '';
            emailParams.recordId = caseList[0].Id;

            Test.startTest();
            CaseEmailFlowHelper.sendCustomEmail(new List<CaseEmailFlowHelper.EmailParameters>{emailParams});
            System.assertEquals(1, Limits.getEmailInvocations(),'Number of email invocations not as expected');
            Test.stopTest();

        }
    }

}