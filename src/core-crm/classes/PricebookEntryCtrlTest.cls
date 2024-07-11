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
      | john.bo.a.pineda          | May 13, 2022          | DEPP-2591             | Modified to include BuyerGroup PriceBook           |
*/
@isTest
private class PricebookEntryCtrlTest {
    private static String PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static String PR_MODULE = System.Label.RT_ProductRequest_MODULE;
    private static Id opeProgProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static Id opeModuleReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_MODULE).getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
    private static final Id SOA_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Standing_Offer_Arrangement').getRecordTypeId();
    private static final Id ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
    private static final Id ACTIVITY_COURSE_ID = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();

    @testSetup static void setupMethod() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        List<Account> accounts;
        accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account acc : accounts){
            acc.RecordTypeId = ACCT_UNIV_DEP_ID;
            acc.Organization_Unit_Level__c = '2';
        }
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
        insert prodRequest;

        List<hed__Course__c> courses;
        courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequest[0].Id);
        insert courses;

        Pricebook2 priceBook;
        pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
        update pricebook;

        Pricebook2 priceBook2 = new Pricebook2(isActive = true, Name='Current Learner');
        insert priceBook2;

        //there should a product created through flow
        PricebookEntry priceBookEntry;
        priceBookEntry = new PricebookEntry(pricebook2id = pricebook.Id, UnitPrice = 12, product2Id = [SELECT Id FROM Product2 WHERE Program_Plan__c =: programPlanList[0].Id].Id, isActive = true);
        insert priceBookEntry;

        PricebookEntry priceBookEntryNonStandard;
        priceBookEntryNonStandard = new PricebookEntry(pricebook2id = pricebook2.Id, UnitPrice = 12, product2Id = [SELECT Id FROM Product2 WHERE Program_Plan__c =: programPlanList[0].Id].Id, isActive = true);
        insert priceBookEntryNonStandard;

        PricebookEntry priceBookEntry2;
        priceBookEntry2 = new PricebookEntry(pricebook2id = pricebook.Id, UnitPrice = 12, product2Id = [SELECT Id FROM Product2 WHERE Course__c =: courses[0].Id].Id, isActive = true);
        insert priceBookEntry2;

        PricebookEntry priceBookEntryNonStandard2;
        priceBookEntryNonStandard2 = new PricebookEntry(pricebook2id = pricebook2.Id, UnitPrice = 12, product2Id = [SELECT Id FROM Product2 WHERE Course__c =: courses[0].Id].Id, isActive = true);
        insert priceBookEntryNonStandard2;
     }


    @isTest
    private static void upsertPricebookEntriesTest(){
        List<PriceBookEntry> pbEntriesToUpdate = new List<PricebookEntry>();
        List<PriceBookEntry> pbEntries = new List<PriceBookEntry>([SELECT Id, Pricebook2Id, UnitPrice FROM PriceBookEntry]);
        for(PricebookEntry pbE: pbEntries){
            pbE.UnitPrice = 100;
            pbEntriesToUpdate.add(pbE);
        }


        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator)
        {
            BuyerGroup buyerGroup = new BuyerGroup(Name='OPE BuyerGroup');
            insert buyerGroup;

            PricebookEntryCtrl.upsertPricebookEntries(pbEntriesToUpdate);
            System.assert(![SELECT Id FROM PricebookEntry WHERE UnitPrice = 100].isEmpty(),'error updating pricebookentry');
        }
        Test.stopTest();



    }

    @isTest
    private static void getPricebookEntriesCourseTest()
    {


        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator)
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator)
        {
         PricebookEntryCtrl.ResponseWrapper getRecords = new PricebookEntryCtrl.ResponseWrapper();
         getRecords = PricebookEntryCtrl.getPricebookEntries(string.valueOf([SELECT Id FROM Product_Request__c WHERE RecordTypeId =:opeProgProdReqId LIMIT 1].Id));

         System.assert(!getRecords.priceBookEntries.isEmpty(),'Error while getting pricebook entries');
         System.assert(getRecords.priceBooks.isEmpty(),'Error while getting pricebook records');
         System.assert(getRecords.product != null,'Error while getting product records');

        }
        Test.stopTest();

    }

    @isTest
    private static void createSOAPricingTest(){
        Test.startTest();

            BuyerGroup buyerGroup = new BuyerGroup(Name='OPE BuyerGroup');
            insert buyerGroup;

            List<Contact> conList;
            conList = TestDataFactory.createTestContactRecords(1);
            insert conList;
    
            List<Account> accounts = [SELECT Id FROM Account WHERE Organization_Unit_Level__c = '2' LIMIT 1];
    
            List<Opportunity> oppList = TestDataFactory.createClosedWonOpportunities(1,accounts[0].Id,conList.iterator().next()?.Id);
            insert oppList;
    
            List<Product_Specification__c> prodSpecList = TestDataFactory.retrieveCCEProductSpecifications();
    
            List<Product_Request__c> soaRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
    
            Pricebook2 priceBook;
            pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
            update pricebook;
    
            for(Product_Request__c pr : soaRequest){
                pr.RecordTypeId = SOA_ID;        
            }
    
            insert soaRequest;
    
            List<BuyerGroup> bgToInsertList = new List<BuyerGroup>();
                for(Integer i = 0; i<soaRequest.size();i++){
                bgToInsertList.add(new BuyerGroup(Name ='SOA' + i, Product_Request__c = soaRequest[i].Id));
                }
            
            insert bgToInsertList;
    
            List<Product_Request__c> courseRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
                for(Product_Request__c pr : courseRequest){
                    pr.RecordTypeId = ACTIVITY_ID;        
                }
            insert courseRequest;
    
            List<hed__Course__c> courses = new List<hed__Course__c>();
            for(Product_Request__c prC: courseRequest){
            courses.addAll(TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prC.Id));
            }
    
            for(hed__Course__c c: courses){
            c.RecordTypeId = ACTIVITY_COURSE_ID;
            }
            insert courses;
    
            List<Related_Product_Request__c> relatedPRInsert = new List<Related_Product_Request__c>();
            for(Integer i = 0; i < soaRequest.size(); i ++){
            relatedPRInsert.add(new Related_Product_Request__c(Program__c = soaRequest[i].Id, Course__c = courseRequest[i].Id));
            }
            insert relatedPRInsert;
    
            List<Product2> products = new List<Product2>([SELECT Id FROM Product2 WHERE Course__c IN:courses]);
    
            List<PriceBookEntry> newPriceBookEntry = new List<PriceBookEntry>();
            newPriceBookEntry.add(new PriceBookEntry(Product2Id = products[0].Id, PriceBook2Id = priceBook.Id, IsActive = true, UnitPrice = 300));
            
            System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
                PricebookEntryCtrl.upsertPricebookEntries(newPriceBookEntry);
            }
            
            
        Test.stopTest();

        System.assert(![SELECT Id FROM PriceBookEntry Where UnitPrice = 300].isEmpty(), 'No pricebook entry created');
    }

}