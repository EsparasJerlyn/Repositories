/**
 * @description Test class for EvaluationSectionCtrl
 *
 * @see EvaluationSectionCtrl
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                  |
      |---------------------------|-----------------------|----------------------|---------------------------------|
      | angelika.j.s.galang       | March 24, 2022        | DEPP-1502            | Created file                    | 
*/
@IsTest(SeeAllData = false)
private class EvaluationSectionCtrlTest {
    
    private static final String QUTEX = System.Label.QUTeX;
    private static User currentUser = TestDataFactory.createUserRecords(1, QUTEX).iterator().next();

    @IsTest
    private static void getEvaluationFields(){
        System.runAs(currentUser){
            Test.startTest();
            List<Offering_Evaluation_Setting__mdt> evaluationSettings = EvaluationSectionCtrl.getEvaluationFields();
            Test.stopTest();
            System.assert(!evaluationSettings.isEmpty(), 'Evaluation settings not retrieved as expected');
        }
    }
}
