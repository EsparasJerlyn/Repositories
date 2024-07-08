
/**
 * @description Qualtrics Survey object trigger handler test class
 * @see QualtricsSurveyTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eugene.andrew.abuan       | May 21, 2024          | DEPP-8822    | Created file                                |

*/

@isTest
private class QualtricsSurveyTriggerHandlerTest {

    @TestSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserStudentSuccessOutreachManager();
    }

    @isTest
    private static void checkInProgressSurveyURLPositive(){
        System.runAs(TestDataFactoryUser.selectUserStudentSuccessOutreachManager) {

            List<Qualtrics_Survey__c> qualtricsSurveyList = TestDataFactory.createQualtricsSurveyRecord(100);
            QualtricsSurveysDAO.newInstance().insertRecords(qualtricsSurveyList, false, AccessLevel.SYSTEM_MODE);

            for(Qualtrics_Survey__c qs : qualtricsSurveyList){
                qs.In_Progress_Survey_URL__c = 'Test URL';
            }

            Test.startTest();
            QualtricsSurveysDAO.newInstance().updateRecords(qualtricsSurveyList, false, AccessLevel.SYSTEM_MODE);

            Test.stopTest();
            for(Qualtrics_Survey__c qs : qualtricsSurveyList){
                System.assert(String.IsNotBlank(qs.In_Progress_Survey_URL__c), 'In Progress Survey URL should not be blank');
            }
        }
    }

    @isTest
    private static void checkInProgressSurveyURLNegative(){
        System.runAs(TestDataFactoryUser.selectUserStudentSuccessOutreachManager) {

            List<Qualtrics_Survey__c> qualtricsSurveyList = TestDataFactory.createQualtricsSurveyRecord(100);
            for(Qualtrics_Survey__c qs : qualtricsSurveyList){
                qs.In_Progress_Survey_URL__c = 'Initial URL';
            }
            QualtricsSurveysDAO.newInstance().insertRecords(qualtricsSurveyList, false, AccessLevel.SYSTEM_MODE);

            for(Qualtrics_Survey__c qs : qualtricsSurveyList){
                qs.In_Progress_Survey_URL__c = 'update URL';
            }

            Test.startTest();
            QualtricsSurveysDAO.newInstance().updateRecords(qualtricsSurveyList, false, AccessLevel.SYSTEM_MODE);

            Test.stopTest();
            for(Qualtrics_Survey__c qs : qualtricsSurveyList){
                System.assertEquals('update URL', qs.In_Progress_Survey_URL__c, 'In Progress Survey URL did not update');
            }
            
        }
    }
}