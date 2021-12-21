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
      |                           |                       |          |                                 |
*/
@isTest(SeeAllData = false)
public with sharing class Prod_Specs_Send_EmailTest {

    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static Id opeProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('OPE_Program_Specification').getRecordTypeId();

    @isTest
    private static void updateProdSpecsFromQualifyToDesign()
    {
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
            

            List<Product_Specification__c> prodSpec = TestDataFactory.createTestProductSpecsRecords(5,conList,oppList);
            for(Integer i =0;i<prodSpec.size();i++){
                prodSpec[i].Stage__c = 'Idea';
                prodSpec[i].Requestor_Name__c = conList[i].Id;
                prodSpec[i].Endorsed_by__c = conList[i].Id;
                prodSpec[i].Idea_Summary__c = 'Test';
            }
            insert prodSpec;
            
               
            Test.startTest();
            
            List<Product_Specification__c> getProductSpecsRecord = new List<Product_Specification__c>();
            List<Product_Specification__c> productSpecsRec = new List<Product_Specification__c>([SELECT Id, Stage__c  FROM Product_Specification__c LIMIT 100]);

            for(Product_Specification__c prodSpecs : productSpecsRec){
                prodSpecs.RecordTypeId = opeProdSpecId;
                prodSpecs.Stage__c = 'Qualify';
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
                uProdSpecs.Product_Type__c = 'Single Product';
                uProdSpecs.Product_Subtype__c = 'Short Course';
                getUpdatedProductSpecsRecord.add(uProdSpecs);
            }
            update getUpdatedProductSpecsRecord;

        }
        System.debug('insidetest: '+Limits.getEmailInvocations());
        Test.stopTest();
        System.debug('outsidetest: '+Limits.getEmailInvocations());
        System.assertEquals(0, Limits.getEmailInvocations());
    }
   
}
