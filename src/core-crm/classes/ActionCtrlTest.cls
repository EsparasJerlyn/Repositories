/**
 * @description Tests Controller Class for ActionCtrl
 * @see ActionCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.karl.munoz            | July 12, 2022         | DEPP-2035              | Created file                 | 
      |                                |                       |                        |                              | 
 */
@isTest
public with sharing class ActionCtrlTest {
    private static final string PR_EDUC_CONS = System.Label.RT_ProductRequest_Educ_Consultancy;
    private static final Id PR_EDUC_CONS_ID =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_EDUC_CONS).getRecordTypeId();

    private static final string RT_ACTION_ACT = System.Label.RT_Action_Activity;
    private static final Id RT_ACTION_ACT_ID =  Schema.SObjectType.Action__c.getRecordTypeInfosByDeveloperName().get(RT_ACTION_ACT).getRecordTypeId();

    private static final string RT_ACTION_INV = System.Label.RT_Action_Investigation;
    private static final Id RT_ACTION_INV_ID =  Schema.SObjectType.Action__c.getRecordTypeInfosByDeveloperName().get(RT_ACTION_INV).getRecordTypeId();

    private static final Integer NUM_RECORDS = 100;

    @testSetup
    static void makeData(){
        TestDataFactory.generateTestUsers();
    }

    @isTest
    static void getActionDetailsTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()){
            makeData(RT_ACTION_ACT_ID);

            Id prodReqId;
            List<Product_Request__c> productRequests = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 1];
            for(Product_Request__c productRequest : productRequests){
                prodReqId = productRequest.Id;
            }
            List<Action__c> actions = new List<Action__c>();
            Test.startTest();
            actions = ActionCtrl.getActionDetails(prodReqId);
            Test.stopTest();
            
            System.assert(actions.size() > 0, 'No Actions Retrieved');
        }
    }

    @isTest
    static void getInvestigationActionDetailsTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()){
            makeData(RT_ACTION_INV_ID);

            Id prodReqId;
            List<Product_Request__c> productRequests = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 1];
            for(Product_Request__c productRequest : productRequests){
                prodReqId = productRequest.Id;
            }
            List<Action__c> actions = new List<Action__c>();
            Test.startTest();
            actions = ActionCtrl.getInvestigationActionDetails(prodReqId);
            Test.stopTest();
            
            System.assert(actions.size() > 0, 'No Actions Retrieved');
        }
    }

    @isTest
    static void getActivitySectionDetailsTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()){
            makeData(RT_ACTION_ACT_ID);

            Id prodReqId;
            List<Product_Request__c> productRequests = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 1];
            for(Product_Request__c productRequest : productRequests){
                prodReqId = productRequest.Id;
            }
            ActionCtrl.ActivitySectionDetails response = new ActionCtrl.ActivitySectionDetails();
            Test.startTest();
            response = ActionCtrl.getActivitySectionDetails(prodReqId);
            Test.stopTest();
            System.assert(response.Id != null , 'No Consultancies Retrieved');
        }
    }

    @isTest
    static void getRelatedFilesByRecordIdTest(){
        System.runAs(TestDataFactory.getProgramAdminUser()){
            makeData(RT_ACTION_ACT_ID);
            List<Consultancy__c> consultancyList = [SELECT ID FROM Consultancy__c LIMIT 1];
            Test.startTest();
            Map<ID, String> response = ActionCtrl.getRelatedFilesByRecordId(consultancyList[0].Id);
            Test.stopTest();
            System.assert(response.isEmpty() || response == null , 'No files uploaded');
        }
    }

    private static void makeData(Id actionRecTypeId){
        List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
        for(Product_Request__c productRequest : productRequests){
            productRequest.RecordTypeId = PR_EDUC_CONS_ID;
            productRequest.Product_Request_Status__c = 'Design';
        }
        insert productRequests;

        List<Consultancy__c> consultancies = new List<Consultancy__c>();
        for(Integer i=0; i < 1; i ++){
            Consultancy__c cons =new Consultancy__c();
            cons.Name = 'Test Name ' + i;
            cons.Definition_of_Problem__c = 'Test';
            cons.Product_Request__c = productRequests[i].Id;
            cons.Investigation_Summary__c = 'Preparing investigation summary';
            cons.Definition_of_Problem__c = 'Preparing problem definition';
            consultancies.add(cons);
        }
        insert consultancies;

        List<Action__c> actions = new List<Action__c>();
        for(Integer i=0; i < NUM_RECORDS; i ++){
            Action__c action = new Action__c();
            action.Activity_Name__c = 'Test Activity Name ' + i;
            action.Activity_Type__c = 'Meeting';
            action.Consultancy__c = consultancies[0].Id;
            action.RecordTypeId = actionRecTypeId;
            action.Summary__c = 'Preparing action investigation summary';
            actions.add(action);
        }
        insert actions;
    }
}
