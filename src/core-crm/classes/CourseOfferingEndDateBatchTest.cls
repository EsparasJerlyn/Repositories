/**
 * @description Test Class for the CourseOfferingEndDateBatch
 *
 * @see CourseOfferingEndDateBatch
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | sebastianne.k.trias       | January 25, 2024      | DEPP-7481    | Created file                                |
      |                           |                       |              |                                             |
*/
@isTest
public with sharing class CourseOfferingEndDateBatchTest {
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup
    static void setupMethod(){
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);

            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }

            for (Account acc : accounts) {
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(3,accounts[0].Id);
            insert terms;

            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
            
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1,accounts[0].Id,prodRequest[0].Id);
            insert courses;

            List<hed__Course_Offering__c> courseOfferings = new List<hed__Course_Offering__c>();
            for (Integer i = 0; i < 2; i++) {
                courseOfferings.add(
                    new hed__Course_Offering__c(
                        Name = 'CourseOffering ' + i,
                        hed__Course__c = courses[0].id,
                        hed__Term__c = terms[i].id,
                        hed__Start_Date__c = system.today().addDays(-15),
                        hed__End_Date__c = system.today().addDays(-2),
                        hed__Capacity__c = 10
                    )
                );
            }
            courseOfferings.add(
                new hed__Course_Offering__c(
                    Name = 'CourseOffering 2',
                    hed__Course__c = courses[0].id,
                    hed__Term__c = terms[2].id,
                    hed__Start_Date__c = system.today().addDays(-1),
                    hed__End_Date__c = system.today().addDays(2),
                    hed__Capacity__c = 10
                )
            );
            insert courseOfferings;
        }
    }

    @isTest
    public static void testCourseOfferingEndDateBatch() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            Test.startTest();

            CourseOfferingEndDateBatch batch = new CourseOfferingEndDateBatch();
            Database.executeBatch(batch);

            Test.stopTest();

            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'CourseOfferingEndDateBatch'].isEmpty() , 'CourseOfferingEndDateBatch Job was not executed');
        }
    }
}