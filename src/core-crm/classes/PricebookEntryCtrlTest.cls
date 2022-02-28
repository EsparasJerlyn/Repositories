/**
 * @description Tests the Product Details Controller Test Class
 *
 * @see PricebookEntryCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                  | Change Summary                                     |
      |---------------------------|-----------------------|-----------------------|----------------------------------------------------|
      | roy.nino.s.regala         | Febuary 14, 2022      | DEPP-1406,1257,1773   | Created file                                       | 
*/
@isTest(SeeAllData=false)
private class PricebookEntryCtrlTest {
    private static String PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static String PR_MODULE = System.Label.RT_ProductRequest_MODULE;
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static Id opeProgProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static Id opeModuleReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_MODULE).getRecordTypeId();


    @testSetup static void setupMethod() {
        List<Account> accounts;
        accounts = TestDataFactory.createTestAccountRecords(1);
        insert accounts;

        List<Product_Request__c> prodRequestOPEProgramRequest;
        prodRequestOPEProgramRequest = TestDataFactory.createTestProductRequestRecords(1);
        prodRequestOPEProgramRequest[0].Product_Request_Name__c = 'Program Request';
        prodRequestOPEProgramRequest[0].RecordTypeId = opeProgProdReqId;
        insert prodRequestOPEProgramRequest;

        List<hed__Program_Plan__c> programPlanList;
        programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
        programPlanList[0].Product_Request__c = prodRequestOPEProgramRequest[0].Id;
        insert programPlanList;

        List<Product_Request__c> prodRequest;
        prodRequest = TestDataFactory.createTestProductRequestRecords(1);
        prodRequest[0].RecordTypeId = opeModuleReqId;
        prodRequest[0].Parent_Product_Request__c = prodRequestOPEProgramRequest[0].Id;
        insert prodRequest;

        List<hed__Course__c> courses;
        courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequest[0].Id);
        insert courses;

        Pricebook2 priceBook;
        pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
        update pricebook;
        
        //there should a product created through flow
        PricebookEntry priceBookEntry;
        priceBookEntry = new PricebookEntry(pricebook2id = pricebook.Id, UnitPrice = 12, product2Id = [SELECT Id FROM Product2 WHERE Program_Plan__c =: programPlanList[0].Id].Id, isActive = true);
        insert priceBookEntry;

        PricebookEntry priceBookEntry2;
        priceBookEntry2 = new PricebookEntry(pricebook2id = pricebook.Id, UnitPrice = 12, product2Id = [SELECT Id FROM Product2 WHERE Course__c =: courses[0].Id].Id, isActive = true);
        insert priceBookEntry2;



     }


    @isTest
    private static void upsertPricebookEntriesTest(){
        List<PriceBookEntry> pbEntriesToUpdate = new List<PricebookEntry>();
        List<PriceBookEntry> pbEntries = new List<PriceBookEntry>([SELECT Id, UnitPrice FROM PriceBookEntry]);
        for(PricebookEntry pbE: pbEntries){
            pbE.UnitPrice = 100;
            pbEntriesToUpdate.add(pbE);
        }


        Test.startTest();
        System.runAs(currentUser)
        {
            PricebookEntryCtrl.upsertPricebookEntries(pbEntriesToUpdate);
            System.assert(![SELECT Id FROM PricebookEntry WHERE UnitPrice = 100].isEmpty(),'error updating pricebookentry');
        }
        Test.stopTest();
        


    }
    
    @isTest
    private static void getPricebookEntriesCourseTest()
    {
        

        Test.startTest();
        System.runAs(currentUser)
        {   
         PricebookEntryCtrl.ResponseWrapper getRecords = new PricebookEntryCtrl.ResponseWrapper();
         getRecords = PricebookEntryCtrl.getPricebookEntries(string.valueOf([SELECT Id FROM Product_Request__c WHERE RecordTypeId =:opeModuleReqId LIMIT 1].Id)); 
        
         System.assert(!getRecords.priceBookEntries.isEmpty(),'Error while getting pricebook entries');
         System.assert(getRecords.priceBooks.isEmpty(),'Error while getting pricebook records');
         System.assert(getRecords.product != null,'Error while getting product records');

        }
        Test.stopTest();
        
    }

    @isTest
    private static void getPricebookEntriesProgramTest()
    {
        

        Test.startTest();
        System.runAs(currentUser)
        {   
         PricebookEntryCtrl.ResponseWrapper getRecords = new PricebookEntryCtrl.ResponseWrapper();
         getRecords = PricebookEntryCtrl.getPricebookEntries(string.valueOf([SELECT Id FROM Product_Request__c WHERE RecordTypeId =:opeProgProdReqId LIMIT 1].Id)); 

         System.assert(!getRecords.priceBookEntries.isEmpty(),'Error while getting pricebook entries');
         System.assert(getRecords.priceBooks.isEmpty(),'Error while getting pricebook records');
         System.assert(getRecords.product != null,'Error while getting product records');

        }
        Test.stopTest();
        
    }

}