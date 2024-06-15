/**
 * @description Tests the Product Specs Send Email to Requestor flow
 *
 * @see Prod_Specs_Send_EmailTest
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | arsenio.dayrit@qut.edu.au | December 09, 2021     | DEPP-1359| Created file                    | 
      | cadalin@qut.edu.au        | June 12, 2022         | DEPP-2485| Renamed refs to OPE record-type |
      |                           |                       |          |                                 |
*/
@isTest
public with sharing class Prod_Specs_Send_EmailTest {

    private static Id opeProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('OPE').getRecordTypeId();

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void updateProdSpecsFromQualifyToDesignInternal()
    {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
            insert customEmail;
            
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
            insert acc;
    
            List<Contact> conList = TestDataFactory.createTestContactRecords(5);
            for(Integer i =0;i<conList.size();i++){
                conList[i].Email = 'testIdeaFormUser'+i+'@mailinator.com';
                conList[i].QUT_Staff_Email__c = 'testIdeaFormUserQUT'+i+'@mailinator.com';
                conList[i].hed__Preferred_Email__c = 'Alternate Email';
                conList[i].hed__AlternateEmail__c = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert conList;
    
            List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(5,acc?.Id,conList.iterator().next()?.Id);
            insert oppList;
            

            List<Product_Specification__c> prodSpec = TestDataFactory.createTestProductSpecsRecords(5,conList,oppList);
            for(Integer i =0;i<prodSpec.size();i++){
                prodSpec[i].Requestor_Name__c = conList[i].Id;
                prodSpec[i].Endorsed_by__c = conList[i].Id;
                prodSpec[i].Idea_Summary__c = 'Test';
                prodSpec[i].Requestor_Internal_External__c = 'Internal';
                prodSpec[i].RecordTypeId = opeProdSpecId;
                prodSpec[i].Stage__c = 'Idea';
            }
            insert prodSpec;
            
               
            Test.startTest();
            
            List<Product_Specification__c> getProductSpecsRecord = new List<Product_Specification__c>();
            List<Product_Specification__c> productSpecsRec = new List<Product_Specification__c>([SELECT Id, Stage__c  FROM Product_Specification__c LIMIT 100]);

            for(Product_Specification__c prodSpecs : productSpecsRec){
                prodSpecs.RecordTypeId = opeProdSpecId;
                prodSpecs.Stage__c = 'Qualify';
                prodSpecs.Requestor_Name__c = conList[0].Id;
                getProductSpecsRecord.add(prodSpecs);
            }
            update getProductSpecsRecord;

            List<Product_Specification__c> getUpdatedProductSpecsRecord = new List<Product_Specification__c>();
            List<Product_Specification__c> updatedProductSpecsRec = new List<Product_Specification__c>([SELECT Id, Stage__c  FROM Product_Specification__c LIMIT 100]);

            for(Product_Specification__c uProdSpecs : updatedProductSpecsRec){
                uProdSpecs.Stage__c = 'Design';
                uProdSpecs.Requires_Director_Endorsement__c = 'Yes';
                uProdSpecs.Financial_Viability__c = 'Yes';
                uProdSpecs.Existing_Product__c = 'No';
                uProdSpecs.Market_Need__c = 'Yes';
                uProdSpecs.QUTeX_Capacity__c = 'Yes';
                uProdSpecs.QUT_Faculty_Capacity__c = 'Yes';
                uProdSpecs.Product_Type__c = 'Module';
                uProdSpecs.Endorsed_by__c = conList[0].Id;
                uProdSpecs.Idea_Summary__c = 'Idea Summary Details';
                uProdSpecs.Supporting_Comments__c = 'Supporting Comments';
                getUpdatedProductSpecsRecord.add(uProdSpecs);
            }
            update getUpdatedProductSpecsRecord;

        }
        Test.stopTest();
        System.assertEquals(0, Limits.getEmailInvocations(),'Email invocations is not 0');
    }

    @isTest
    private static void updateProdSpecsFromQualifyToDesignExternal()
    {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
            insert customEmail;
            
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
            insert acc;
    
            List<Contact> conList = TestDataFactory.createTestContactRecords(5);
            for(Integer i =0;i<conList.size();i++){
                conList[i].Email = 'testIdeaFormUser'+i+'@mailinator.com';
                conList[i].QUT_Staff_Email__c = 'testIdeaFormUserQUT'+i+'@mailinator.com';
                conList[i].hed__Preferred_Email__c = 'Alternate Email';
                conList[i].hed__AlternateEmail__c = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert conList;
    
            List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(5,acc?.Id,conList.iterator().next()?.Id);
            insert oppList;
            

            List<Product_Specification__c> prodSpec = TestDataFactory.createTestProductSpecsRecords(5,conList,oppList);
            for(Integer i =0;i<prodSpec.size();i++){
                prodSpec[i].Requestor_Name__c = conList[i].Id;
                prodSpec[i].Endorsed_by__c = conList[i].Id;
                prodSpec[i].Idea_Summary__c = 'Test';
                prodSpec[i].Requestor_Internal_External__c = 'External';
                prodSpec[i].RecordTypeId = opeProdSpecId;
                prodSpec[i].Stage__c = 'Idea';
            }
            insert prodSpec;
            
               
            Test.startTest();
            
            List<Product_Specification__c> getProductSpecsRecord = new List<Product_Specification__c>();
            List<Product_Specification__c> productSpecsRec = new List<Product_Specification__c>([SELECT Id, Stage__c  FROM Product_Specification__c LIMIT 100]);

            for(Product_Specification__c prodSpecs : productSpecsRec){
                prodSpecs.RecordTypeId = opeProdSpecId;
                prodSpecs.Stage__c = 'Qualify';
                prodSpecs.Requestor_Name__c = conList[0].Id;
                getProductSpecsRecord.add(prodSpecs);
            }
            update getProductSpecsRecord;

            List<Product_Specification__c> getUpdatedProductSpecsRecord = new List<Product_Specification__c>();
            List<Product_Specification__c> updatedProductSpecsRec = new List<Product_Specification__c>([SELECT Id, Stage__c  FROM Product_Specification__c LIMIT 100]);

            for(Product_Specification__c uProdSpecs : updatedProductSpecsRec){
                uProdSpecs.Stage__c = 'Design';
                uProdSpecs.Requires_Director_Endorsement__c = 'Yes';
                uProdSpecs.Financial_Viability__c = 'Yes';
                uProdSpecs.Existing_Product__c = 'No';
                uProdSpecs.Market_Need__c = 'Yes';
                uProdSpecs.QUTeX_Capacity__c = 'Yes';
                uProdSpecs.QUT_Faculty_Capacity__c = 'Yes';
                uProdSpecs.Product_Type__c = 'Module';
                uProdSpecs.Endorsed_by__c = conList[0].Id;
                uProdSpecs.Idea_Summary__c = 'Idea Summary Details';
                uProdSpecs.Supporting_Comments__c = 'Supporting Comments';
                getUpdatedProductSpecsRecord.add(uProdSpecs);
            }
            update getUpdatedProductSpecsRecord;

        }
        Test.stopTest();
        System.assertEquals(0, Limits.getEmailInvocations(),'Email invocations is not 0');
    }
   
}