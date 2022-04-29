/**
 * @description Test Class for the OfferingStartDateBatch
 *
 * @see OfferingStartDateBatch
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | angelika.j.s.galang		  | March 15, 2022        | DEPP-1890            | Created file                 |
      |                           |                       |                      |                              |
 */
@IsTest(SeeAllData=false)
public with sharing class OfferingStartDateBatchTest {

    private static final String QUTEX = System.Label.QUTeX;
    private static User currentUser = TestDataFactory.createUserRecords(1, QUTEX).iterator().next();
    private static final String COURSE_OFFERING_API_NAME = hed__Course_Offering__c.SObjectType.getDescribe().getLocalName();
    private static final String RT_PR_SHORTCOURSE = System.Label.RT_ProductRequest_ShortCourse;
    private static final String RT_C_SHORTCOURSE = System.Label.RT_Course_ShortCourse;
    private static final Id PR_SHORTCOURSE_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_PR_SHORTCOURSE).getRecordTypeId();
    private static final Id C_SHORTCOURSE_ID = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(RT_C_SHORTCOURSE).getRecordTypeId();
    private static final Integer NO_OF_RECORDS = 100;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @TestSetup
    static void setupMethod(){
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
        insert acc;

        List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(NO_OF_RECORDS);
        for(Product_Request__c productRequest : productRequests){
            productRequest.RecordTypeId = PR_SHORTCOURSE_ID;
            productRequest.Product_Request_Status__c = 'Release';
        }
        insert productRequests;

        List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(NO_OF_RECORDS, acc?.Id, productRequests[0].Id);
        for(Integer i = 0 ; i < courses.size() ; i++){
            courses[i].ProductRequestID__c = productRequests[i].Id;
            courses[i].RecordTypeId = C_SHORTCOURSE_ID;
        }
        insert courses;

        List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(100,acc?.Id);
        insert terms;

        List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(100,courses,terms);
        for(hed__Course_Offering__c courseOffering : courseOfferings){
            courseOffering.hed__Start_Date__c = System.today();
        }
        insert courseOfferings;
    }

    @IsTest
    public static void testOfferingStartDateBatch() {
        System.runAs(currentUser){
            try{
                Test.startTest();
                OfferingStartDateBatch batch = new OfferingStartDateBatch(COURSE_OFFERING_API_NAME);
                Id batchId = Database.executeBatch(batch);
                Test.stopTest();
                System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'OfferingStartDateBatch'].isEmpty() , 'OfferingStartDateBatch Job was not executed');
            }catch(Exception e){
               System.debug('ERROR: ' + e.getMessage());
            }
        }
    }
 }