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
|                           |                       |              |                                             |
*/
@isTest
public with sharing class Flow_To_Update_Ein_Recom_Chk_ValueTest {
    @testSetup
    static void makeData(){
        List<User> usr= TestDataFactory.generateTestUsers(new List<String>{ 'QUT_International_Future_Student_Agent', 'QUT_Domestic_Future_Student_Agent' });
        System.debug('usr' +usr );
        List<Case> internationalCases = TestDataFactory.createTestCaseRecords(CasesDAO.INTERNATIONALFS_RECTYPE_ID, 'Test International Case', 100);
        System.debug('internationalCases' +internationalCases );
        CasesDAO.newInstance().insertRecords(internationalCases, false, AccessLevel.SYSTEM_MODE);  
        
    }
    
    @isTest
    static void UpdateEinsteinAppliedOtherUserChangesTest() {
        System.runAs(TestDataFactory.getInternationalFutureStudentAgent()) {   
            Case cas = [Select Id, Subject, Description From Case Limit 1];
            System.debug('Case : '+ cas);
            cas.Category__c = 'Applying for a course';
            cas.Sub_Category__c = 'How to apply';
            Test.startTest();
            update cas;
            Test.stopTest();
            // Assert Statement
            Case updatedCase = [SELECT Category__c, Sub_Category__c FROM Case WHERE Id = :cas.Id];
            System.assertEquals('Applying for a course', updatedCase.Category__c,'Case Category Changed');
            System.assertEquals('How to apply', updatedCase.Sub_Category__c,'Case Sub Category Changed');
        }
    }
    
        @isTest
    static void UpdateEinsteinAppliedAutomatedUserChangesTest() {
         User us = [SELECT Id,Name FROM User where Name = 'Automated Process'];
        System.runAs(us) {   
            Case cas = [Select Id, Subject, Description From Case Limit 1];
            System.debug('Case : '+ cas);
            cas.Category__c = 'Applying for a course';
            cas.Sub_Category__c = 'How to apply';
            Test.startTest();
            update cas;
            Test.stopTest();
            // Assert Statement
            Case updatedCase = [SELECT Category__c, Sub_Category__c FROM Case WHERE Id = :cas.Id];
            System.assertEquals('Applying for a course', updatedCase.Category__c,'Case Category Changed');
            System.assertEquals('How to apply', updatedCase.Sub_Category__c,'Case Sub Category Changed');
        }
    }
}