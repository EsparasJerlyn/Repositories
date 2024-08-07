/**
 * @description Test Class for Case Email International Ack  Flow
 *
 * @see ../flows/Case_Email_International_Ack
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eccarius.munoz            | March 19, 2024        | DEPP-8297    | Created file                                |
      |                           |                       |              |                                             |
*/
@isTest
public with sharing class CaseEmailInternationalAck_FlowTest {
    private static final String STR_EMAIL_TEMPLATE = 'Test Email Template';
    
    @testSetup
    static void makeData(){
        TestDataFactoryUser.generateUserFutureStudentAgentInternational();
    }
    
    @IsTest
    static void caseOriginWebsiteInternationalCaseTest(){
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentInternational) {
            EmailTemplate template = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String,String>{
                STR_EMAIL_TEMPLATE => 'FS International Email Template Test'
            }).iterator().next();
            insert template;
            
            List<Case> internationalCases = TestDataFactory.createTestCaseRecords(CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID, 'Test International Case', 1);           
            List<Case> caseList = new List<Case>();
            caseList.addAll(internationalCases);
            
            for(Case c : caseList){
                c.Origin = 'Website';
                c.Priority = 'Low';
                c.Category__c = 'Student life';
                c.Status = 'Created';
                c.SuppliedEmail = 'test333111CaseRec@mailinator.com';
                c.Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL;
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