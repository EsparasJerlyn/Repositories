/**
 * @description Test class for Product Offering Controller
 *
 * @see ProductOfferingCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                               |
      |---------------------------|-----------------------|--------------|--------------------------------------------------------------|
      | aljohn.motas              | February 8, 2022      | DEPP-1258    | Created file                                                 |
      | kenneth.f.alsay           | December 19, 2023     | DEPP-7447    | Updated courseOffering creation in updateCourseOfferingsTest |
      |                           |                       |              |                                                              |
*/
@isTest
public class ProductOfferingCtrlTest {
    private static final String STR_QUTEXPROD = 'QUTeX Products';
    private static final String STR_QUTEX = 'QUTeX';
    private static final String STR_QUTEX_TERM = STR_QUTEX + ' Term';
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final String ACCT_BUSI_ORG = System.Label.RT_Account_Business_Org;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static final Id ACCT_BUSI_ORG_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_BUSI_ORG).getRecordTypeId();
    private static final Id PERSON_RECORDTYPE_ID = ContactsDAO.PERSON_RECORDTYPE_ID;

    @testSetup static void setup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }
    
    @isTest
    static void getTermIdTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
            acc.Name = STR_QUTEXPROD;
            acc.RecordTypeId = ACCT_BUSI_ORG_ID;
            insert acc;

            Test.startTest();
            String termId = ProductOfferingCtrl.getTermId();
            Test.stopTest();
            System.assertNotEquals(null, termId,'Term ID not as expected');
        }
    }

    @isTest
    static void getSearchedFacilitatorTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
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
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            Contact con = TestDataFactory.createTestContactRecords(1).iterator().next();
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.RecordTypeId = PERSON_RECORDTYPE_ID;
            insert con;

            Test.startTest();
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = con.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            List<Map<String,String>> contacts = ProductOfferingCtrl.getSearchContacts('test');
            Test.stopTest();

            System.assertEquals('Test Contact', contacts[0].get('label'),'Contact Name did not match as expected');
        }
    }

    @isTest
    static void updateFacilitatorDataTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
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
            System.assertEquals(1, updatedCourseConnections.size(), 'updatedCourseConnections is not equal to 1');
        }
    }


    @isTest
    static void getProductOfferingDataTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            Test.startTest();
            List<Product_Request__c> prodRequest =new List<Product_Request__c>();

            final String PROGRAM_OFFERING_FIELDS = 'Id,Delivery_Type__c,Start_Date__c,Registration_Start_Date__c,'+
                'Registration_End_Date__c,End_Date__c,hed_Program_Plan__c';
            String productRequestId;
            Map<String,String> parentInfo = new Map<String,String>();
            parentInfo.put('objectType','hed__Program_Plan__c');
            parentInfo.put('field','Product_Request__c');
            Map<String,String> childInfo = new Map<String,String>();
            childInfo.put('objectType','Program_Offering__c');
            childInfo.put('fields',PROGRAM_OFFERING_FIELDS);
            childInfo.put('conditionField','hed_Program_Plan__c');

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

            ProductOfferingCtrl.ProductOfferingData pod = ProductOfferingCtrl.getProductOfferingData(productRequestId,parentInfo,childInfo);
            Test.stopTest();

            System.assert(pod.relatedFacilitators != null, 'No related facilitators');
            System.assert(pod.relatedSessions != null, 'No related sessions');
        }
    }

    @isTest
    static void getOfferingLayoutTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            Test.startTest();
            Map<String,List<Field_Layout_Setting__mdt>> layoutMap = ProductOfferingCtrl.getOfferingLayout();
            Test.stopTest();
            System.assertEquals(2, layoutMap.keySet().size(),'Layout map not as expected');
        }
    }

    @isTest
    static void updateCourseOfferingsTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
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
            for(hed__Course_Offering__c courseOffering : courseOfferings){
                courseOffering.hed__Start_Date__c = System.today();
                courseOffering.LMS_Creation_Date__c = System.today()-10;
            }
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

    @isTest static void getFacilitatorBiosTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<Id> idList = new List<Id>();
            Contact con = new Contact( LastName = 'Test' );
            insert con;
            Boolean isException = false;
            String errorMsg;
            Test.startTest();
            try{
            	ProductOfferingCtrl.getFacilitatorBios(con.Id, idList);                
            } catch(Exception e) {
                isException = true;
                errorMsg = e.getMessage();
            }
            Test.stopTest();
            System.assert(!isException, 'Exception: ' + errorMsg);
        }
    }
    
    @isTest static void isNewFacilitatorTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Boolean isException = false;
            String errorMsg;
            Test.startTest();
            try {
                ProductOfferingCtrl.isNewFacilitator(null, null);
            } catch(Exception e) {
                isException = true;
                errorMsg = e.getMessage();
            }
            Test.stopTest();
            System.assert(!isException, 'Exception: ' + errorMsg);
        }
    }
}