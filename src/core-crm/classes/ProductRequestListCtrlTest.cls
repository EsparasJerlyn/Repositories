/**
 * @description Tests the Product Request Controller Test Class
 *
 * @see ProductRequestListCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | roy.nino.s.regala         | October 01, 2021      | DEPP40,42 | Created file                    |
      | eccarius.munoz            | March 24, 2022        | DEPP-1888 | Added test method for record    |
      |                           |                       |           | update to Not Proceeding        |
      | john.m.tambasen           | July 06, 2022         | DEPP-1888 | updated test method             |
      | arsenio.jr.dayrit         | April 25, 2023        | DEPP-5554 | added test method               |
*/
@isTest
private class ProductRequestListCtrlTest {
    private static final String PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static final String PR_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final String PR_MODULE = System.Label.RT_ProductRequest_Module;
    private static final String PR_SOA = System.Label.RT_ProductRequest_SOA;
    private static final String PR_EDUC_CONS = System.Label.RT_ProductRequest_Educ_Consultancy;

    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static Id opeProgProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static Id opeActProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_ACTIVITY).getRecordTypeId();
    private static Id opeModProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_MODULE).getRecordTypeId();
    private static Id opeSOAProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_SOA).getRecordTypeId();
    private static Id opeEducConsId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_EDUC_CONS).getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup static void setupMethod() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        List<Account> accounts;
        accounts = TestDataFactory.createTestAccountRecords(1);
        for(Account acc : accounts){
            acc.RecordTypeId = ACCT_UNIV_DEP_ID;
            acc.Organization_Unit_Level__c = '2';
        }
        insert accounts;

        List<Contact> contacts;
        contacts = TestDataFactory.createTestContactRecords(1);
        insert contacts;
        
        List<Opportunity> opps;
        opps = TestDataFactory.createClosedWonOpportunities(1,accounts[0].Id,contacts[0].Id);
        insert opps;

        List<Product_Specification__c> productSpecs = TestDataFactory.retrieveCCEProductSpecifications();
        

        List<Product_Request__c> prodRequestOPEProgramRequest;
        prodRequestOPEProgramRequest = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
        prodRequestOPEProgramRequest[0].Product_Request_Name__c = PR_PROGRAM;
        prodRequestOPEProgramRequest[0].RecordTypeId = opeProgProdReqId;
        insert prodRequestOPEProgramRequest;

        List<Product_Request__c> prodRequestOPEProgramRequestPres;
        prodRequestOPEProgramRequestPres = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
        prodRequestOPEProgramRequestPres[0].Product_Request_Name__c = PR_PROGRAM;
        prodRequestOPEProgramRequestPres[0].RecordTypeId = opeProgProdReqId;
        insert prodRequestOPEProgramRequestPres;

        List<Product_Request__c> prodRequestOPEProgramRequestFlex;
        prodRequestOPEProgramRequestFlex = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
        prodRequestOPEProgramRequestFlex[0].Product_Request_Name__c = PR_PROGRAM;
        prodRequestOPEProgramRequestFlex[0].RecordTypeId = opeProgProdReqId;
        insert prodRequestOPEProgramRequestFlex;

        List<hed__Program_Plan__c> programPlanList;
        programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
        programPlanList[0].Name = PR_PROGRAM;
        programPlanList[0].Product_Request__c = prodRequestOPEProgramRequest[0].Id;
        programPlanList[0].Program_Delivery_Structure__c = 'Prescribed Program';
        insert programPlanList;

        List<hed__Program_Plan__c> programPlanListFlex;
        programPlanListFlex = TestDataFactory.createTestProgramPlanRecords(1);
        programPlanListFlex[0].Product_Request__c = prodRequestOPEProgramRequestFlex[0].Id;
        programPlanListFlex[0].Program_Delivery_Structure__c = 'Flexible Program';
        insert programPlanListFlex;

        List<hed__Program_Plan__c> programPlanListPres;
        programPlanListPres = TestDataFactory.createTestProgramPlanRecords(1);
        programPlanListPres[0].Product_Request__c = prodRequestOPEProgramRequestPres[0].Id;
        programPlanListPres[0].Program_Delivery_Structure__c = 'Prescribed Program';
        insert programPlanListPres;

        List<Product_Request__c> prodRequest;
        prodRequest = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
        prodRequest[0].Product_Request_Name__c = PR_ACTIVITY;
        prodRequest[0].RecordTypeId = opeActProdReqId;
        insert prodRequest;

        List<Product_Request__c> prodRequestMod;
        prodRequestMod = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
        prodRequestMod[0].Product_Request_Name__c = PR_MODULE;
        prodRequestMod[0].RecordTypeId = opeModProdReqId;
        insert prodRequestMod;

        List<hed__Course__c> courses;
        courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequest[0].Id);
        courses[0].Name = PR_ACTIVITY;
        insert courses;

        List<hed__Course__c> coursesMod;
        coursesMod = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequestMod[0].Id);
        insert coursesMod;

        List<Product_Request__c> prodRequestSOA;
        prodRequestSOA = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
        prodRequestSOA[0].Product_Request_Name__c = PR_SOA;
        prodRequestSOA[0].RecordTypeId = opeSOAProdReqId;
        insert prodRequestSOA;

        List<Product_Request__c> prodRequestSOASingle;
        prodRequestSOASingle = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
        prodRequestSOASingle[0].RecordTypeId = opeSOAProdReqId;
        insert prodRequestSOASingle;

        List<Related_Product_Request__c> relatedProductRequests;
        relatedProductRequests = TestDataFactory.createTestRelatedPRRecords(1,prodRequest,prodRequestOPEProgramRequest);
        insert relatedProductRequests;

        List<Related_Product_Request__c> relatedProductRequests2;
        relatedProductRequests2 = TestDataFactory.createTestRelatedPRRecords(1,prodRequestOPEProgramRequest,prodRequest);
        insert relatedProductRequests2;

        List<Related_Product_Request__c> relatedProductRequestsSOA;
        relatedProductRequestsSOA = TestDataFactory.createTestRelatedPRRecords(1,prodRequestOPEProgramRequest,prodRequestSOA);
        insert relatedProductRequestsSOA;

        List<Product_Request__c> educConsultancyProdRequest;
        educConsultancyProdRequest = TestDataFactory.createTestProductRequestRecords(1,productSpecs[0].Id);
        educConsultancyProdRequest[0].RecordTypeId = opeEducConsId;
        insert educConsultancyProdRequest;

        List<Consultancy__c> consultancies = new List<Consultancy__c>();
        consultancies.add(
            new Consultancy__c (
                Name = 'Test Consultancy Name',
                Product_Request__c = educConsultancyProdRequest[0].Id,
                Investigation_Summary__c = 'Investigation Summary with at least 20 characters in it'));
        insert consultancies;
    }

    @isTest
    static void testGetProductRequestsCourse() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
        Test.startTest();
            List<Account> accounts;
            accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;
            List<Product_Specification__c> prodSpec = [SELECT Id, Name FROM Product_Specification__c LIMIT 1];
            List<Product_Request__c> prodReqProg = [SELECT Id, Name FROM Product_Request__c WHERE RecordTypeId =: opeSOAProdReqId LIMIT 1];

            List<Product_Request__c> prodRequestChild;
            prodRequestChild = TestDataFactory.createTestProductRequestRecords(1,prodSpec[0].Id);
            prodRequestChild[0].Product_Request_Name__c = PR_ACTIVITY;
            prodRequestChild[0].RecordTypeId = opeActProdReqId;
            insert prodRequestChild;

            List<hed__Course__c> coursesChild;
            coursesChild = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequestChild[0].Id);
            coursesChild[0].Name = PR_ACTIVITY;
            insert coursesChild;


            List<Related_Product_Request__c> relatedProductRequests;
            relatedProductRequests = TestDataFactory.createTestRelatedPRRecords(1,prodRequestChild,prodReqProg);
            insert relatedProductRequests; 


            ProductRequestListCtrl.ProductRequestData getProdReqs = new ProductRequestListCtrl.ProductRequestData();
            getProdReqs = ProductRequestListCtrl.getProductRequests(string.valueOf([SELECT Id, Product_Specification__c FROM Product_Request__c  WHERE RecordTypeId =: opeSOAProdReqId Limit 1].Product_Specification__c));
            system.assert( !getProdReqs.productRequestData.isEmpty(), 'unable to get product requests');
        Test.stopTest();
        }
    }

    @isTest
    static void testGetProductRequestsProgram() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
        Test.startTest();
            ProductRequestListCtrl.ProductRequestData getProdReqs = new ProductRequestListCtrl.ProductRequestData();
            getProdReqs = ProductRequestListCtrl.getProductRequests(string.valueOf([SELECT Id, Product_Specification__c FROM Product_Request__c  WHERE RecordTypeId =: opeProgProdReqId Limit 1].Product_Specification__c));
            system.assert( !getProdReqs.productRequestData.isEmpty(), 'unable to get product requests');
        Test.stopTest();
        }
    }

    @isTest
    static void testGetProductRequestsCourseWithGrandChild() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
        Test.startTest();
            ProductRequestListCtrl.ProductRequestData getProdReqs = new ProductRequestListCtrl.ProductRequestData();
            List<Account> accounts;
            accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;
            List<Product_Specification__c> prodSpec = [SELECT Id, Name FROM Product_Specification__c LIMIT 1];
            List<Product_Request__c> prodReqProg = [SELECT Id, Name FROM Product_Request__c WHERE RecordTypeId =: opeProgProdReqId LIMIT 1];

            List<Product_Request__c> prodRequestProgramRequest;
            prodRequestProgramRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpec[0].Id);
            prodRequestProgramRequest[0].Product_Request_Name__c = PR_PROGRAM;
            prodRequestProgramRequest[0].RecordTypeId = opeProgProdReqId;
            insert prodRequestProgramRequest;

            List<hed__Program_Plan__c> programPlanList;
            programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
            programPlanList[0].Name = PR_PROGRAM;
            programPlanList[0].Product_Request__c = prodRequestProgramRequest[0].Id;
            programPlanList[0].Program_Delivery_Structure__c = 'Prescribed Program';
            insert programPlanList;

            List<Related_Product_Request__c> relatedProductRequests;
            relatedProductRequests = TestDataFactory.createTestRelatedPRRecords(1,prodReqProg,prodRequestProgramRequest);
            insert relatedProductRequests;

            List<Product_Request__c> prodRequestGrandChild;
            prodRequestGrandChild = TestDataFactory.createTestProductRequestRecords(1,prodSpec[0].Id);
            prodRequestGrandChild[0].Product_Request_Name__c = PR_ACTIVITY;
            prodRequestGrandChild[0].RecordTypeId = opeActProdReqId;
            insert prodRequestGrandChild;

            List<hed__Course__c> coursesGrandChild;
            coursesGrandChild = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequestGrandChild[0].Id);
            coursesGrandChild[0].Name = PR_ACTIVITY;
            insert coursesGrandChild;

            List<Related_Product_Request__c> relatedProductRequests1;
            relatedProductRequests1 = TestDataFactory.createTestRelatedPRRecords(1,prodRequestGrandChild,prodReqProg);
            insert relatedProductRequests1;

            getProdReqs = ProductRequestListCtrl.getProductRequests(string.valueOf([SELECT Id, Product_Specification__c FROM Product_Request__c  WHERE RecordTypeId =: opeProgProdReqId Limit 1].Product_Specification__c));
            system.assert( !getProdReqs.productRequestData.isEmpty(), 'unable to get product requests');
        
        Test.stopTest();
        }
    }

    @isTest
    static void testGetProductRequestsProgramPresWithGrandChild() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
        Test.startTest();
            ProductRequestListCtrl.ProductRequestData getProdReqs = new ProductRequestListCtrl.ProductRequestData();
            List<Product_Specification__c> prodSpec = [SELECT Id, Name FROM Product_Specification__c LIMIT 1];
            List<Product_Request__c> prodReqProg = [SELECT Id, Name FROM Product_Request__c WHERE RecordTypeId =: opeProgProdReqId LIMIT 1];

            List<Product_Request__c> prodRequestProgramRequest;
            prodRequestProgramRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpec[0].Id);
            prodRequestProgramRequest[0].Product_Request_Name__c = PR_PROGRAM;
            prodRequestProgramRequest[0].RecordTypeId = opeProgProdReqId;
            insert prodRequestProgramRequest;

            List<hed__Program_Plan__c> programPlanList;
            programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
            programPlanList[0].Name = PR_PROGRAM;
            programPlanList[0].Product_Request__c = prodRequestProgramRequest[0].Id;
            programPlanList[0].Program_Delivery_Structure__c = 'Prescribed Program';
            insert programPlanList;

            List<Related_Product_Request__c> relatedProductRequests;
            relatedProductRequests = TestDataFactory.createTestRelatedPRRecords(1,prodReqProg,prodRequestProgramRequest);
            insert relatedProductRequests;

            List<Product_Request__c> prodRequestGrandChild;
            prodRequestGrandChild = TestDataFactory.createTestProductRequestRecords(1,prodSpec[0].Id);
            prodRequestGrandChild[0].Product_Request_Name__c = PR_PROGRAM;
            prodRequestGrandChild[0].RecordTypeId = opeProgProdReqId;
            insert prodRequestGrandChild;

            List<hed__Program_Plan__c> programPlanGrandChild;
            programPlanGrandChild = TestDataFactory.createTestProgramPlanRecords(1);
            programPlanGrandChild[0].Name = PR_PROGRAM;
            programPlanGrandChild[0].Product_Request__c = prodRequestGrandChild[0].Id;
            programPlanGrandChild[0].Program_Delivery_Structure__c = 'Prescribed Program';
            insert programPlanGrandChild;

            List<Related_Product_Request__c> relatedProductRequests1;
            relatedProductRequests1 = TestDataFactory.createTestRelatedPRRecords(1,prodRequestGrandChild,prodReqProg);
            insert relatedProductRequests1;

            getProdReqs = ProductRequestListCtrl.getProductRequests(string.valueOf([SELECT Id, Product_Specification__c FROM Product_Request__c  WHERE RecordTypeId =: opeProgProdReqId Limit 1].Product_Specification__c));
            system.assert( !getProdReqs.productRequestData.isEmpty(), 'unable to get product requests');

        Test.stopTest();
        }
    }

    @isTest
    static void testGetProductRequestsProgramFlexWithGrandChild() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
        Test.startTest();
            ProductRequestListCtrl.ProductRequestData getProdReqs = new ProductRequestListCtrl.ProductRequestData();
            List<Product_Specification__c> prodSpec = [SELECT Id, Name FROM Product_Specification__c LIMIT 1];
            List<Product_Request__c> prodReqProg = [SELECT Id, Name FROM Product_Request__c WHERE RecordTypeId =: opeProgProdReqId LIMIT 1];

            List<Product_Request__c> prodRequestProgramRequest;
            prodRequestProgramRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpec[0].Id);
            prodRequestProgramRequest[0].Product_Request_Name__c = PR_PROGRAM;
            prodRequestProgramRequest[0].RecordTypeId = opeProgProdReqId;
            insert prodRequestProgramRequest;

            List<hed__Program_Plan__c> programPlanList;
            programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
            programPlanList[0].Name = PR_PROGRAM;
            programPlanList[0].Product_Request__c = prodRequestProgramRequest[0].Id;
            programPlanList[0].Program_Delivery_Structure__c = 'Flexible Program';
            insert programPlanList;

            List<Related_Product_Request__c> relatedProductRequests;
            relatedProductRequests = TestDataFactory.createTestRelatedPRRecords(1,prodReqProg,prodRequestProgramRequest);
            insert relatedProductRequests;

            List<Product_Request__c> prodRequestGrandChild;
            prodRequestGrandChild = TestDataFactory.createTestProductRequestRecords(1,prodSpec[0].Id);
            prodRequestGrandChild[0].Product_Request_Name__c = PR_PROGRAM;
            prodRequestGrandChild[0].RecordTypeId = opeProgProdReqId;
            insert prodRequestGrandChild;

            List<Related_Product_Request__c> relatedProductRequests1;
            relatedProductRequests1 = TestDataFactory.createTestRelatedPRRecords(1,prodRequestGrandChild,prodReqProg);
            insert relatedProductRequests1;

            getProdReqs = ProductRequestListCtrl.getProductRequests(string.valueOf([SELECT Id, Product_Specification__c FROM Product_Request__c  WHERE RecordTypeId =: opeProgProdReqId Limit 1].Product_Specification__c));
            system.assert( !getProdReqs.productRequestData.isEmpty(), 'unable to get product requests');

        Test.stopTest();
        }
    }


    @isTest
    static void testGetProductRequestsProgramFlex() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
        Test.startTest();
            ProductRequestListCtrl.ProductRequestData getProdReqs = new ProductRequestListCtrl.ProductRequestData();
            getProdReqs = ProductRequestListCtrl.getProductRequests(string.valueOf([SELECT Id, Product_Specification__c, (SELECT Id, Program_Delivery_Structure__c FROM Program_Plans__r WHERE Program_Delivery_Structure__c = 'Flexible Program') 
            FROM Product_Request__c  WHERE RecordTypeId =: opeProgProdReqId Limit 1].Product_Specification__c));
            system.assert( !getProdReqs.productRequestData.isEmpty(), 'unable to get product requests');
        Test.stopTest();
        }
    }

    @isTest
    static void testGetProductRequestsProgramPres() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
        Test.startTest();
            ProductRequestListCtrl.ProductRequestData getProdReqs = new ProductRequestListCtrl.ProductRequestData();
            getProdReqs = ProductRequestListCtrl.getProductRequests(string.valueOf([SELECT Id, Product_Specification__c, (SELECT Id, Program_Delivery_Structure__c FROM Program_Plans__r WHERE Program_Delivery_Structure__c = 'Prescribed Program') 
            FROM Product_Request__c  WHERE RecordTypeId =: opeProgProdReqId Limit 1].Product_Specification__c));
            system.assert( !getProdReqs.productRequestData.isEmpty(), 'unable to get product requests');
        Test.stopTest();
        }
    }

    @isTest
    static void testUpdateProdReqCourseToNotProceeding() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Product2 testProduct = [
                SELECT
                    Id,
                    Name,
                    Course__c,
                    Course__r.ProductRequestID__c,
                    QA_Review_Completed__c
                FROM Product2
                WHERE
                    Course__r.ProductRequestID__c != null
                LIMIT 1];

            testProduct.QA_Review_Completed__c = 'Yes';
            testProduct.Ready_for_publishing__c = 'Yes';
            update testProduct;


            Test.startTest();
                // Id productRequestId = [SELECT Id, Name, Product_Request_Status__c FROM Product_Request__c LIMIT 1].Id;
                String response = ProductRequestListCtrl.updateProdReqToNotProceeding(testProduct.Course__r.ProductRequestID__c, PR_ACTIVITY, 'notProceedingComment', false);
                System.assertEquals('Success', response, 'Failed to update record.');
            Test.stopTest();
        }
    }

    @isTest
    static void testUpdateProdReqProgramToNotProceeding() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Product2 testProduct = [
                SELECT
                    Id,
                    Name,
                    Program_Plan__c,
                    Program_Plan__r.Product_Request__c,
                    QA_Review_Completed__c
                FROM Product2
                WHERE
                Program_Plan__r.Product_Request__c != null
                LIMIT 1];

            testProduct.QA_Review_Completed__c = 'Yes';
            testProduct.Ready_for_publishing__c = 'Yes';
            update testProduct;


            Test.startTest();
                // Id productRequestId = [SELECT Id, Name, Product_Request_Status__c FROM Product_Request__c LIMIT 1].Id;
                String response = ProductRequestListCtrl.updateProdReqToNotProceeding(testProduct.Program_Plan__r.Product_Request__c, PR_PROGRAM, 'notProceedingComment', false);
                System.assertEquals('Success', response, 'Failed to update record.');
            Test.stopTest();
        }
    }



}
