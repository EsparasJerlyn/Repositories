/**
 * @description Tests the ProductRequestTriggerHandlerClass
 *
 * @see ProductRequestTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                                  |
      |---------------------------|-----------------------|-----------|-------------------------------------------------|
      | roy.nino.s.regala         | June 02, 2022         | DEPP-2863 | Created file                                    |
      | arsenio.jr.dayrit         | June 24, 2022         | DEPP-3246 | Added test method for update course and program |
*/
@isTest(SeeAllData=false)
private class ProductRequestTriggerHandlerTest {
    private static final String PR_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final String PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
    private static final String PR_NOT_PROCEEDING = System.Label.PL_ProductRequest_Not_Proceeding;

    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static Id opeActProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_ACTIVITY).getRecordTypeId();
    private static Id opeProgProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static final Id C_ACTIVITY_ID = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(PR_ACTIVITY).getRecordTypeId();
    private static final Id P_PROGRAM_ID = Schema.SObjectType.hed__Program_Plan__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static Date endDate = date.today();

    @testSetup static void setupMethod() {
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
        opps = TestDataFactory.createTestOpportunityRecords(1,accounts[0].Id,contacts[0].Id);
        insert opps;

        List<Product_Specification__c> productSpecs;
        productSpecs = TestDataFactory.createTestProductSpecsRecords(1,contacts,opps);
        insert productSpecs;

        List<Product_Request__c> prodRequest;

        prodRequest = TestDataFactory.createTestProductRequestRecords(50,productSpecs[0].Id);
        prodRequest[0].RecordTypeId = opeActProdReqId;
        insert prodRequest;

        List<hed__Course__c> courses;
        courses = TestDataFactory.createTestCourseRecords(50,accounts[0].Id,prodRequest[0].Id);
        for(hed__Course__c course: courses){
            course.RecordTypeId = C_ACTIVITY_ID;
        } 
        insert courses;

        List<hed__Program_Plan__c> programs;
        programs = TestDataFactory.createTestProgramPlanRecords(50);
        for(hed__Program_Plan__c pro: programs){
            pro.Product_Request__c = prodRequest[0].Id;
            pro.RecordTypeId = P_PROGRAM_ID;
        } 
        insert programs;

    }

    @isTest
    static void notProceedingPRTest() {
        Test.startTest();
        System.runAs(currentUser){
            List<Product_Request__c> prList = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 50];
            for(Product_Request__c pr: prList){
                pr.Product_Request_Status__c = PR_NOT_PROCEEDING;
            }
            update prList;
        }

        system.assert(![SELECT Id FROM Product2 WHERE IsActive = false AND End_Date__c!= null LIMIT 100].isEmpty(), 'products are not deactivated');
        Test.stopTest();
    }

    @isTest
    static void completedPRTest() {
        Test.startTest();
        System.runAs(currentUser){
            List<Product_Request__c> prList = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 50];
            for(Product_Request__c pr: prList){
                pr.Product_Request_Status__c = PR_COMPLETED;
            }
            update prList;
        }
        system.assert(![SELECT Id FROM Product2 WHERE IsActive = false LIMIT 100].isEmpty(), 'products are not deactivated');
        Test.stopTest();
    }

    @isTest
    static void updateCourseTest() {
        Test.startTest();
        System.runAs(currentUser){

            List<Product_Request__c> prList = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 50];
            for(Product_Request__c pr: prList){
                pr.Product_Request_Status__c = PR_NOT_PROCEEDING;
            }
            update prList;
        }

        List<Product2> prod = [SELECT Id , End_Date__c FROM Product2 LIMIT 50];

        List<hed__Course__c> cours = [SELECT Id, End_Date__c FROM hed__Course__c LIMIT 50];

        //system.assertEquals(endDate, cours[0].End_Date__c, 'Course end date must be updated to not proceeding date');
        Test.stopTest();
    }

    
    @isTest
    static void updateProgramTest() {
        Test.startTest();
        System.runAs(currentUser){

            List<Product_Request__c> prList = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 50];
            for(Product_Request__c pr: prList){
                pr.Product_Request_Status__c = PR_NOT_PROCEEDING;
            }
            update prList;
        }

        List<Product2> prod = [SELECT Id , End_Date__c FROM Product2 LIMIT 50];

        List<hed__Program_Plan__c> prog = [SELECT Id, hed__End_Date__c FROM hed__Program_Plan__c LIMIT 50];

        //system.assertEquals(endDate, prog[0].hed__End_Date__c, 'Program end date must be updated to not proceeding date');
        Test.stopTest();
    }



}