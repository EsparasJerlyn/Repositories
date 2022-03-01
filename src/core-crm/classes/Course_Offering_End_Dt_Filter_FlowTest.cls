/**
 * @description Test Class for Course Offering End Date Filter Flow
 *
 * @see ../flows/Course_Offering_End_Date_Filter_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                                                           |
      |---------------------------|-----------------------|--------------|------------------------------------------------------------------------------------------|
      | eccarius.munoz            | December 24, 2021     | DEPP-1109    | Created file                                                                             |
      | johnbo.pineda@qut.edu.au  | January 05, 2022      | DEPP-1382    | Modified to accommodate changes to TestDataFactory for createTestCourseConnectionRecord. |
      | justine.javier@qut.edu.au | February 25, 2022     | DEPP-1819    | Removed Program_Offering__c logic       													|                                                                                          |

*/
@IsTest(SeeAllData = false)
private class Course_Offering_End_Dt_Filter_FlowTest{

    private static User  currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    private static Integer numberOfRecords = 100;

    @IsTest
    private static void courseOfferingFilterEndDateFlowTest(){
        System.runAs(currentUser){
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            insert accounts;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(numberOfRecords, accounts[0].Id);
            insert terms;

            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(numberOfRecords, accounts[0].Id, prodRequest[0].Id);
            insert courses;

            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(numberOfRecords, courses, terms);
            insert courseOfferings;

            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            insert contacts;

            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(1);
            insert programPlans;

            List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(1, contacts[0].Id, courseOfferings);
            insert courseConnections;

            List<Asset> assets = TestDataFactory.createTestAssetRecords(10, accounts[0].Id, prodRequest[0].Id);
            insert assets;

            List<Product_Ledger__c> productLedgers = new List<Product_Ledger__c>();
            Product_Ledger__c productLedger = new Product_Ledger__c();
            productLedger.Course_Connection__c = courseConnections[0].Id;
            productLedger.Asset__c = assets[0].Id;
            productLedgers.add(productLedger);
            insert productLedgers;

            Test.startTest();
            Integer todayOrFutureResp = updateCourseOfferingEndDate(10, '2');
            Integer pastResp = updateCourseOfferingEndDate(-10, '1');
            Test.stopTest();

            System.assertEquals(0, todayOrFutureResp, 'End date of course offering must be filtered as today or in the future.');
            System.assertEquals(0, pastResp, 'End date of course offering must be filtered as past.');
        }
    }

    private static Integer updateCourseOfferingEndDate(Integer numberOfDays, String checker){
        List<hed__Course_Offering__c> courseOfferingList = [SELECT Id, hed__End_Date__c FROM hed__Course_Offering__c];

        Date newDate2 = Date.today().AddDays(numberOfDays);
        for(hed__Course_Offering__c courseOffering : courseOfferingList){
            courseOffering.hed__End_Date__c = newDate2;
        }
        update courseOfferingList;

        List<Product_Ledger__c> productLedgerList = [SELECT Id, Course_Connection__c, Course_Offering_End_Date__c, Course_Offering_End_Date_Checker__c FROM Product_Ledger__c];

        Integer checkerCounter = 0;
        for(Product_Ledger__c productLedger: productLedgerList){
            if(productLedger.Course_Offering_End_Date_Checker__c == checker){
                checkerCounter ++ ;
            }
        }
        return checkerCounter;
    }
}