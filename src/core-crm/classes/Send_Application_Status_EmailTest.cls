/**
 * @description Test Class for Send Application Status Email flow
 *
 * @see ../flows/Send_Application_Status_Email
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | arsenio.jr.dayrit         | February 14, 2022     | DEPP-1538    | Created file                                | 
      |                           |                       |              |                                             | 
*/
@IsTest(SeeAllData = false)
private class Send_Application_Status_EmailTest {

    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    
    @IsTest
    private static void sendApprovedApplicationStatusEmailTest(){
        System.runAs(currentUser){
            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            for(Integer i =0;i<conList.size();i++){
                conList[i].Email = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert conList;
            List<Account> acc = TestDataFactory.createTestAccountRecords(1);
            insert acc;
            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
            List<hed__Course__c> course = TestDataFactory.createTestCourseRecords(10,acc[0].Id,prodRequest[0].Id);
            insert course;
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10, acc[0].Id);
            insert terms;
            List<hed__Course_Offering__c> courseOff = TestDataFactory.createTestCourseOfferingRecord(10, course, terms);
            insert courseOff;

            
            List<Questionnaire_Response_Summary__c> qRs = TestDataFactory.createTestQuestionnaireResponseSummaryRecords(10,courseOff,conList[0]);
            for(Integer i = 0 ; i < qRs.size() ; i++){
                qRs[i].Application_Status__c = 'Pending';
                qRs[i].Course_Offering__c = courseOff[0].Id;
            }
            insert qRs;

            Test.startTest();
            List<Questionnaire_Response_Summary__c> qRsUpdateRec = new List<Questionnaire_Response_Summary__c>();
            List<Questionnaire_Response_Summary__c> getQrS = [SELECT Id, Name, Application_Status__c FROM Questionnaire_Response_Summary__c LIMIT 100];
            for(Questionnaire_Response_Summary__c updateQrs : getQrS){
                updateQrs.Application_Status__c = 'Approved';
                qRsUpdateRec.add(updateQrs);
            }

            update qRsUpdateRec;
            Test.stopTest();

            System.assertEquals(0, Limits.getEmailInvocations(),'Number of email invocations not as expected');
          
        
        }
    }

    @IsTest
    private static void sendRejectedApplicationStatusEmailTest(){
        System.runAs(currentUser){
            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            for(Integer i =0;i<conList.size();i++){
                conList[i].Email = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert conList;
            List<Account> acc = TestDataFactory.createTestAccountRecords(1);
            insert acc;
            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
            List<hed__Course__c> course = TestDataFactory.createTestCourseRecords(10,acc[0].Id,prodRequest[0].Id);
            insert course;
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10, acc[0].Id);
            insert terms;
            List<hed__Course_Offering__c> courseOff = TestDataFactory.createTestCourseOfferingRecord(10, course, terms);
            insert courseOff;

            
            List<Questionnaire_Response_Summary__c> qRs = TestDataFactory.createTestQuestionnaireResponseSummaryRecords(10,courseOff,conList[0]);
            for(Integer i = 0 ; i < qRs.size() ; i++){
                qRs[i].Application_Status__c = 'Pending';
                qRs[i].Course_Offering__c = courseOff[0].Id;
            }
            insert qRs;

            Test.startTest();
            List<Questionnaire_Response_Summary__c> qRsUpdateRec = new List<Questionnaire_Response_Summary__c>();
            List<Questionnaire_Response_Summary__c> getQrS = [SELECT Id, Name, Application_Status__c FROM Questionnaire_Response_Summary__c LIMIT 100];
            for(Questionnaire_Response_Summary__c updateQrs : getQrS){
                updateQrs.Application_Status__c = 'Rejected';
                updateQrs.Reason_for_Rejection__c = 'test';
                qRsUpdateRec.add(updateQrs);
            }

            update qRsUpdateRec;
            Test.stopTest();

            System.assertEquals(0, Limits.getEmailInvocations(),'Number of email invocations not as expected');
          
        
        }
    }


    
}
