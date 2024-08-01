/**
* @description Test Class for Flow To Auto Populate DescriptionSummary Field of Case Object with short summary of Description.
*
* @see ../flows/Flow_To_Pop_DescSummary_Fld
*
* @author Accenture
*
* @history
*  | Developer                 | Date               | JIRA         | Change Summary                         |
|---------------------------|-----------------------|--------------|---------------------------------------------|
| moiz.syed@qut.edu.au      | June 25, 2024          | DEPP-9371    | Created file                                |
|
*/
@isTest
public with sharing class Flow_To_Pop_DescSummary_FldTest {
    private static final Integer NO_OF_RECORDS = 1;
    private static final String DESCRIPTION = 'This Case is Raised To Know What are the different courses offered by the university';
    
    @testSetup
    static void setup() {
        TestDataFactoryUser.generateUserFutureStudentAgentInternational();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
    }

    @isTest
    static void futureStudentAgentInternationalCreatesCase() {
        // Add toggle to endable
        AI_Settings__c aiSettings = AI_Settings__c.getOrgDefaults();
        if(aiSettings.Id==null){
            AI_Settings__c insertAISettings = new AI_Settings__c(LLM_Requests_Active__c = true, SetupOwnerId = UserInfo.getOrganizationId());
            insert insertAISettings;
        }else{
            aiSettings.LLM_Requests_Active__c = true;
            update aiSettings;
        }
 
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentInternational) {
            List<Case> internationalCases = TestDataFactory.createTestCaseRecords(CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID, 'Test International Case', NO_OF_RECORDS);
            for(Case c : internationalCases){
                c.Description = DESCRIPTION;
                c.Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL;
            }
            Test.startTest();
            CasesDAO.newInstance().insertRecords(internationalCases, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            // Assert Statement
            List<Case> createdCase = [SELECT Id, Description, Description_Summary__c FROM Case where Id =:internationalCases[0].Id];
            System.assertEquals('This Case is Raised To Know What are the different courses offered by the university', createdCase[0].Description,'Case Description');
            System.assertNotEquals(null, createdCase[0].Description_Summary__c,'Description_Summary__c should not be null');
        }
    }
    
    @isTest
    static void futureStudentAgentDomesticCreatesCaseUpdateCase() {
        // Add toggle to endable
        AI_Settings__c aiSettings = AI_Settings__c.getOrgDefaults();
        if(aiSettings.Id==null){
            AI_Settings__c insertAISettings = new AI_Settings__c(LLM_Requests_Active__c = true, SetupOwnerId = UserInfo.getOrganizationId());
            insert insertAISettings;
        }else{
            aiSettings.LLM_Requests_Active__c = true;
            update aiSettings;
        }

        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Case> internationalCases = TestDataFactory.createTestCaseRecords(CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID, 'Test International Case', NO_OF_RECORDS);
            for(Case c : internationalCases){
                c.Description = DESCRIPTION;
                c.Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL;
            }            
            CasesDAO.newInstance().insertRecords(internationalCases, false, AccessLevel.SYSTEM_MODE);
            
            List<Case> casList = [Select Id, Subject, Description, Description_Summary__c  From Case Where ID IN :internationalCases];
            for(Case cas : casList){
                cas.Description = DESCRIPTION + ' Please Let me Know Timing of the course';
            }
            Test.startTest();
            update casList;
            Test.stopTest();
            // Assert Statement
            Case updatedCase = [SELECT Id, Description , Description_Summary__c FROM Case WHERE Id = :casList[0].Id];
            System.assertEquals('This Case is Raised To Know What are the different courses offered by the university Please Let me Know Timing of the course', updatedCase.Description,'Case Description Updated');
            System.assertNotEquals(null, updatedCase.Description_Summary__c,'Description_Summary__c should not be null');
        }
    }    
}