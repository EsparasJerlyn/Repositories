/**
 * @description Test Class for Inbound Enquiry Case Set Case Type Flow
 *
 * @see ../flows/Inbound_Enquiry_Case_Set_Case_Type
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eccarius.munoz            | April 22, 2024        | DEPP-8542    | Created file                                |
      |                           |                       |              |                                             |
*/
@isTest
public with sharing class InboundEnquiryCaseSetCaseType_FlowTest {
    
    @testSetup
    static void makeData(){
        TestDataFactoryUser.generateUserFutureStudentAgentInternational();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
    }
    
    @IsTest
    static void domesticCaseTypeTest(){
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            
            List<Group> groupList = [SELECT Id, Name FROM Group WHERE  Type = 'Queue' and Name = 'Future Student Domestic Queue'];
            List<Case> domesticCases = TestDataFactory.createTestCaseRecords(CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID, 'Test Domestic Case', 1);           
            List<Case> caseList = new List<Case>();
            caseList.addAll(domesticCases);
            
            for(Case c : caseList){
                c.Origin = 'Email';
                c.Priority = 'Low';
                c.Category__c = 'Student life';
                c.Status = 'Created';
                c.SuppliedEmail = 'test333111CaseRec@mailinator.com';
                c.OwnerId = groupList[0].Id;
            }

            Test.startTest();
            CasesDAO.newInstance().insertRecords(caseList, false, AccessLevel.SYSTEM_MODE);  
            Test.stopTest();

            List<Case> caseListWithCaseType = CasesDAO.newInstance().getCasesByIds(new Set<Id>{caseList[0].Id}, AccessLevel.SYSTEM_MODE);
            System.assertEquals(CasesDAO.CASE_TYPE_DOMESTIC, caseListWithCaseType[0].Case_Type__c,'Case Type must be Domestic Future Student Enquiry.');
        }
    }

    @IsTest
    static void internationalCaseTypeTest(){
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentInternational) {
            
            List<Group> groupList = [SELECT Id, Name FROM Group WHERE  Type = 'Queue' and Name = 'Future Student International Queue'];
            List<Case> internationalCases = TestDataFactory.createTestCaseRecords(CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID, 'Test International Case', 1);           
            List<Case> caseList = new List<Case>();
            caseList.addAll(internationalCases);
            
            for(Case c : caseList){
                c.Origin = 'Email';
                c.Priority = 'Low';
                c.Category__c = 'Student life';
                c.Status = 'Created';
                c.SuppliedEmail = 'test333111CaseRec@mailinator.com';
                c.OwnerId = groupList[0].Id;
            }

            Test.startTest();
            CasesDAO.newInstance().insertRecords(caseList, false, AccessLevel.SYSTEM_MODE);  
            Test.stopTest();
            
            List<Case> caseListWithCaseType = CasesDAO.newInstance().getCasesByIds(new Set<Id>{caseList[0].Id}, AccessLevel.SYSTEM_MODE);
            System.assertEquals(CasesDAO.CASE_TYPE_INTERNATIONAL, caseListWithCaseType[0].Case_Type__c,'Case Type must be International Future Student Enquiry.');
        }
    }
}