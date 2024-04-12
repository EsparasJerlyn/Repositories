/**
 * @description Test Class for Update Product Code Flow
 *
 * @see ../flows/Update Max Score for Parent Lead Scoring Configuration

 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | julie.jane.alegre         | August 29, 2023       | DEPP-6315    | Created file                                |
      |                           |                       |              |                                             |
      |                           |                       |              |                                             |
*/
@isTest
private class Lead_Score_Config_Max_Score_UpdateTest {

    private static final Id LEAD_SCORE_CONFIGURATION_REC_TYPE_CATEGORY = Schema.SObjectType.Lead_Score_Configuration__c.getRecordTypeInfosByName().get('Category').getRecordTypeId();
    private static final Id LEAD_SCORE_CONFIGURATION_REC_TYPE_CONFIGURATION = Schema.SObjectType.Lead_Score_Configuration__c.getRecordTypeInfosByName().get('Configuration').getRecordTypeId();
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_System_Administrator' });
    }
    @isTest
    static void updateMaxScoreOnParentConfigurationTest() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
            Test.startTest();
                Decimal totalMaxScore = 0;
                //Create Parent Record
                List<Lead_Score_Configuration__c> parentRecord = TestDataFactory.createLeadScoreConfigurationRecords(
                                                    null,
                                                    LEAD_SCORE_CONFIGURATION_REC_TYPE_CONFIGURATION,
                                                    1);
                insert parentRecord;
                //Create Child Record
                List<Lead_Score_Configuration__c> childRecord = TestDataFactory.createLeadScoreConfigurationRecords(
                                                    parentRecord[0].Id,
                                                    LEAD_SCORE_CONFIGURATION_REC_TYPE_CATEGORY,
                                                    100);
                insert childRecord;
                List<Lead_Score_Configuration__c> updatedParentRecord = [Select Id, Max_Score__c, RecordTypeId FROM Lead_Score_Configuration__c WHERE RecordTypeId =: LEAD_SCORE_CONFIGURATION_REC_TYPE_CONFIGURATION LIMIT 1];
                List<Lead_Score_Configuration__c> listOfChildRecords = [Select Id, Max_Score__c, RecordTypeId FROM Lead_Score_Configuration__c WHERE Parent_Category__c =: updatedParentRecord[0].Id LIMIT 100];
                for(Lead_Score_Configuration__c children: listOfChildRecords){
                    totalMaxScore += children.Max_Score__c;
                }
                Test.stopTest();
                
                System.assertEquals(totalMaxScore, updatedParentRecord[0].Max_Score__c, 'No data retrieved!');
        }
    }
}
