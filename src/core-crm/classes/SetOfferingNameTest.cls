/**
 * @description Test Class for SetOfferingName
 * @see ..SetOfferingName
 *
 * @author Accenture 
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | Ana                            | 29/4/22               | DEPP-2361              | Created file                 |
 */
@isTest
public with sharing class SetOfferingNameTest {
    private static final Id RT_UNI_DEPT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('University_Department')
        .getRecordTypeId();

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }
    
    @isTest
    private static void testOfferingName() {
         System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
             Account acc = TestDataFactory.createTestAccount(false);
             acc.Organization_Unit_Level__c = '2';
             acc.recordTypeId = RT_UNI_DEPT;
             insert acc;
             
             List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10,acc.Id);
             insert terms;
             
             List<Product_Request__c> prodReqs = TestDataFactory.createTestProductRequestRecords(2);
             insert prodReqs;
             
             List<hed__Course__c> course = TestDataFactory.createTestCourseRecords(1,acc.Id,prodReqs[0].Id);
             insert course;
             
             List<hed__Program_Plan__c> program = TestDataFactory.createTestProgramPlanRecords(1);
             insert program;
             
             Test.startTest();
             List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1,course,terms);
             courseOfferings[0].Name = null;
             insert courseOfferings;
             
             //test increment
             List<hed__Course_Offering__c> courseOfferings2 = TestDataFactory.createTestCourseOfferingRecord(1,course,terms);
             courseOfferings2[0].Name = null;
             insert courseOfferings2;
             
             List<Program_Offering__c> porgramOfferings = TestDataFactory.createTestProgramOfferingRecords(1,program);
             porgramOfferings[0].Name = null;
             insert porgramOfferings;
             
             //test increment
             List<Program_Offering__c> porgramOfferings2 = TestDataFactory.createTestProgramOfferingRecords(1,program);
             porgramOfferings2[0].Name = null;
             insert porgramOfferings2;
             Test.stopTest();
             
             hed__Course_Offering__c courseOffering = [Select Id, Name From hed__Course_Offering__c limit 1];
             system.assertNotEquals(courseOffering.Name, courseOffering.Id, courseOffering.Name);
             
             Program_Offering__c porgramOffering = [Select Id, Name From Program_Offering__c limit 1];
             system.assertNotEquals(porgramOffering.Name, porgramOffering.Id, porgramOffering.Name);
         }
    }
}