/**
 * @description Test Class for Send Email Upon Idea Received Flow
 *
 * @see ../flows/Send_Email_Upon_Idea_Received
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | adrian.c.habasa           | Febuary 16, 2022      | DEPP-250     | Created file                                | 
      |                           |                       |              |                                             | 
*/
@IsTest(SeeAllData = false)
private with sharing class Send_Email_Upon_Idea_ReceivedTest {
    
    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    private static Id opeProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('OPE_Program_Specification').getRecordTypeId();

    @isTest
    private static void emailUponIdeaReceived(){
        System.runAs(currentUser){
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
            insert acc;

            List<Contact> conList = TestDataFactory.createTestContactRecords(5);
            for(Integer i =0;i<conList.size();i++){
                conList[i].Email = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert conList;

            List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(5,acc?.Id,conList.iterator().next()?.Id);
            insert oppList;

            List<Product_Specification__c> prodSpecList = TestDataFactory.createTestProductSpecsRecords(5,conList,oppList);
            for(Integer i =0;i<prodSpecList.size();i++){
                prodSpecList[i].RecordTypeId = opeProdSpecId;
                prodSpecList[i].Stage__c = 'Idea';
                prodSpecList[i].Status__c = 'Idea Sent';
                prodSpecList[i].Requestor_Name__c = conList[i].Id;
            }
            insert prodSpecList;

            Test.startTest();
            for(Product_Specification__c ps : prodSpecList){
                ps.Status__c = 'Idea Received';
            }
            update prodSpecList;
            Test.stopTest();
            
            System.assertEquals(0, Limits.getEmailInvocations(),'Number of email invocations not as expected');
        }
    }
}
