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
@isTest
private class EvaluationSectionCtrlTest {
    
    private static final String QUTEX = System.Label.QUTeX;
    private static User currentUser = TestDataFactory.createUserRecords(1, QUTEX).iterator().next();

    @testSetup static void setupMethod() {
        Product_Request__c productRequest = TestDataFactory.createTestProductRequestRecords(1).iterator().next();
        insert productRequest;

        hed__Program_Plan__c programPlan = TestDataFactory.createTestProgramPlanRecords(1).iterator().next();
        programPlan.Product_Request__c = productRequest?.Id;
        insert programPlan;

        Program_Offering__c programOffering = TestDataFactory.createTestProgramOfferingRecords(
            1,new List<hed__Program_Plan__c>{programPlan}
        ).iterator().next();
        insert programOffering;
    } 

    @isTest
    private static void getEvaluationFieldsTest(){
        System.runAs(currentUser){
            Test.startTest();
            List<Offering_Evaluation_Setting__mdt> evaluationSettings = EvaluationSectionCtrl.getEvaluationFields();
            Test.stopTest();
            System.assert(!evaluationSettings.isEmpty(), 'Evaluation settings not retrieved as expected');
        }
    }

    @isTest
    private static void getRelatedProgramOfferingsTest(){
        System.runAs(currentUser){
            Id productRequestId = [SELECT Id FROM Product_Request__c LIMIT 1]?.Id;
            Id programOfferingId = [SELECT Id FROM Program_Offering__c LIMIT 1]?.Id;
            Test.startTest();
            List<Map<String,Object>> programOfferings = EvaluationSectionCtrl.getRelatedProgramOfferings(productRequestId);
            Test.stopTest();
            System.assertEquals(
                programOfferingId,
                (Id) programOfferings.iterator().next().get('value'), 
                'Expected program offering ID did not match'
            );
        }
    }
}
