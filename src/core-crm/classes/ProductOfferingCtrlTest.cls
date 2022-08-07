/**
 * @description Test class for Product Offering Controller
 *
 * @see ProductOfferingCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                |
      |---------------------------|-----------------------|--------------|-----------------------------------------------|
      | aljohn.motas              | February 8, 2022      | DEPP-1258    | Created file                                  |
      |                           |                       |              |                                               |
*/
@isTest(SeeAllData=false)
public class ProductOfferingCtrlTest {
    private static final String STR_QUTEXPROD = 'QUTeX Products';
    private static final String STR_QUTEX = 'QUTeX';
    private static final String STR_QUTEX_TERM = STR_QUTEX + ' Term';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTEX).iterator().next();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @isTest
    static void getTermIdTest() {
        System.runAs(currentUser){
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
            acc.Name = STR_QUTEXPROD;
            insert acc;
            Test.startTest();
            String termId = ProductOfferingCtrl.getTermId();
            Test.stopTest();
            System.assertNotEquals(null, termId,'Term ID not as expected');
        }
    }

    @isTest
    static void getSearchedFacilitatorTest() {
        System.runAs(currentUser){
            Contact con = TestDataFactory.createTestContactRecords(1).iterator().next();
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            insert con;
            Facilitator_Bio__c faciBio = new Facilitator_Bio__c(
                Facilitator__c = con?.Id
            );
            insert faciBio;

            Test.startTest();
            List<Map<String,String>> facilitators = ProductOfferingCtrl.getSearchedFacilitator('test',new List<Id>{});
            Test.stopTest();

            System.assertEquals('Test Contact', facilitators[0].get('label'),'Facilitator Name did not match as expected');
        }
    }

    @isTest
    static void getSearchedContactTest() {
        System.runAs(currentUser){
            Contact con = TestDataFactory.createTestContactRecords(1).iterator().next();
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            insert con;

            Test.startTest();
            List<Map<String,String>> contacts = ProductOfferingCtrl.getSearchContacts('test');
            Test.stopTest();

            System.assertEquals('Test Contact', contacts[0].get('label'),'Contact Name did not match as expected');
        }
    }

    @isTest
    static void updateFacilitatorDataTest() {
        System.runAs(currentUser){
            Contact con = TestDataFactory.createTestContactRecords(1).iterator().next();
            insert con;
            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(25,accounts[0].Id,prodRequest[0].Id);
            insert courses;
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(25,accounts[0].Id);
            insert terms;
            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(25,courses,terms);
            insert courseOfferings;
            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(25);
            insert programPlans;
            List<hed__Course_Enrollment__c> courseConnections =  TestDataFactory.createTestCourseConnectionRecord(25,con?.Id,courseOfferings);
            insert courseConnections;
            courseConnections[0].hed__Account__c = accounts[0]?.Id;
            List<Facilitator_Bio__c> faciBios = new List<Facilitator_Bio__c>();
            Map<String,List<SObject>> faciData = new Map<String,List<SObject>>();
            faciData.put('courseConnections',courseConnections);
            faciData.put('facilitatorBios',faciBios);
            Test.startTest();
            ProductOfferingCtrl.updateFacilitatorData(faciData);
            Test.stopTest();
            List<hed__Course_Enrollment__c> updatedCourseConnections = [Select hed__Account__c From hed__Course_Enrollment__c Where hed__Account__c =: accounts[0].Id];
            System.assertEquals(1, updatedCourseConnections.size());
        }
    }


    @isTest
    static void getProductOfferingDataTest() {
        System.runAs(currentUser){
            List<Product_Request__c> prodRequest =new List<Product_Request__c>();
            List<hed__Course_Enrollment__c> courseConnectionRecord = new List<hed__Course_Enrollment__c>();

            String PROGRAM_OFFERING_FIELDS = 'Id,Delivery_Type__c,Start_Date__c,Registration_Start_Date__c,'+
                'Registration_End_Date__c,End_Date__c,hed_Program_Plan__c';
            String COURSE_OFFERING_FIELDS ='Id,Delivery_Type__c,hed__Start_Date__c,Registration_Start_Date__c,'+
                'Registration_End_Date__c,hed__End_Date__c,hed__Course__c,hed__Term__c';
            String productRequestId;
            Map<String,String> parentInfo = new Map<String,String>();
            parentInfo.put('objectType','hed__Program_Plan__c');
            parentInfo.put('field','Product_Request__c');
            Map<String,String> childInfo = new Map<String,String>();
            childInfo.put('objectType','Program_Offering__c');
            childInfo.put('fields',PROGRAM_OFFERING_FIELDS);
            childInfo.put('conditionField','hed_Program_Plan__c');

            List<hed__Program_Plan__c> programPlans = new List<hed__Program_Plan__c>();
            List<Program_Offering__c> programOfferings = new List<Program_Offering__c>();

            prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;

            List<hed__Program_Plan__c> programPlanList = new List<hed__Program_Plan__c>();
            programPlanList.add(new hed__Program_Plan__c(Name = 'Test Program Plan',Product_Request__c=prodRequest[0].Id));
            insert programPlanList;
            productRequestId = prodRequest[0].Id;
            programOfferings.add(
                new Program_Offering__c(
                Name = 'Test Program Offering',
                hed_Program_Plan__c = programPlanList[0].id,
                hed_Capacity__c = 10,
                Start_Date__c = system.today() + 1
                )
            );
            insert programOfferings;

            Test.startTest();
            ProductOfferingCtrl.ProductOfferingData POD = ProductOfferingCtrl.getProductOfferingData(productRequestId,parentInfo,childInfo);
            Test.stopTest();
        }
    }

    @isTest
    static void getOfferingLayoutTest() {
        System.runAs(currentUser){
            Test.startTest();
            Map<String,List<Field_Layout_Setting__mdt>> layoutMap = ProductOfferingCtrl.getOfferingLayout();
            Test.stopTest();
            System.assertEquals(2, layoutMap.keySet().size(),'Layout map not as expected');
        }
    }

    @isTest
    static void updateCourseOfferingsTest() {
        System.runAs(currentUser){
            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(25,accounts[0].Id,prodRequest[0].Id);
            insert courses;
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(25,accounts[0].Id);
            insert terms;
            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(25,courses,terms);
            insert courseOfferings;
            for(hed__Course_Offering__c offering : courseOfferings){
                offering.IsActive__c = false;
            }
            Test.startTest();
            ProductOfferingCtrl.updateCourseOfferings(courseOfferings);
            Test.stopTest();
            for(hed__Course_Offering__c offering : [
                SELECT IsActive__c 
                FROM hed__Course_Offering__c 
                WHERE Id IN :courseOfferings
            ])
            {
                System.assertEquals(false, offering.IsActive__c,'Course Offering not updated as expected');
            }
        }
    }

}