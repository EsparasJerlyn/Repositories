/**
* @description Test Class for Flow To Update Ein Recom Chk Value
*
* @see ../flows/Flow_To_Update_Ein_Recom_Chk_Value
*
* @author Accenture
*
* @history
*  | Developer                 | Date                  | JIRA         | Change Summary                         |
|---------------------------|-----------------------|--------------|---------------------------------------------|
| moiz.syed@qut.edu.au      | May 31, 2024          | DEPP-8870    | Created file                                |
| moiz.syed@qut.edu.au      | June 10, 2024         | DEPP-8870    | removed debug statements                    |
| moiz.syed@qut.edu.au      | June 19, 2024         | DEPP-8870    | changed the case record type                |
*/
@isTest
public with sharing class Flow_To_Update_Ein_Recom_Chk_ValueTest {
    @testSetup
    static void makeData(){
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_International_Future_Student_Agent', 'QUT_Domestic_Future_Student_Agent' });
        List<Case> internationalCases = TestDataFactory.createTestCaseRecords(CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID, 'Test International Case', 100);
        for(Case c : internationalCases){
            c.Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL;
        }
        CasesDAO.newInstance().insertRecords(internationalCases, false, AccessLevel.SYSTEM_MODE);
        List<Case> caseList = [Select Id, Subject, Description From Case WHERE RecordTypeId=:CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID Limit 100];
        Id internationalFutureStudentAgentId = TestDataFactory.getInternationalFutureStudentAgent().Id;

        List<CaseShare> caseShareList = new List<CaseShare>();
        for(Case c : caseList){
            CaseShare caseShare = new CaseShare();
            caseShare.caseId = c.Id;
            caseShare.UserOrGroupId = InternationalFutureStudentAgentId;
            caseShare.CaseAccessLevel = 'Edit'; // 'Read' Or 'Edit' depending on the access level required
            caseShare.RowCause = Schema.CaseShare.RowCause.Manual;
            caseShareList.add(caseShare);
        }
        insert caseShareList;
    }

    @isTest
    static void UpdateEinsteinAppliedOtherUserChangesTest() {
        System.runAs(TestDataFactory.getInternationalFutureStudentAgent()) {
            List<Case> casList = [Select Id, Subject, Description From Case Limit 100];
            for(Case cas : casList){
                cas.Category__c = 'Applying for a course';
                cas.Sub_Category__c = 'How to apply';
            }
            Test.startTest();
            update casList;
            Test.stopTest();
            // Assert Statement
            Case updatedCase = [SELECT Category__c, Sub_Category__c FROM Case WHERE Id = :casList[0].Id];
            System.assertEquals('Applying for a course', updatedCase.Category__c,'Case Category Changed');
            System.assertEquals('How to apply', updatedCase.Sub_Category__c,'Case Sub Category Changed');
        }
    }

    @isTest
    static void UpdateEinsteinAppliedAutomatedUserChangesTest() {
        User us = [SELECT Id,Name FROM User where Name = 'Automated Process'];
        System.runAs(us) {
            List<Case> casList = [Select Id, Subject, Description From Case WHERE RecordTypeId=:CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID Limit 100];
            for(Case cas : casList){
                cas.Category__c = 'Applying for a course';
                cas.Sub_Category__c = 'How to apply';
            }
            Test.startTest();
            update casList;
            Test.stopTest();

            // Assert Statement
            Case updatedCase = [SELECT Category__c, Sub_Category__c FROM Case WHERE Id = :casList[0].Id];
            System.assertEquals('Applying for a course', updatedCase.Category__c,'Case Category Changed');
            System.assertEquals('How to apply', updatedCase.Sub_Category__c,'Case Sub Category Changed');
        }
    }
}